//
//  SkinsApp.swift
//  Skins
//
//  The golf app built for your group, not your handicap.
//

import SwiftUI
import SwiftData

@main
struct SkinsApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Round.self, Player.self, Hole.self, Score.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        // Populate a sample round on first launch so the app opens ready to explore.
        SeedData.populateIfNeeded(container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            RoundListView()
        }
        .modelContainer(container)
    }
}
