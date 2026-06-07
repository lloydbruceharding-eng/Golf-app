//
//  Round.swift
//  Skins
//
//  A single round of golf played by a group of friends.
//

import Foundation
import SwiftData

@Model
final class Round {
    var name: String
    var joinCode: String
    var holeCount: Int
    var stakePerSkin: Double
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Player.round)
    var players: [Player]

    @Relationship(deleteRule: .cascade, inverse: \Hole.round)
    var holes: [Hole]

    init(
        name: String,
        joinCode: String,
        holeCount: Int,
        stakePerSkin: Double = 10,
        createdAt: Date = .now
    ) {
        self.name = name
        self.joinCode = joinCode
        self.holeCount = holeCount
        self.stakePerSkin = stakePerSkin
        self.createdAt = createdAt
        self.players = []
        self.holes = []
    }

    // MARK: - Convenience

    var sortedPlayers: [Player] {
        players.sorted { $0.createdAt < $1.createdAt }
    }

    var sortedHoles: [Hole] {
        holes.sorted { $0.number < $1.number }
    }

    var totalPar: Int {
        holes.reduce(0) { $0 + $1.par }
    }

    /// True when every player has entered a score on every hole.
    var isComplete: Bool {
        guard !players.isEmpty, !holes.isEmpty else { return false }
        for hole in holes {
            let entered = hole.scores.filter { $0.strokes > 0 }.count
            if entered < players.count { return false }
        }
        return true
    }
}

// MARK: - Join code generation

extension Round {
    /// Unambiguous characters only (no 0/O or 1/I) — easy to read aloud.
    static func generateJoinCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
