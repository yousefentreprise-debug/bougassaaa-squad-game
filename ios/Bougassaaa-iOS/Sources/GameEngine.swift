import Foundation

public enum Phase: String, Codable { case ready, playing, paused, won, lost }
public enum CharacterID: String, CaseIterable, Codable, Identifiable {
    case bougassaaa, frira, bingo, seven = "7idan"
    public var id: String { rawValue }
    public var name: String { rawValue == "7idan" ? "7idan" : rawValue.prefix(1).uppercased() + String(rawValue.dropFirst()) }
    public var mark: String { self == .bougassaaa ? "BG" : self == .frira ? "F" : self == .bingo ? "B" : "7" }
    public var color: UInt { self == .bougassaaa ? 0xED5A25 : self == .frira ? 0xF5B84D : self == .bingo ? 0x9B8CFF : 0x59D9EF }
    public var giftKey: String { self == .frira || self == .bougassaaa ? "giftShield" : self == .bingo ? "giftTurns" : "giftDash" }
    public var cell: Cell { self == .bougassaaa ? Cell(4,4) : self == .frira ? Cell(0,3) : self == .bingo ? Cell(4,2) : Cell(0,0) }
    public var assetName: String { "avatar-\(rawValue)" }
}
public enum GameLanguage: String, CaseIterable, Codable, Identifiable {
    case it, ary, en, fr, es
    public var id: String { rawValue }
    public var displayName: String { self == .it ? "Italiano" : self == .ary ? "الدارجة" : self == .en ? "English" : self == .fr ? "Français" : "Español" }
}
public struct Cell: Equatable, Hashable, Codable {
    public var x: Int; public var y: Int
    public init(_ x: Int, _ y: Int) { self.x = x; self.y = y }
}
public struct SquadFriend {
    public let id: CharacterID
    public var name: String { id.name }
    public var cell: Cell { id.cell }
    public var mark: String { id.mark }
    public var color: UInt { id.color }
    public var gift: String { GameText.text(id.giftKey, .en) }
    public init(_ id: CharacterID) { self.id = id }
}
public let allCharacters: [SquadFriend] = CharacterID.allCases.map(SquadFriend.init)
public let levelLimits = [17,16,14,13,12,14]
public let maximumLevel = 6

