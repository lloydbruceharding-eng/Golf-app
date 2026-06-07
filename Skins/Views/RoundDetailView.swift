//
//  RoundDetailView.swift
//  Skins
//
//  Join-code banner + the live scorecard, with a path to settle up.
//

import SwiftUI
import SwiftData

struct RoundDetailView: View {
    @Bindable var round: Round
    @Environment(\.modelContext) private var context

    @State private var addPlayerName = ""
    @State private var showingAddPlayer = false

    var body: some View {
        VStack(spacing: 0) {
            JoinCodeBanner(round: round) {
                showingAddPlayer = true
            }
            ScorecardView(round: round)
        }
        .navigationTitle(round.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            settleButton
        }
        .alert("Add player", isPresented: $showingAddPlayer) {
            TextField("Name", text: $addPlayerName)
            Button("Cancel", role: .cancel) { addPlayerName = "" }
            Button("Add") { addPlayer() }
        } message: {
            Text("Simulate a friend joining with the code \(round.joinCode).")
        }
    }

    private var settleButton: some View {
        NavigationLink {
            SettlementView(round: round)
        } label: {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                Text("View Skins & Settle")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
            }
            .font(AppFont.rounded(18, .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .background(Color.golfGreen.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func addPlayer() {
        let trimmed = addPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, round.players.count < 6 else {
            addPlayerName = ""
            return
        }
        RoundFactory.addPlayer(named: trimmed, to: round, in: context)
        try? context.save()
        addPlayerName = ""
    }
}

// MARK: - Join code banner

private struct JoinCodeBanner: View {
    let round: Round
    var onAddPlayer: () -> Void
    @State private var copied = false

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("JOIN CODE")
                    .font(AppFont.rounded(11, .bold))
                    .foregroundStyle(.white.opacity(0.8))
                Text(round.joinCode)
                    .font(AppFont.rounded(26, .heavy))
                    .foregroundStyle(.white)
                    .tracking(3)
            }

            Spacer()

            Button {
                UIPasteboard.general.string = round.joinCode
                withAnimation { copied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation { copied = false }
                }
            } label: {
                Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                    .font(AppFont.rounded(14, .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.2), in: Capsule())
                    .foregroundStyle(.white)
            }

            Button(action: onAddPlayer) {
                Image(systemName: "person.badge.plus")
                    .font(.title3)
                    .padding(8)
                    .background(.white.opacity(0.2), in: Circle())
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.golfGreenDark.gradient)
    }
}

#Preview {
    NavigationStack {
        PreviewWrapper { round in
            RoundDetailView(round: round)
        }
    }
}
