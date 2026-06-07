//
//  SkinsCalculator.swift
//  Skins
//
//  Pure skins logic: lowest UNIQUE score wins the hole's skin; ties carry over.
//

import Foundation
import SwiftData

/// One player's outcome for a round.
struct PlayerResult: Identifiable {
    let id: PersistentIdentifier
    let player: Player
    var skinsWon: Int
    /// Net cash: positive means they collect, negative means they owe.
    var net: Double
}

/// A single "X pays Y" transaction that settles the round.
struct Settlement: Identifiable {
    let id = UUID()
    let from: Player
    let to: Player
    let amount: Double
}

enum SkinsCalculator {

    /// Skins won and net cash per player.
    static func results(for round: Round) -> [PlayerResult] {
        let players = round.sortedPlayers
        guard !players.isEmpty else { return [] }

        var skins: [PersistentIdentifier: Int] = [:]
        for player in players { skins[player.persistentModelID] = 0 }

        var carry = 0
        for hole in round.sortedHoles {
            // Gather entered scores for this hole.
            var entries: [(id: PersistentIdentifier, strokes: Int)] = []
            for player in players {
                if let score = player.score(forHole: hole), score.strokes > 0 {
                    entries.append((player.persistentModelID, score.strokes))
                }
            }

            // Only settle a hole once everyone has a score on it.
            guard entries.count == players.count else { continue }

            let lowest = entries.map(\.strokes).min()!
            let winners = entries.filter { $0.strokes == lowest }

            if winners.count == 1 {
                // Unique low score takes this skin plus any carried over.
                skins[winners[0].id, default: 0] += 1 + carry
                carry = 0
            } else {
                // Tie — the skin carries to the next hole.
                carry += 1
            }
        }

        let totalSkins = skins.values.reduce(0, +)
        let playerCount = players.count
        let stake = round.stakePerSkin

        return players.map { player in
            let won = skins[player.persistentModelID] ?? 0
            // For every skin won, collect `stake` from each other player;
            // for every skin won by others, pay `stake`. Nets to zero overall.
            let net = stake * Double(won * playerCount - totalSkins)
            return PlayerResult(id: player.persistentModelID, player: player, skinsWon: won, net: net)
        }
    }

    /// Skins that have been played for but not yet awarded (still carrying).
    static func skinsOnTheTable(for round: Round) -> Int {
        let playerCount = round.players.count
        guard playerCount > 0 else { return 0 }
        let settledHoles = round.sortedHoles.filter { $0.isFullyScored(playerCount: playerCount) }.count
        let awarded = results(for: round).reduce(0) { $0 + $1.skinsWon }
        return max(0, settledHoles - awarded)
    }

    /// Greedy debtor/creditor matching so the group settles with the fewest payments.
    static func settlements(for round: Round) -> [Settlement] {
        let results = results(for: round)
        var creditors = results.filter { $0.net > 0.001 }
            .map { (player: $0.player, amount: $0.net) }
            .sorted { $0.amount > $1.amount }
        var debtors = results.filter { $0.net < -0.001 }
            .map { (player: $0.player, amount: -$0.net) }
            .sorted { $0.amount > $1.amount }

        var settlements: [Settlement] = []
        var d = 0
        var c = 0
        while d < debtors.count && c < creditors.count {
            let pay = min(debtors[d].amount, creditors[c].amount)
            settlements.append(
                Settlement(from: debtors[d].player, to: creditors[c].player, amount: pay)
            )
            debtors[d].amount -= pay
            creditors[c].amount -= pay
            if debtors[d].amount < 0.001 { d += 1 }
            if creditors[c].amount < 0.001 { c += 1 }
        }
        return settlements
    }
}