public struct Run: Codable, Equatable {
    public var phase: Phase = .ready
    public var cell = Cell(2,5)
    public var turn = 0
    public var limit = 17
    public var rescued: [String] = []
    public var shield = 1
    public var dash = 0
    public var hits = 0
    public var message = "Rescue all three friends and reach the exit."
    // Optional fields preserve older UserDefaults saves when decoded by this version.
    public var level: Int? = 1
    public var keyCollected: Bool? = false
    public var character: CharacterID? = .bougassaaa
    public var currentLevel: Int { min(maximumLevel, max(1, level ?? 1)) }
    public var hasKey: Bool { keyCollected ?? false }
    public var selectedCharacter: CharacterID { character ?? .bougassaaa }
    public init() {}
}
public struct SaveData: Codable {
    public var run = Run()
    public var best = 0
    public var played = 0
    public var wins = 0
    public var language: GameLanguage? = .it
    public init() {}
}
public enum GameText {
    private static let values: [GameLanguage: [String:String]] = [
        .it: ["language":"Lingua","arena":"Arena tattica","squad":"SQUADRA","turns":"TURNI","friends":"amici","pause":"Pausa","ready":"La squadra è pronta!","choose":"Scegli il tuo personaggio","enter":"Entra in arena","resume":"Riprendi","restart":"Ricomincia questo livello","next":"Sblocca livello","paused":"IN PAUSA","yourMove":"Il piano è tuo.","won":"LIVELLO SUPERATO","lost":"RIPROVIAMO?","campaignWon":"Campagna completata. Sei una leggenda della squadra!","arenaWon":"Livello superato. La prossima arena alza la posta tattica.","intro":"Sei arene consecutive, sempre più strette. Bot e laser colpiscono dopo ogni passo: × mostra il prossimo pericolo, anche sulle caselle degli amici. Un impatto consuma uno scudo; senza scudi perdi. Attendere fa passare un turno. Lo scatto salta due caselle in linea, non attraversa i muri e si ricarica in quattro turni.","rules":"Regole e difficoltà","close":"Chiudi","wait":"Attendi un turno","up":"Su","down":"Giù","left":"Sinistra","right":"Destra","dash":"Scatto ×2","chooseDirection":"Scegli direzione","shields":"Scudi","saved":"SALVATO","giftShield":"Scudo +1","giftTurns":"3 turni extra","giftDash":"Scatto ricaricato","keyYes":"chiave sì","keyNo":"chiave no","keyMessage":"Chiave raccolta. L’uscita si apre con tutta la squadra.","impact":"Impatto! Uno scudo consumato.","intercepted":"Intercettato. Osserva le × e cambia percorso.","timeout":"Tempo esaurito. Usa lo scatto e pianifica i bonus.","joined":"nella squadra!","fan":"Fan game non ufficiale · nessuna affiliazione","privacyTitle":"Privacy","privacy":"Questa versione standalone salva partite e record soltanto sul dispositivo. Non include account, pubblicità, analisi, rete o tracciamento. Disinstallando l’app i dati locali vengono rimossi; i backup dipendono dalle impostazioni Apple.","helpTitle":"Salva la squadra","help":"Tocca una casella vicina o usa le frecce. × indica la prossima posizione di un bot. Lo scatto salta due caselle in linea retta e si ricarica dopo quattro mosse. Gli amici danno bonus. Salvali tutti e raggiungi ↗ prima che finiscano i turni.","milestones":"Grafica fan del traguardo · nessuna affiliazione","record":"Record","points":"punti","keyRule":"Dal livello 3 raccogli la chiave al centro. Dal livello 4 i laser centrali si attivano ogni tre turni. Salva tutti e raggiungi ↗. Tre stelle senza impatti, due con uno, una con due o più.","rescuedCount":"squadra","campaign":"CAMPAGNA","level":"LIVELLO","of":"di","hard":"DIFFICILE","expert":"ESPERTO","extreme":"ESTREMO","patrols":"pattuglie","keyRequired":"chiave obbligatoria","lasersEvery3":"laser ogni 3 turni","rescueAndExit":"Salva tutti e raggiungi ↗","savedGame":"La partita è salvata. Riprendi o ricomincia questo livello con le regole attuali.","retry":"Riprova","tryAgain":"Serve un altro piano.","dangerHint":"× = pericolo al prossimo turno. Pianifica prima di muoverti.","dashReady":"Scatto","on":"Attivo","off":"Disattivo","column":"Colonna","row":"riga","bot":"bot","danger":"pericolo prossimo turno","wall":"muro","key":"chiave","exit":"uscita","rescueHint":"Salva i tre amici e raggiungi l’uscita."],
        .en: ["language":"Language","arena":"Tactical arena","squad":"SQUAD","turns":"TURNS","friends":"friends","pause":"Pause","ready":"The squad is ready!","choose":"Choose your character","enter":"Enter arena","resume":"Resume","restart":"Restart this level","next":"Unlock level","paused":"PAUSED","yourMove":"Your move.","won":"LEVEL CLEARED","lost":"TRY AGAIN?","campaignWon":"Campaign complete. You are a squad legend!","arenaWon":"Level cleared. The next arena demands more tactics.","intro":"Six increasingly tight arenas. Bots and lasers strike after every step: × marks the next danger, even on friends’ cells. A hit uses one shield; with no shields you lose. Waiting costs a turn. Dash moves two cells straight, cannot cross walls and recharges in four turns.","rules":"Rules & difficulty","close":"Close","wait":"Wait one turn","up":"Up","down":"Down","left":"Left","right":"Right","dash":"Dash ×2","chooseDirection":"Choose direction","shields":"Shields","saved":"RESCUED","giftShield":"Shield +1","giftTurns":"3 extra turns","giftDash":"Dash recharged","keyYes":"key collected","keyNo":"key needed","keyMessage":"Key collected. The exit opens with the whole squad.","impact":"Hit! One shield used.","intercepted":"Intercepted. Watch the × marks and change your route.","timeout":"Out of turns. Use your dash and plan the bonuses.","joined":"joined the squad!","fan":"Unofficial fan game · no affiliation","privacyTitle":"Privacy","privacy":"This standalone version stores game progress and records only on this device. It has no account, advertising, analytics, network access or tracking. Uninstalling removes local data; device backups follow Apple settings.","helpTitle":"Rescue the squad","help":"Tap a nearby square or use the arrows. × marks the bot’s next position. Dash jumps two cells in a straight line and recharges after four moves. Friends grant bonuses. Rescue all three, then reach ↗ before turns run out.","milestones":"Milestone fan graphic · no affiliation","record":"Best","points":"points","keyRule":"From level 3, collect the central key. From level 4, central lasers fire every three turns. Save everyone, then reach ↗. Three stars for no hits, two for one, one for two or more.","rescuedCount":"squad","campaign":"CAMPAIGN","level":"LEVEL","of":"of","hard":"HARD","expert":"EXPERT","extreme":"EXTREME","patrols":"patrols","keyRequired":"key required","lasersEvery3":"lasers every 3 turns","rescueAndExit":"Rescue everyone and reach ↗","savedGame":"Your game is saved. Resume or restart this level with the current rules.","retry":"Try again","tryAgain":"The squad needs another plan.","dangerHint":"× = danger next turn. Plan before moving.","dashReady":"Dash","on":"On","off":"Off","column":"Column","row":"row","bot":"bot","danger":"next-turn danger","wall":"wall","key":"key","exit":"exit","rescueHint":"Rescue all three friends and reach the exit."] ,
        .fr: ["language":"Langue","arena":"Arène tactique","squad":"ÉQUIPE","turns":"TOURS","friends":"amis","pause":"Pause","ready":"L’équipe est prête !","choose":"Choisis ton personnage","enter":"Entrer dans l’arène","resume":"Reprendre","restart":"Recommencer ce niveau","next":"Débloquer le niveau","paused":"EN PAUSE","yourMove":"À toi de jouer.","won":"NIVEAU RÉUSSI","lost":"ON RÉESSAIE ?","campaignWon":"Campagne terminée. Tu es une légende de l’équipe !","arenaWon":"Niveau réussi. La prochaine arène demande plus de tactique.","intro":"Six arènes de plus en plus serrées. Les bots et les lasers frappent après chaque pas : × indique le prochain danger, même sur les cases des amis. Un impact consomme un bouclier ; sans bouclier, tu perds. Attendre coûte un tour. Le sprint avance de deux cases en ligne droite, ne traverse pas les murs et se recharge en quatre tours.","rules":"Règles et difficulté","close":"Fermer","wait":"Attendre un tour","up":"Haut","down":"Bas","left":"Gauche","right":"Droite","dash":"Sprint ×2","chooseDirection":"Choisir une direction","shields":"Boucliers","saved":"SAUVÉ","giftShield":"Bouclier +1","giftTurns":"3 tours en plus","giftDash":"Sprint rechargé","keyYes":"clé récupérée","keyNo":"clé requise","keyMessage":"Clé récupérée. La sortie s’ouvre avec toute l’équipe.","impact":"Touché ! Un bouclier consommé.","intercepted":"Intercepté. Observe les × et change de chemin.","timeout":"Plus de tours. Utilise le sprint et prévois les bonus.","joined":"a rejoint l’équipe !","fan":"Jeu de fans non officiel · sans affiliation","privacyTitle":"Confidentialité","privacy":"Cette version autonome conserve la partie et les records uniquement sur cet appareil. Aucun compte, publicité, analytique, réseau ou suivi. La désinstallation supprime les données locales ; les sauvegardes dépendent des réglages Apple.","helpTitle":"Sauve l’équipe","help":"Touche une case voisine ou utilise les flèches. × indique la prochaine position d’un bot. Le sprint avance de deux cases en ligne droite et se recharge après quatre déplacements. Les amis donnent des bonus. Sauve-les tous, puis rejoins ↗ avant la fin des tours.","milestones":"Visuel fan du palier · sans affiliation","record":"Record","points":"points","keyRule":"Dès le niveau 3, récupère la clé centrale. Dès le niveau 4, les lasers centraux s’activent tous les trois tours. Sauve tout le monde, puis rejoins ↗. Trois étoiles sans impact, deux avec un, une avec deux ou plus.","rescuedCount":"équipe","campaign":"CAMPAGNE","level":"NIVEAU","of":"sur","hard":"DIFFICILE","expert":"EXPERT","extreme":"EXTRÊME","patrols":"patrouilles","keyRequired":"clé obligatoire","lasersEvery3":"lasers tous les 3 tours","rescueAndExit":"Sauve tout le monde et rejoins ↗","savedGame":"Ta partie est sauvegardée. Reprends ou recommence ce niveau avec les règles actuelles.","retry":"Réessayer","tryAgain":"L’équipe a besoin d’un autre plan.","dangerHint":"× = danger au prochain tour. Prévois ton déplacement.","dashReady":"Sprint","on":"Activé","off":"Désactivé","column":"Colonne","row":"ligne","bot":"bot","danger":"danger au prochain tour","wall":"mur","key":"clé","exit":"sortie","rescueHint":"Sauve les trois amis et rejoins la sortie."] ,
        .es: ["language":"Idioma","arena":"Arena táctica","squad":"EQUIPO","turns":"TURNOS","friends":"amigos","pause":"Pausa","ready":"¡El equipo está listo!","choose":"Elige tu personaje","enter":"Entrar en la arena","resume":"Continuar","restart":"Reiniciar este nivel","next":"Desbloquear nivel","paused":"EN PAUSA","yourMove":"Tú decides.","won":"NIVEL SUPERADO","lost":"¿OTRA VEZ?","campaignWon":"Campaña completada. ¡Eres una leyenda del equipo!","arenaWon":"Nivel superado. La próxima arena exige más táctica.","intro":"Seis arenas cada vez más estrechas. Bots y láseres golpean tras cada paso: × marca el siguiente peligro, incluso sobre amigos. Un impacto consume un escudo; sin escudos pierdes. Esperar cuesta un turno. El impulso avanza dos casillas rectas, no atraviesa muros y se recarga en cuatro turnos.","rules":"Reglas y dificultad","close":"Cerrar","wait":"Esperar un turno","up":"Arriba","down":"Abajo","left":"Izquierda","right":"Derecha","dash":"Impulso ×2","chooseDirection":"Elige dirección","shields":"Escudos","saved":"RESCATADO","giftShield":"Escudo +1","giftTurns":"3 turnos extra","giftDash":"Impulso recargado","keyYes":"llave recogida","keyNo":"falta la llave","keyMessage":"Llave recogida. La salida se abre con todo el equipo.","impact":"¡Impacto! Un escudo usado.","intercepted":"Interceptado. Mira las × y cambia de ruta.","timeout":"Sin turnos. Usa el impulso y planifica los bonus.","joined":"se unió al equipo.","fan":"Juego de fans no oficial · sin afiliación","privacyTitle":"Privacidad","privacy":"Esta versión independiente guarda la partida y los récords solo en este dispositivo. No tiene cuenta, anuncios, analítica, red ni seguimiento. Al desinstalarla se borran los datos locales; las copias dependen de los ajustes de Apple.","helpTitle":"Rescata al equipo","help":"Toca una casilla cercana o usa las flechas. × marca la próxima posición de un bot. El impulso salta dos casillas en línea recta y se recarga tras cuatro movimientos. Los amigos dan bonus. Rescátalos a todos y llega a ↗ antes de que se agoten los turnos.","milestones":"Gráfico fan del hito · sin afiliación","record":"Récord","points":"puntos","keyRule":"Desde el nivel 3, recoge la llave central. Desde el 4, los láseres centrales se activan cada tres turnos. Rescata a todos y llega a ↗. Tres estrellas sin impactos, dos con uno, una con dos o más.","rescuedCount":"equipo","campaign":"CAMPAÑA","level":"NIVEL","of":"de","hard":"DIFÍCIL","expert":"EXPERTO","extreme":"EXTREMO","patrols":"patrullas","keyRequired":"llave obligatoria","lasersEvery3":"láseres cada 3 turnos","rescueAndExit":"Rescata a todos y llega a ↗","savedGame":"Tu partida está guardada. Continúa o reinicia este nivel con las reglas actuales.","retry":"Reintentar","tryAgain":"El equipo necesita otro plan.","dangerHint":"× = peligro en el próximo turno. Planea antes de moverte.","dashReady":"Impulso","on":"Activado","off":"Desactivado","column":"Columna","row":"fila","bot":"bot","danger":"peligro próximo turno","wall":"muro","key":"llave","exit":"salida","rescueHint":"Rescata a los tres amigos y llega a la salida."] ,
        .ary: ["language":"اللغة","arena":"الساحة التكتيكية","squad":"الفريق","turns":"الأدوار","friends":"صحاب","pause":"وقّف","ready":"الفريق واجد!","choose":"اختار الشخصية ديالك","enter":"دخل للساحة","resume":"كمّل","restart":"عاود المستوى","next":"حلّ المستوى","paused":"موقّف","yourMove":"الخطة ديالك.","won":"دوزتي المستوى","lost":"نعاودو؟","campaignWon":"كمّلتي الحملة. نتا أسطورة الفريق!","arenaWon":"دوزتي المستوى. الساحة الجاية خاصّها تخطيط أكثر.","intro":"ستّة ساحات كيزيدو يصعابو. الروبوتات والليزر كيضربو من بعد كل خطوة: × كيبين الخطر الجاي حتى فخانات صحابك. الضربة كتاكل درع؛ بلا دروع كتخسر. التسنّية كتدوز دور. الاندفاع كينقز جوج خانات فخط مستقيم، ما كيدوزش الحيطان وكيرجع واجد فربعة أدوار.","rules":"القواعد والصعوبة","close":"سدّ","wait":"تسنّى دور","up":"الفوق","down":"التحت","left":"اليسر","right":"اليمين","dash":"اندفاع ×2","chooseDirection":"ختار الاتجاه","shields":"الدروع","saved":"تنقذ","giftShield":"درع +1","giftTurns":"3 أدوار زايدة","giftDash":"الاندفاع واجد","keyYes":"المفتاح واجد","keyNo":"خاصّ المفتاح","keyMessage":"خديتي المفتاح. الخرجة كتحل ملي تجمع الفريق كامل.","impact":"ضربة! مشا درع واحد.","intercepted":"شدّوك. شوف علامات × وبدّل الطريق.","timeout":"سالا الوقت. استعمل الاندفاع وخطّط للبونيسات.","joined":"دخل للفريق!","fan":"لعبة ديال الفانز، ماشي رسمية · بلا ارتباط","privacyTitle":"الخصوصية","privacy":"هاد النسخة كتحفظ اللعبة والريكورد غير فهاد الجهاز. ما فيهاش حساب ولا إعلانات ولا تحليلات ولا شبكة ولا تتبّع. إلا مسحتي التطبيق كتمشي البيانات المحلية؛ النسخ الاحتياطية كتخضع لإعدادات Apple.","helpTitle":"نقذ الفريق","help":"لمس خانة قريبة ولا استعمل السهام. × كيبين فين غادي يمشي الروبوت فالدور الجاي. الاندفاع كينقز جوج خانات بخط مستقيم وكيرجع واجد من بعد ربعة ديال الحركات. صحابك كيعطيوك بونيسات. نقذهم كاملين ووصل لـ ↗ قبل ما يسالي الوقت.","milestones":"رسم ديال الفانز · بلا ارتباط","record":"الريكورد","points":"نقطة","keyRule":"من المستوى 3 جمع المفتاح فالوسط. من المستوى 4 الليزر ديال الوسط كيخدم كل ثلاثة أدوار. نقذ الجميع ووصل لـ ↗. ثلاثة نجوم بلا ضربات، جوج بضربة، وحدة بجوج ولا كثر.","rescuedCount":"الفريق","campaign":"الحملة","level":"المستوى","of":"من","hard":"صعيب","expert":"خبير","extreme":"صعيب بزاف","patrols":"دوريات","keyRequired":"خاصّ المفتاح","lasersEvery3":"الليزر كل ثلاثة أدوار","rescueAndExit":"نقذ الجميع ووصل لـ ↗","savedGame":"اللعبة محفوظة. كمّل ولا عاود هاد المستوى بالقواعد الحالية.","retry":"عاود","tryAgain":"الفريق خاصّو خطة أخرى.","dangerHint":"× = الخطر فالدور الجاي. خطّط قبل ما تتحرّك.","dashReady":"الاندفاع","on":"مفعّل","off":"موقوف","column":"العمود","row":"السطر","bot":"روبوت","danger":"الخطر فالدور الجاي","wall":"حيط","key":"مفتاح","exit":"الخرجة","rescueHint":"نقذ صحابك الثلاثة ووصل للخرجة."]
    ]
    public static func text(_ key: String, _ language: GameLanguage) -> String { values[language]?[key] ?? values[.en]?[key] ?? key }
    public static func levelName(_ level: Int, _ language: GameLanguage) -> String {
        let names: [GameLanguage:[String]] = [
            .it:["Infiltrazione","Corridoi stretti","Codice di fuga","Incrocio di pattuglie","Allarme rosso","Ultima estrazione"],
            .en:["Infiltration","Tight corridors","Escape code","Patrol crossing","Red alert","Final extraction"],
            .fr:["Infiltration","Couloirs étroits","Code de fuite","Croisée des patrouilles","Alerte rouge","Dernière extraction"],
            .es:["Infiltración","Pasillos estrechos","Código de escape","Cruce de patrullas","Alerta roja","Extracción final"],
            .ary:["تسلّل","ممرّات ضيّقة","كود الهروب","تقاطع الدوريات","إنذار حمر","آخر إنقاذ"]
        ]
        return names[language]?[max(0,min(maximumLevel-1,level-1))] ?? "Level \(level)"
    }
}
public enum GameEngine {
    public static func friends(for character: CharacterID) -> [SquadFriend] { allCharacters.filter { $0.id != character } }
    private static func positiveMod(_ value: Int, _ modulus: Int) -> Int { ((value % modulus) + modulus) % modulus }
    public static func walls(_ level: Int) -> [Cell] {
        if level < 2 { return [] }
        var cells = level < 4 ? [Cell(2,2),Cell(2,3)] : [Cell(2,2),Cell(2,3),Cell(1,1),Cell(3,4)]
        if level == 6 { cells.append(Cell(1,4)) }
        return cells
    }
    public static func bots(_ turn: Int, level: Int) -> [Cell] {
        let speed = level >= 5 ? 2 : 1, offset = level - 1
        var result = [Cell(positiveMod(2 + turn * speed + offset,5),1), Cell(positiveMod(4 - turn * speed + offset,5),4)]
        if level >= 3 { result.append(Cell(3,positiveMod(turn + offset,6))) }
        if level >= 5 { result.append(Cell(1,positiveMod(5 - turn + offset,6))) }
        if level == 6 { result.append(Cell(positiveMod(turn * 2,5),3)) }
        return result
    }
    public static func lasers(_ turn: Int, level: Int) -> [Cell] {
        level >= 4 && turn % 3 == 0 ? [Cell(2,0),Cell(2,1),Cell(2,4),Cell(2,5)] : []
    }
    public static func freshRun(level: Int = 1, character: CharacterID = .bougassaaa, language: GameLanguage = .it) -> Run {
        let safeLevel = min(maximumLevel,max(1,level))
        var r = Run(); r.phase = .ready; r.cell = Cell(2,5); r.turn = 0; r.limit = levelLimits[safeLevel-1]
        r.rescued = []; r.shield = 1; r.dash = 0; r.hits = 0; r.level = safeLevel; r.keyCollected = false; r.character = character
        r.message = GameText.text(safeLevel >= 3 ? "keyRule" : "rescueHint", language)
        return r
    }
    public static func canMove(_ r: Run, to cell: Cell, dash: Bool) -> Bool {
        guard r.phase == .playing, (0..<5).contains(cell.x), (0..<6).contains(cell.y) else { return false }
        let distance = abs(cell.x-r.cell.x) + abs(cell.y-r.cell.y)
        guard distance == (dash ? 2 : 1), !dash || (r.dash == 0 && (cell.x == r.cell.x || cell.y == r.cell.y)) else { return false }
        let blockers = walls(r.currentLevel)
        if blockers.contains(cell) { return false }
        if dash && blockers.contains(Cell((cell.x+r.cell.x)/2,(cell.y+r.cell.y)/2)) { return false }
        return true
    }
    public static func advance(_ original: Run, to cell: Cell, dash: Bool, language: GameLanguage = .en) -> Run {
        guard canMove(original,to:cell,dash:dash) else { return original }
        var n = original; let level = original.currentLevel; let player = original.selectedCharacter
        n.cell = cell; n.level = level; n.keyCollected = original.hasKey; n.character = player
        n.turn += 1; n.rescued = original.rescued; n.dash = dash ? 4 : max(0,original.dash-1); n.message = ""
        if let rescued = friends(for:player).first(where: { $0.cell == cell && !n.rescued.contains($0.id.rawValue) }) {
            n.rescued.append(rescued.id.rawValue)
            n.message = "\(rescued.name) \(GameText.text("joined",language)) \(GameText.text(rescued.id.giftKey,language))."
            if rescued.id == .frira || rescued.id == .bougassaaa { n.shield += 1 }
            if rescued.id == .bingo { n.limit += 3 }
            if rescued.id == .seven { n.dash = 0 }
        }
        if level >= 3 && cell == Cell(2,4) && !n.hasKey { n.keyCollected = true; n.message = GameText.text("keyMessage",language) }
        let hit = bots(n.turn,level:level).contains(cell) || lasers(n.turn,level:level).contains(cell)
        if hit {
            n.hits += 1
            if n.shield > 0 { n.shield -= 1; n.message = GameText.text("impact",language) }
            else { n.phase = .lost; n.message = GameText.text("intercepted",language) }
        }
        if n.phase == .playing && cell == Cell(4,0) && n.rescued.count == 3 && (level < 3 || n.hasKey) {
            n.phase = .won; n.message = GameText.text(level == maximumLevel ? "campaignWon" : "arenaWon",language)
        } else if n.phase == .playing && n.turn >= n.limit { n.phase = .lost; n.message = GameText.text("timeout",language) }
        return n
    }
    public static func waitTurn(_ original: Run, language: GameLanguage = .en) -> Run {
        guard original.phase == .playing else { return original }
        var n = original; let level = original.currentLevel
        n.turn += 1; n.dash = max(0,n.dash-1); n.message = ""
        if bots(n.turn,level:level).contains(n.cell) || lasers(n.turn,level:level).contains(n.cell) {
            n.hits += 1
            if n.shield > 0 { n.shield -= 1; n.message = GameText.text("impact",language) }
            else { n.phase = .lost; n.message = GameText.text("intercepted",language) }
        }
        if n.phase == .playing && n.turn >= n.limit { n.phase = .lost; n.message = GameText.text("timeout",language) }
        return n
    }
    public static func points(_ r: Run) -> Int { r.rescued.count * 100 + max(0,r.limit-r.turn) * 20 + (r.phase == .won ? 500 + r.currentLevel * 100 : 0) }
    public static func stars(_ r: Run) -> Int { r.phase == .won ? max(1,3-min(2,r.hits)) : 0 }
}
