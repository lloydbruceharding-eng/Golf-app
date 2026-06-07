//
//  Player.swift
//  Skins
//
//  A player is just a name — no accounts, no phone numbers.
//

import Foundation
import SwiftData

@Model
final class Player {
    var name: String
    var createdAt: Date
    var round: Round?

    @Relationship(deleteRule: .cascade, inverse: \Score.player)
    var scores: [Score]

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
        self.scores = []
    }

    /// The score record for a given hole, if one exists.
    func score(forHole hole: Hole) -> Score? {
        scores.first { $0.hole?.persistentModelID == hole.persistentModelID }
    }

    /// Sum of strokes across holes that have been scored.
    var totalStrokes: Int {
        scores.reduce(0) { $0 + $1.strokes }
    }

    /// Score relative to par across holes the player has actually scored.
    var scoreToPar: Int {
        scores.reduce(0) { partial, score in
            guard score.strokes > 0, let par = score.hole?.par else { return partial }
            return partial + (score.strokes - par)
        }
    }

    /// Initials for compact avatars, e.g. "Lloyd Harding" -> "LH".
    var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }
        return letters.joined().uppercased()
    }
}
