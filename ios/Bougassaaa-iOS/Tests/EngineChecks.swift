import Foundation

@main struct EngineChecks {
    static func main() {
        var ready = GameEngine.freshRun()
        assert(GameEngine.advance(ready,to:Cell(2,4),dash:false) == ready,"Ready cannot move")
        ready.phase = .playing
        assert(GameEngine.advance(ready,to:Cell(-1,5),dash:false) == ready,"Bounds")
        assert(GameEngine.advance(ready,to:Cell(3,4),dash:false) == ready,"No diagonal steps")

        let dash = GameEngine.advance(ready,to:Cell(2,3),dash:true)
        assert(dash.turn == 1 && dash.dash == 4 && dash.cell == Cell(2,3),"Dash move and cooldown")
        assert(GameEngine.advance(dash,to:Cell(2,1),dash:true) == dash,"Dash cooldown")
        var levelTwo = GameEngine.freshRun(level:2); levelTwo.phase = .playing; levelTwo.cell = Cell(2,4)
        assert(!GameEngine.canMove(levelTwo,to:Cell(2,2),dash:true),"Dash cannot cross a wall")

        var frira = GameEngine.freshRun(character:.bougassaaa); frira.phase = .playing; frira.cell = Cell(0,4)
        frira = GameEngine.advance(frira,to:Cell(0,3),dash:false)
        assert(frira.rescued == ["frira"] && frira.shield == 2,"Frira gives one shield")
        var bingo = GameEngine.freshRun(); bingo.phase = .playing; bingo.cell = Cell(4,3)
        bingo = GameEngine.advance(bingo,to:Cell(4,2),dash:false)
        assert(bingo.limit == 20 && bingo.rescued == ["bingo"],"Bingo grants three extra turns")
        var seven = GameEngine.freshRun(); seven.phase = .playing; seven.cell = Cell(0,1); seven.dash = 2
        seven = GameEngine.advance(seven,to:Cell(0,0),dash:false)
        assert(seven.dash == 0 && seven.rescued == ["7idan"],"7idan recharges dash")

        var chooseFrira = GameEngine.freshRun(character:.frira); chooseFrira.phase = .playing; chooseFrira.cell = Cell(1,3)
        chooseFrira = GameEngine.advance(chooseFrira,to:Cell(0,3),dash:false)
        assert(chooseFrira.rescued.isEmpty,"The selected character is not a rescue target")
        assert(GameEngine.friends(for:.frira).count == 3 && !GameEngine.friends(for:.frira).contains(where:{$0.id == .frira}),"Three other squad members remain to rescue")
        var recruitBingo = GameEngine.freshRun(character:.frira); recruitBingo.phase = .playing; recruitBingo.cell = Cell(3,2)
        recruitBingo = GameEngine.advance(recruitBingo,to:Cell(4,2),dash:false)
        assert(recruitBingo.rescued == ["bingo"] && recruitBingo.limit == 20,"Other selectable characters remain rescuable")

        var hit = GameEngine.freshRun(); hit.phase = .playing; hit.cell = Cell(3,2)
        hit = GameEngine.advance(hit,to:Cell(3,1),dash:false)
        assert(hit.hits == 1 && hit.shield == 0 && hit.phase == .playing,"Bot collision consumes shield")
        var lost = GameEngine.freshRun(); lost.phase = .playing; lost.cell = Cell(3,2); lost.shield = 0
        lost = GameEngine.advance(lost,to:Cell(3,1),dash:false)
        assert(lost.phase == .lost,"Collision without shield loses")
        var timed = GameEngine.freshRun(); timed.phase = .playing; timed.turn = 16; timed.cell = Cell(2,5)
        timed = GameEngine.advance(timed,to:Cell(1,5),dash:false)
        assert(timed.phase == .lost,"Turn limit")

        assert(GameEngine.bots(0,level:1).count == 2 && GameEngine.bots(0,level:3).count == 3 && GameEngine.bots(0,level:5).count == 4 && GameEngine.bots(0,level:6).count == 5,"Level patrol counts")
        assert(GameEngine.walls(1).isEmpty && GameEngine.walls(2).count == 2 && GameEngine.walls(4).count == 4 && GameEngine.walls(6).count == 5,"Level wall layouts")
        assert(GameEngine.lasers(3,level:4).count == 4 && GameEngine.lasers(4,level:4).isEmpty,"Lasers fire every third turn from level four")
        var laserHit = GameEngine.freshRun(level:4); laserHit.phase = .playing; laserHit.cell = Cell(1,0); laserHit.turn = 2
        laserHit = GameEngine.advance(laserHit,to:Cell(2,0),dash:false)
        assert(laserHit.hits == 1 && laserHit.shield == 0,"Laser collision consumes shield")

        var locked = GameEngine.freshRun(level:3); locked.phase = .playing; locked.cell = Cell(3,0); locked.rescued = ["frira","bingo","7idan"]
        locked = GameEngine.advance(locked,to:Cell(4,0),dash:false)
        assert(locked.phase == .playing,"Level three exit requires key")
        var unlocked = GameEngine.freshRun(level:3); unlocked.phase = .playing; unlocked.cell = Cell(3,0); unlocked.rescued = ["frira","bingo","7idan"]; unlocked.keyCollected = true
        unlocked = GameEngine.advance(unlocked,to:Cell(4,0),dash:false)
        assert(unlocked.phase == .won && GameEngine.points(unlocked) == 1360 && GameEngine.stars(unlocked) == 3,"Key unlocks exit and score/stars are calculated")

        var waiting = GameEngine.freshRun(); waiting.phase = .playing
        let waited = GameEngine.waitTurn(waiting)
        assert(waited.turn == 1 && waited.cell == waiting.cell,"Waiting consumes one turn in place")
        assert(GameText.text("language",.it) == "Lingua" && GameText.text("language",.ary) == "اللغة" && GameText.text("language",.fr) == "Langue" && GameText.text("language",.es) == "Idioma","All five app languages resolve")

        let legacyRun = #"{"phase":"paused","cell":{"x":3,"y":5},"turn":1,"limit":24,"rescued":[],"shield":1,"dash":0,"hits":0,"message":""}"#.data(using:.utf8)!
        let restored = try! JSONDecoder().decode(Run.self,from:legacyRun)
        assert(restored.currentLevel == 1 && restored.selectedCharacter == .bougassaaa && !restored.hasKey && restored.cell == Cell(3,5),"Old saved runs decode without losing progress")
        let data = try! JSONEncoder().encode(unlocked)
        assert(try! JSONDecoder().decode(Run.self,from:data) == unlocked,"New run Codable round-trip")
        print("PASS: selection, rescue roles, six levels, hazards, key gate, scoring, localization and old-save migration")
    }
}
