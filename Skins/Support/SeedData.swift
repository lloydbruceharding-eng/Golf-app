//
//  SeedData.swift
//  Skins
//
//  A sample round so the app opens populated and ready to test.
//

import Foundation
import SwiftData

enum SeedData {

    static func populateIfNeeded(_ context: ModelContext) {
        let descriptor = FetchDescriptor<Round>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let round = RoundFactory.makeRound(
            name: "Sunday Fourball",
            holeCount: 9,
            playerNames: ["Lloyd", "Sipho", "James", "Thandi"],
            stakePerSkin: 10,
            in: context
        )

        // A varied set of pars for a more realistic front nine.
        let pars = [4, 3, 5, 4, 4, 3, 5, 4, 4]
        for hole in round.sortedHoles where hole.number <= pars.count {
            hole.par = pars[hole.number - 1]
        }

        // Pre-fill scores for the first 7 holes to demonstrate skins + carry-overs.
        // Rows: Lloyd, Sipho, James, Thandi
        let scripted: [[Int]] = [
            [4, 5, 6, 5], // H1 par4 -> Lloyd unique low: skin
            [3, 3, 4, 4], // H2 par3 -> tie at 3: carry
            [5, 6, 5, 7], // H3 par5 -> tie at 5: carry (now 2 on table)
            [4, 4, 4, 3], // H4 par4 -> Thandi unique low: takes 1 + 2 carried = 3 skins
            [5, 4, 5, 5], // H5 par4 -> Sipho unique low: skin
            [2, 3, 4, 3], // H6 par3 -> Lloyd unique low: skin
            [6, 5, 5, 6], // H7 par5 -> tie at 5: carry
        ]

        let players = round.sortedPlayers
        for (holeIndex, row) in scripted.enumerated() {
            guard holeIndex < round.sortedHoles.count else { break }
            let hole = round.sortedHoles[holeIndex]
            for (playerIndex, strokes) in row.enumerated() where playerIndex < players.count {
                players[playerIndex].score(forHole: hole)?.strokes = strokes
            }
        }

        try? context.save()
    }
}
