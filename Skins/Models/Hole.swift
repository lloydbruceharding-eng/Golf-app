//
//  Hole.swift
//  Skins
//
//  A hole carries a number and a par. No course database — par is editable.
//

import Foundation
import SwiftData

@Model
final class Hole {
    var number: Int
    var par: Int
    var round: Round?

    @Relationship(deleteRule: .cascade, inverse: \Score.hole)
    var scores: [Score]

    init(number: Int, par: Int = 4) {
        self.number = number
        self.par = par
        self.scores = []
    }

    /// True once every player in the round has entered a score on this hole.
    func isFullyScored(playerCount: Int) -> Bool {
        guard playerCount > 0 else { return false }
        return scores.filter { $0.strokes > 0 }.count == playerCount
    }
}
