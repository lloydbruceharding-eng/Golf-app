//
//  CreateRoundView.swift
//  Skins
//
//  30-second setup: name it, add 2–6 players by name, pick 9 or 18, go.
//

import SwiftUI
import SwiftData

struct CreateRoundView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var onCreate: (Round) -> Void

    @State private var name = ""
    @State private var holeCount = 18
    @State private var stake = 10
    @State private var playerNames: [String] = ["", ""]
    @FocusState private var focusedField: Int?

    private let minPlayers = 2
    private let maxPlayers = 6

    private var trimmedNames: [String] {
        playerNames.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    private var canCreate: Bool {
        trimmedNames.count >= minPlayers
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Round") {
                    TextField("Round name (e.g. Sunday Fourball)", text: $name)
                        .font(AppFont.rounded(16))
                }

                Section("Holes") {
                    Picker("Holes", selection: $holeCount) {
                        Text("9 holes").tag(9)
                        Text("18 holes").tag(18)
                    }
                    .pickerStyle(.segmented)
                    Text("Par defaults to 4 per hole — tap a par on the scorecard to change it.")
                        .font(AppFont.rounded(12))
                        .foregroundStyle(.secondary)
                }

                Section {
                    ForEach(playerNames.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                            TextField("Player \(index + 1)", text: $playerNames[index])
                                .font(AppFont.rounded(16))
                                .focused($focusedField, equals: index)
                            if playerNames.count > minPlayers {
                                Button {
                                    removePlayer(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    if playerNames.count < maxPlayers {
                        Button {
                            addPlayerField()
                        } label: {
                            Label("Add player", systemImage: "plus.circle.fill")
                                .foregroundStyle(Color.golfGreen)
                        }
                    }
                } header: {
                    Text("Players (\(minPlayers)–\(maxPlayers))")
                } footer: {
                    Text("Just names. No accounts, no phone numbers — that's the whole point.")
                        .font(AppFont.rounded(12))
                }

                Section("Stake per skin") {
                    Stepper(value: $stake, in: 1...500, step: 5) {
                        HStack {
                            Text("Stake")
                            Spacer()
                            Text(Money.string(Double(stake)))
                                .font(AppFont.rounded(16, .semibold))
                                .foregroundStyle(Color.golfGreen)
                        }
                    }
                }
            }
            .navigationTitle("New Round")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }
                        .font(AppFont.rounded(17, .semibold))
                        .disabled(!canCreate)
                }
            }
        }
        .tint(.golfGreen)
    }

    private func addPlayerField() {
        guard playerNames.count < maxPlayers else { return }
        playerNames.append("")
        focusedField = playerNames.count - 1
    }

    private func removePlayer(at index: Int) {
        guard playerNames.count > minPlayers else { return }
        playerNames.remove(at: index)
    }

    private func create() {
        let round = RoundFactory.makeRound(
            name: name.trimmingCharacters(in: .whitespaces),
            holeCount: holeCount,
            playerNames: trimmedNames,
            stakePerSkin: Double(stake),
            in: context
        )
        try? context.save()
        dismiss()
        onCreate(round)
    }
}

#Preview {
    CreateRoundView { _ in }
        .modelContainer(for: [Round.self, Player.self, Hole.self, Score.self], inMemory: true)
}
