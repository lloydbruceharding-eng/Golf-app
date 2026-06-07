//
//  Score.swift
//  Skins
//
//  A single player's stroke count on a single hole. 0 means "not entered yet".
//

import Foundation
import SwiftData

@Model
final class Score {
    var strokes: Int
    var player: Player?
    var hole: Hole?

    init(strokes: Int = 0, player: Player? = nil, hole: Hole? = nil) {
        self.strokes = strokes
        self.player = player
        self.hole = hole
    }

    var isEntered: Bool { strokes > 0 }
}
