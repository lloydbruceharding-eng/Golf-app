//
//  SettlementView.swift
//  Skins
//
//  Who won what, who owes who, an editable stake, and the shareable card.
//

import SwiftUI
import SwiftData

struct SettlementView: View {
    @Bindable var round: Round

    @State private var cardImage: UIImage?

    private var results: [PlayerResult] {
        SkinsCalculator.results(for: round)
            .sorted { $0.skinsWon != $1.skinsWon ? $0.skinsWon > $1.skinsWon : $0.net > $1.net }
    }

    private var settlements: [Settlement] {
        SkinsCalculator.settlements(for: round)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                stakeControl
                resultsSection
                settlementSection
                cardPreview
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Skins & Settle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let image = cardImage {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("\(round.name) — Skins results", image: Image(uiImage: image))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .task(id: redrawKey) { renderCard() }
    }

    // Recompute the card whenever something that affects it changes.
    private var redrawKey: String {
        let scores = round.sortedPlayers
            .map { "\($0.totalStrokes)" }
            .joined(separator: "-")
        return "\(round.stakePerSkin)|\(scores)"
    }

    // MARK: Stake

    private var stakeControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STAKE PER SKIN")
                .font(AppFont.rounded(12, .bold))
                .foregroundStyle(.secondary)
            Stepper(value: $round.stakePerSkin, in: 1...500, step: 5) {
                HStack {
                    Image(systemName: "banknote.fill")
                        .foregroundStyle(Color.golfGreen)
                    Text(Money.string(round.stakePerSkin))
                        .font(AppFont.rounded(22, .heavy))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Skins won")
            VStack(spacing: 0) {
                ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                    HStack(spacing: 12) {
                        PlayerAvatar(player: result.player, size: 36)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(result.player.name)
                                .font(AppFont.rounded(16, .semibold))
                            Text("\(result.skinsWon) skin\(result.skinsWon == 1 ? "" : "s")")
                                .font(AppFont.rounded(13))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(Money.signed(result.net))
                            .font(AppFont.rounded(18, .heavy))
                            .foregroundStyle(result.net > 0 ? .golfGreen : (result.net < 0 ? .red : .secondary))
                    }
                    .padding(.vertical, 12)
                    if index < results.count - 1 { Divider() }
                }
            }
            .padding(.horizontal, 14)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: Settlement

    private var settlementSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Who owes who")
            if settlements.isEmpty {
                Text(round.isComplete ? "All square — nobody owes anything." : "Finish entering scores to settle up.")
                    .font(AppFont.rounded(15))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(settlements.enumerated()), id: \.element.id) { index, settlement in
                        HStack(spacing: 10) {
                            Text(settlement.from.name)
                                .font(AppFont.rounded(16, .semibold))
                            Image(systemName: "arrow.right")
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(settlement.to.name)
                                .font(AppFont.rounded(16, .semibold))
                            Spacer()
                            Text(Money.string(settlement.amount))
                                .font(AppFont.rounded(18, .heavy))
                                .foregroundStyle(Color.golfGreen)
                        }
                        .padding(.vertical, 12)
                        if index < settlements.count - 1 { Divider() }
                    }
                }
                .padding(.horizontal, 14)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    // MARK: Card preview

    private var cardPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Shareable card")
            ResultsCardView(round: round)
                .frame(maxWidth: .infinity)
            if let image = cardImage {
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview("\(round.name) — Skins results", image: Image(uiImage: image))
                ) {
                    Label("Share Results Card", systemImage: "square.and.arrow.up")
                        .font(AppFont.rounded(17, .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.golfGreen.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(AppFont.rounded(18, .bold))
    }

    @MainActor
    private func renderCard() {
        let renderer = ImageRenderer(content: ResultsCardView(round: round).padding(16))
        renderer.scale = 3.0
        cardImage = renderer.uiImage
    }
}

#Preview {
    NavigationStack {
        PreviewWrapper { round in
            SettlementView(round: round)
        }
    }
}
