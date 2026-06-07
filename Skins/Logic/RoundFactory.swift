//
//  RoundFactory.swift
//  Skins
//
//  Builds rounds, holes, players and the score grid, and keeps them consistent.
//

import Foundation
import SwiftData

enum RoundFactory {

    /// Create a fully-wired round: holes (default par 4), players, and a Score
    /// for every player/hole pairing so the scorecard grid is ready to tap.
    @discardableResult
    static func makeRound(
        name: String,
        holeCount: Int,
        playerNames: [String],
        stakePerSkin: Double,
        in context: ModelContext
    ) -> Round {
        let round = Round(
            name: name.isEmpty ? "Weekend Round" : name,
            joinCode: Round.generateJoinCode(),
            holeCount: holeCount,
            stakePerSkin: stakePerSkin
        )
        context.insert(round)

        for number in 1...holeCount {
            let hole = Hole(number: number, par: 4)
            hole.round = round
            round.holes.append(hole)
        }

        for name in playerNames {
            addPlayer(named: name, to: round, in: context)
        }

        return round
    }

    /// Add a player (simulating someone joining via the code) and create their
    /// score cells for every existing hole.
    @discardableResult
    static func addPlayer(named name: String, to round: Round, in context: ModelContext) -> Player {
        let player = Player(name: name)
        player.round = round
        context.insert(player)
        round.players.append(player)

        for hole in round.holes {
            let score = Score(strokes: 0, player: player, hole: hole)
            context.insert(score)
            player.scores.append(score)
            hole.scores.append(score)
        }
        return player
    }
}
