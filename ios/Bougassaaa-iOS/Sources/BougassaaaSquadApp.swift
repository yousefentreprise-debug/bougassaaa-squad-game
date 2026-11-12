import SwiftUI
import Combine

@MainActor final class GameModel: ObservableObject {
    @Published private(set) var save: SaveData
    private let key = "bougassaaa.squad.save.v1"
    var language: GameLanguage { save.language ?? .it }
    var run: Run { save.run }
    init() {
        if let data = UserDefaults.standard.data(forKey:key), let decoded = try? JSONDecoder().decode(SaveData.self,from:data) {
            save = decoded
            if save.run.phase == .playing { save.run.phase = .paused }
            if save.run.character == nil { save.run.character = .bougassaaa }
            if save.run.level == nil { save.run.level = 1 }
            if save.run.keyCollected == nil { save.run.keyCollected = false }
        } else { save = SaveData() }
    }
    func persist() { if let data = try? JSONEncoder().encode(save) { UserDefaults.standard.set(data,forKey:key) } }
    func setLanguage(_ language:GameLanguage) { save.language = language; persist() }
    func chooseCharacter(_ character:CharacterID) { guard save.run.phase == .ready else { return }; save.run.character = character; persist() }
    func start() { guard save.run.phase == .ready else { return }; save.run.phase = .playing; persist() }
    func pause() { guard save.run.phase == .playing else { return }; save.run.phase = .paused; persist() }
    func resume() { guard save.run.phase == .paused else { return }; save.run.phase = .playing; persist() }
    func resetLevel() { let r = save.run; save.run = GameEngine.freshRun(level:r.currentLevel,character:r.selectedCharacter,language:language); persist() }
    func nextLevel() { let r = save.run; guard r.phase == .won && r.currentLevel < maximumLevel else { return }; save.run = GameEngine.freshRun(level:r.currentLevel+1,character:r.selectedCharacter,language:language); persist() }
    func move(to cell:Cell,dash:Bool) {
        let old = save.run, next = GameEngine.advance(old,to:cell,dash:dash,language:language)
        guard next != old else { return }; save.run = next
        if next.phase == .won || next.phase == .lost { save.best = max(save.best,GameEngine.points(next)); save.played += 1; if next.phase == .won { save.wins += 1 } }
        persist()
    }
    func waitTurn() {
        let old = save.run, next = GameEngine.waitTurn(old,language:language)
        guard next != old else { return }; save.run = next
        if next.phase == .won || next.phase == .lost { save.best = max(save.best,GameEngine.points(next)); save.played += 1; if next.phase == .won { save.wins += 1 } }
        persist()
    }
}
extension Color {
    init(hex:UInt) { self.init(red:Double((hex>>16)&255)/255,green:Double((hex>>8)&255)/255,blue:Double(hex&255)/255) }
}
struct GameView: View {
    @StateObject private var model = GameModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var dashArmed = false
    @State private var help = false
    private let bg = Color(hex:0x101020), lime = Color(hex:0xDCFF64)
    private var run:Run { model.run }
    private var language:GameLanguage { model.language }
    private var selected:CharacterID { run.selectedCharacter }
    private var activeFriends:[SquadFriend] { GameEngine.friends(for:selected) }
    private func t(_ key:String)->String { GameText.text(key,language) }
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing:12) {
                    languagePicker
                    campaignBar
                    hud
                    ZStack {
                        board
                        if run.phase != .playing {
                            Color.black.opacity(0.56).clipShape(RoundedRectangle(cornerRadius:14))
                            dialog
                                .padding(10)
                        }
                    }
                    squad
                    Text(run.message.isEmpty ? t("dangerHint") : run.message)
                        .font(.caption).foregroundStyle(.white.opacity(0.82)).frame(maxWidth:.infinity,alignment:.leading)
                        .accessibilityAddTraits(.updatesFrequently)
                    controls
                    Button(t("rules")) { help = true }.font(.footnote.weight(.semibold)).padding(8)
                }
                .padding(.horizontal,18).padding(.vertical,12)
                .frame(maxWidth:560).frame(maxWidth:.infinity).frame(minHeight:geometry.size.height)
                .environment(\.layoutDirection,language == .ary ? .rightToLeft : .leftToRight)
            }
            .background(bg.ignoresSafeArea())
        }
        .preferredColorScheme(.dark).tint(lime)
        .sheet(isPresented:$help) { rules }
        .onChange(of:scenePhase) { phase in if phase != .active { model.pause(); dashArmed = false } }
        .onChange(of:run.phase) { phase in if phase != .playing { dashArmed = false } }
    }
    private var languagePicker:some View {
        HStack(spacing:6) {
            Text(t("language")).font(.caption.bold()).foregroundStyle(.secondary)
            Spacer(minLength:2)
            ForEach(GameLanguage.allCases) { locale in
                Button { model.setLanguage(locale) } label: {
                    Text(locale.displayName).font(.system(size:locale == .ary ? 11 : 10,weight:.bold))
                        .lineLimit(1).minimumScaleFactor(0.7).frame(minWidth:46,minHeight:36)
                        .padding(.horizontal,5)
                        .background(language == locale ? lime : Color(hex:0x252039),in:RoundedRectangle(cornerRadius:10))
                        .foregroundStyle(language == locale ? Color.black : Color.white)
                }
                .buttonStyle(.plain).accessibilityAddTraits(language == locale ? .isSelected : [])
            }
        }
    }
    private var campaignBar:some View {
        HStack(spacing:12) {
            VStack(alignment:.leading,spacing:2) {
                Text("\(t("campaign")) · \(run.currentLevel)/\(maximumLevel)").font(.system(size:10,weight:.heavy)).tracking(1.2).foregroundStyle(.secondary)
                Text(GameText.levelName(run.currentLevel,language)).font(.subheadline.bold())
            }
            Spacer()
            HStack(spacing:4) { ForEach(0..<maximumLevel,id:\.self) { i in Capsule().fill(i < run.currentLevel ? lime : Color(hex:0x39334F)).frame(width:10,height:6) } }
                .accessibilityLabel("\(t("level")) \(run.currentLevel) \(t("of")) \(maximumLevel)")
        }
    }
    private var hud:some View {
        HStack(spacing:18) {
            VStack(alignment:.leading,spacing:3) {
                Text(t("squad")).font(.system(size:10,weight:.heavy)).tracking(2).foregroundStyle(.secondary)
                Text("\(run.rescued.count)/3 \(t("friends"))\(run.currentLevel >= 3 ? " · \(t(run.hasKey ? "keyYes":"keyNo"))" : "")")
                    .font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.75)
            }
            Spacer()
            VStack(spacing:1) { Text(t("turns")).font(.system(size:10,weight:.heavy)).foregroundStyle(.secondary); Text("\(max(0,run.limit-run.turn))").font(.title2.bold().monospacedDigit()) }
            Button { model.pause() } label: { Image(systemName:"pause.fill").frame(width:42,height:42).background(Color(hex:0x222139),in:RoundedRectangle(cornerRadius:13)) }
                .accessibilityLabel(t("pause")).disabled(run.phase != .playing)
        }
    }
    private var board:some View {
        LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:5),count:5),spacing:5) {
            ForEach(0..<30,id:\.self) { i in cellView(Cell(i%5,i/5)) }
        }
        .padding(7).background(Color(hex:0x19182C),in:RoundedRectangle(cornerRadius:14))
        .aspectRatio(5/6,contentMode:.fit).environment(\.layoutDirection,.leftToRight)
        .accessibilityElement(children:.contain).accessibilityLabel(t("arena"))
    }
    private func cellView(_ cell:Cell)->some View {
        let player = cell == run.cell
        let friend = activeFriends.first { $0.cell == cell && !run.rescued.contains($0.id.rawValue) }
        let bots = GameEngine.bots(run.turn,level:run.currentLevel)
        let danger = GameEngine.bots(run.turn+1,level:run.currentLevel).contains(cell) || GameEngine.lasers(run.turn+1,level:run.currentLevel).contains(cell)
        let bot = bots.contains(cell), wall = GameEngine.walls(run.currentLevel).contains(cell)
        let laser = GameEngine.lasers(run.turn,level:run.currentLevel).contains(cell)
        let exit = cell == Cell(4,0), key = run.currentLevel >= 3 && !run.hasKey && cell == Cell(2,4)
        let reachable = GameEngine.canMove(run,to:cell,dash:dashArmed)
        return Button { model.move(to:cell,dash:dashArmed); dashArmed = false } label: {
            ZStack {
                RoundedRectangle(cornerRadius:9).fill(danger ? Color(hex:0x39263E) : Color(hex:0x24233B))
                RoundedRectangle(cornerRadius:9).stroke(reachable ? lime : wall ? Color(hex:0x746882) : Color(hex:0x35334E),lineWidth:reachable ? 2 : 1)
                if wall { Text("▧").font(.title2).foregroundStyle(Color(hex:0xA399B2)) }
                else if player { token(selected) }
                else if let friend { token(friend.id) }
                else if bot { Image(systemName:"desktopcomputer").font(.title2).foregroundStyle(Color(hex:0xF87597)) }
                else if key { Text("⚿").font(.title2.bold()).foregroundStyle(lime) }
                else if exit { Image(systemName:"arrow.up.right").font(.title2.bold()).foregroundStyle(run.rescued.count == 3 && (run.currentLevel < 3 || run.hasKey) ? lime : .gray) }
                else if laser { Image(systemName:"bolt.fill").font(.title2).foregroundStyle(Color(hex:0xFA657C)) }
                else if danger { Text("×").font(.title2).foregroundStyle(Color(hex:0xF68B99)) }
                if danger && !wall { Text("×").font(.caption.bold()).foregroundStyle(Color(hex:0xFF97AA)).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.topTrailing).padding(2) }
            }
            .aspectRatio(1,contentMode:.fit)
        }
        .buttonStyle(.plain).disabled(!reachable)
        .accessibilityLabel("\(t("column")) \(cell.x+1), \(t("row")) \(cell.y+1)\(player ? ", \(selected.name)" : "")\(friend.map{", \($0.name)"} ?? "")\(bot ? ", \(t("bot"))" : "")\(danger ? ", \(t("danger"))" : "")\(wall ? ", \(t("wall"))" : "")\(key ? ", \(t("key"))" : "")\(exit ? ", \(t("exit"))" : "")")
    }
    private func token(_ id:CharacterID)->some View {
        VStack(spacing:2) {
            Image(id.assetName).resizable().scaledToFill().frame(maxWidth:.infinity,maxHeight:.infinity).clipped()
            Text(id.name).font(.system(size:7,weight:.heavy)).lineLimit(1).minimumScaleFactor(0.55)
        }
        .foregroundStyle(Color(hex:0x17121B)).padding(3).background(Color(hex:id.color),in:RoundedRectangle(cornerRadius:8)).padding(3)
        .accessibilityHidden(true)
    }
    private var squad:some View {
        HStack(spacing:5) {
            ForEach(activeFriends,id:\.id) { friend in
                VStack(spacing:3) {
                    Image(friend.id.assetName).resizable().scaledToFill().frame(width:31,height:31).clipShape(RoundedRectangle(cornerRadius:9))
                    Text(friend.name).font(.caption.bold()).foregroundStyle(Color(hex:friend.color)).lineLimit(1).minimumScaleFactor(0.7)
                    Text(run.rescued.contains(friend.id.rawValue) ? t("saved") : t(friend.id.giftKey)).font(.system(size:9,weight:.medium)).foregroundStyle(run.rescued.contains(friend.id.rawValue) ? lime : .secondary).lineLimit(1).minimumScaleFactor(0.65)
                }.frame(maxWidth:.infinity).opacity(run.rescued.contains(friend.id.rawValue) ? 1 : 0.82)
            }
        }.padding(.vertical,2)
    }
    private var controls:some View {
        VStack(spacing:8) {
            HStack(spacing:16) {
                VStack(spacing:4) {
                    direction("arrow.up",dx:0,dy:-1,label:t("up"))
                    HStack(spacing:4) { direction("arrow.left",dx:-1,dy:0,label:t("left")); direction("arrow.down",dx:0,dy:1,label:t("down")); direction("arrow.right",dx:1,dy:0,label:t("right")) }
                }
                VStack(spacing:7) {
                    Button(dashArmed ? t("chooseDirection") : run.dash > 0 ? "\(t("dashReady")) · \(run.dash)" : t("dash")) { dashArmed.toggle() }
                        .font(.subheadline.bold()).padding(13).frame(maxWidth:.infinity).background(dashArmed ? lime : Color(hex:0xF16A32),in:RoundedRectangle(cornerRadius:12)).foregroundStyle(.black)
                        .disabled(run.phase != .playing || run.dash > 0).accessibilityValue(dashArmed ? t("on") : t("off"))
                    Text("\(t("shields")): \(run.shield)").font(.caption).foregroundStyle(.secondary)
                }
            }
            Button(t("wait")) { model.waitTurn(); dashArmed = false }.font(.caption.bold()).frame(maxWidth:.infinity,minHeight:38)
                .background(Color(hex:0x252039),in:RoundedRectangle(cornerRadius:10)).overlay(RoundedRectangle(cornerRadius:10).stroke(Color(hex:0x635777)))
                .disabled(run.phase != .playing)
        }
    }
    private func direction(_ symbol:String,dx:Int,dy:Int,label:String)->some View {
        Button { model.move(to:Cell(run.cell.x+dx*(dashArmed ? 2 : 1),run.cell.y+dy*(dashArmed ? 2 : 1)),dash:dashArmed); dashArmed = false } label: {
            Image(systemName:symbol).font(.title3).frame(width:43,height:43).background(Color(hex:0x2C2944),in:RoundedRectangle(cornerRadius:11))
        }.disabled(run.phase != .playing).accessibilityLabel(label)
    }
    private var dialog:some View {
        VStack(alignment:.leading,spacing:10) {
            Text(dialogEyebrow).font(.caption.bold()).tracking(1).foregroundStyle(.secondary)
            Text(dialogTitle).font(.title2.bold()).fixedSize(horizontal:false,vertical:true)
            if run.phase == .ready {
                VStack(spacing:7) {
                    HStack(spacing:4) {
                        ForEach(CharacterID.allCases) { id in
                            Button { model.chooseCharacter(id) } label: {
                                VStack(spacing:4) {
                                    Image(id.assetName).resizable().scaledToFill().frame(width:41,height:41).clipShape(RoundedRectangle(cornerRadius:12))
                                    Text(id.name).font(.system(size:9,weight:.bold)).lineLimit(1).minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth:.infinity,minHeight:66).padding(3)
                                .background(selected == id ? Color.white.opacity(0.10) : Color.clear,in:RoundedRectangle(cornerRadius:12))
                                .overlay(RoundedRectangle(cornerRadius:12).stroke(selected == id ? Color(hex:0xFFBD69) : .clear,lineWidth:1.5))
                            }.buttonStyle(.plain).accessibilityLabel("\(t("choose")): \(id.name)").accessibilityAddTraits(selected == id ? .isSelected : [])
                        }
                    }
                    Text(t("choose")).font(.caption.bold()).foregroundStyle(Color(hex:0xD8C9EF)).frame(maxWidth:.infinity)
                }
            }
            Text(dialogDetail).font(.subheadline).foregroundStyle(Color(hex:0xD4D1E6)).fixedSize(horizontal:false,vertical:true)
            if run.phase == .won {
                Text(String(repeating:"★",count:GameEngine.stars(run))+String(repeating:"☆",count:3-GameEngine.stars(run)))
                    .font(.title2.bold()).foregroundStyle(lime).accessibilityLabel("\(GameEngine.stars(run)) / 3")
                HStack { Text("\(GameEngine.points(run)) \(t("points"))"); Spacer(); Text("\(t("record")) \(model.save.best)") }.font(.caption.bold()).foregroundStyle(.secondary)
            }
            if run.phase == .won && [2,4,6].contains(run.currentLevel) {
                Image("logo-21").resizable().scaledToFit().frame(maxWidth:115,maxHeight:28).frame(maxWidth:.infinity)
                Text(t("milestones")).font(.system(size:9)).foregroundStyle(.secondary).frame(maxWidth:.infinity)
            }
            Button(action:primaryAction) {
                HStack { Text(primaryTitle).bold(); Spacer(); Image(systemName:"arrow.up.right") }
                    .padding(13).frame(maxWidth:.infinity).foregroundStyle(Color.black).background(lime,in:RoundedRectangle(cornerRadius:12))
            }.buttonStyle(.plain)
            if run.phase == .paused || run.phase == .won {
                Button(t("restart")) { model.resetLevel(); dashArmed = false }.font(.caption.bold()).frame(maxWidth:.infinity,minHeight:34).foregroundStyle(Color(hex:0xDDD8F0))
            }
        }
        .padding(16).frame(maxWidth:370).background(Color(hex:0x171629),in:RoundedRectangle(cornerRadius:20))
        .overlay(RoundedRectangle(cornerRadius:20).stroke(Color(hex:0x615679)))
    }
    private var dialogEyebrow:String {
        switch run.phase { case .ready:return "\(t("level")) \(run.currentLevel) · \(run.currentLevel < 3 ? t("hard") : run.currentLevel < 5 ? t("expert") : t("extreme"))"; case .paused:return t("paused"); case .won:return t("won"); case .lost:return t("lost"); case .playing:return "" }
    }
    private var dialogTitle:String {
        switch run.phase { case .ready:return t("ready"); case .paused:return t("yourMove"); case .won:return run.currentLevel == maximumLevel ? t("campaignWon") : t("arenaWon"); case .lost:return t("tryAgain"); case .playing:return "" }
    }
    private var dialogDetail:String {
        switch run.phase {
        case .ready: return "\(levelLimits[run.currentLevel-1]) \(t("turns")), \(GameEngine.bots(0,level:run.currentLevel).count) \(t("patrols"))\(run.currentLevel >= 3 ? ", \(t("keyRequired"))" : "")\(run.currentLevel >= 4 ? ", \(t("lasersEvery3"))" : ""). \(t("rescueAndExit"))"
        case .paused:return t("savedGame")
        case .won:return run.message
        case .lost:return run.message
        case .playing:return ""
        }
    }
    private var primaryTitle:String {
        if run.phase == .ready { return t("enter") }
        if run.phase == .paused { return t("resume") }
        if run.phase == .won && run.currentLevel < maximumLevel { return "\(t("next")) \(run.currentLevel+1)" }
        return t("retry")
    }
    private func primaryAction() {
        switch run.phase { case .ready:model.start(); case .paused:model.resume(); case .won where run.currentLevel < maximumLevel:model.nextLevel(); case .won,.lost:model.resetLevel(); model.start(); case .playing:break }
        dashArmed = false
    }
    private var rules:some View {
        NavigationStack {
            ScrollView { VStack(alignment:.leading,spacing:18) {
                Text(t("helpTitle")).font(.title.bold())
                Text(t("help"))
                Text(t("keyRule"))
                Text(t("fan")).font(.footnote).foregroundStyle(.secondary)
                Divider()
                Text(t("privacyTitle")).font(.headline)
                Text(t("privacy")).font(.footnote)
            }.padding(24) }
            .toolbar { ToolbarItem(placement:.confirmationAction) { Button(t("close")) { help = false } } }
        }.environment(\.layoutDirection,language == .ary ? .rightToLeft : .leftToRight)
    }
}
@main struct BougassaaaSquadApp:App { var body:some Scene { WindowGroup { GameView() } } }
