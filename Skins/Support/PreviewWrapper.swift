//
//  PreviewWrapper.swift
//  Skins
//
//  Spins up an in-memory, seeded container so previews have real data.
//

import SwiftUI
import SwiftData

struct PreviewWrapper<Content: View>: View {
    let content: (Round) -> Content
    private let container: ModelContainer
    private let round: Round

    init(@ViewBuilder content: @escaping (Round) -> Content) {
        self.content = content
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Round.self, Player.self, Hole.self, Score.self,
            configurations: config
        )
        SeedData.populateIfNeeded(container.mainContext)
        let rounds = (try? container.mainContext.fetch(FetchDescriptor<Round>())) ?? []
        self.container = container
        self.round = rounds.first ?? RoundFactory.makeRound(
            name: "Preview",
            holeCount: 9,
            playerNames: ["A", "B"],
            stakePerSkin: 10,
            in: container.mainContext
        )
    }

    var body: some View {
        content(round)
            .modelContainer(container)
    }
}
