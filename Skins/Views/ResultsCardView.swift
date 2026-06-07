//
//  ResultsCardView.swift
//  Skins
//
//  The screenshot-worthy results card. Designed at a fixed width so it renders
//  cleanly to an image for sharing — this is the app's core growth loop.
//

import SwiftUI

struct ResultsCardView: View {
    let round: Round

    private var results: [PlayerResult] {
        SkinsCalculator.results(for: round)
            .sorted { $0.skinsWon != $1.skinsWon ? $0.skinsWon > $1.skinsWon : $0.net > $1.net }
    }

    private var onTheTable: Int { SkinsCalculator.skinsOnTheTable(for: round) }

    var body: some View {
        VStack(spacing: 0) {
            header
            VStack(spacing: 10) {
                ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                    resultRow(rank: index + 1, result: result)
                }
            }
            .padding(20)

            if onTheTable > 0 {
                Text("\(onTheTable) skin\(onTheTable == 1 ? "" : "s") still on the table")
                    .font(AppFont.rounded(13, .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.sandHighlight.opacity(0.9), in: Capsule())
                    .padding(.bottom, 14)
            }

            footer
        }
        .frame(width: 360)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "flag.2.crossed.fill")
                Text("SKINS")
                    .font(AppFont.rounded(16, .heavy))
                    .tracking(4)
            }
            .foregroundStyle(.white.opacity(0.9))

            Text(round.name)
                .font(AppFont.rounded(26, .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("\(round.holeCount) holes · \(round.createdAt.formatted(date: .abbreviated, time: .omitted)) · \(Money.string(round.stakePerSkin))/skin")
                .font(AppFont.rounded(13, .medium))
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background(Color.golfGreen.gradient)
    }

    // MARK: Row

    private func resultRow(rank: Int, result: PlayerResult) -> some View {
        HStack(spacing: 12) {
            Text(rankBadge(rank))
                .font(AppFont.rounded(20, .bold))
                .frame(width: 30)

            PlayerAvatar(player: result.player, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.player.name)
                    .font(AppFont.rounded(17, .bold))
                Text("\(result.skinsWon) skin\(result.skinsWon == 1 ? "" : "s")")
                    .font(AppFont.rounded(13, .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(Money.signed(result.net))
                .font(AppFont.rounded(19, .heavy))
                .foregroundStyle(netColor(result.net))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(rank == 1 ? Color.fairway : Color(.secondarySystemBackground))
        )
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Image(systemName: "flag.fill")
            Text("Made with Skins — the golf app for your group")
        }
        .font(AppFont.rounded(12, .semibold))
        .foregroundStyle(.secondary)
        .padding(.bottom, 18)
    }

    private func rankBadge(_ rank: Int) -> String {
        switch rank {
        case 1: return "🏆"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }

    private func netColor(_ net: Double) -> Color {
        if net > 0 { return .golfGreen }
        if net < 0 { return .red }
        return .secondary
    }
}

#Preview {
    PreviewWrapper { round in
        ResultsCardView(round: round)
            .padding()
    }
}
