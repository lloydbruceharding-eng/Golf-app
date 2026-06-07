//
//  ScorecardView.swift
//  Skins
//
//  Live, hole-by-hole grid. Names frozen left, totals frozen right, holes
//  scroll in the middle. Tap a cell to add a stroke.
//

import SwiftUI
import SwiftData

struct ScorecardView: View {
    @Bindable var round: Round

    private let numberRowH: CGFloat = 36
    private let parRowH: CGFloat = 42
    private let playerRowH: CGFloat = 56
    private let cellW: CGFloat = 48
    private let nameW: CGFloat = 128
    private let totalsW: CGFloat = 92

    private var players: [Player] { round.sortedPlayers }
    private var holes: [Hole] { round.sortedHoles }

    var body: some View {
        HStack(spacing: 0) {
            frozenNameColumn
            ScrollView(.horizontal, showsIndicators: false) {
                holeColumns
            }
            frozenTotalsColumn
        }
    }

    // MARK: Left frozen column (player names)

    private var frozenNameColumn: some View {
        VStack(spacing: 0) {
            headerCell("HOLE", height: numberRowH, width: nameW, alignment: .leading)
            headerCell("PAR", height: parRowH, width: nameW, alignment: .leading)
            ForEach(players) { player in
                HStack(spacing: 8) {
                    PlayerAvatar(player: player, size: 30)
                    Text(player.name)
                        .font(AppFont.rounded(15, .semibold))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(.leading, 10)
                .frame(width: nameW, height: playerRowH, alignment: .leading)
                .background(rowBackground(for: player))
            }
        }
        .overlay(alignment: .trailing) {
            Divider()
        }
    }

    // MARK: Scrolling middle (holes)

    private var holeColumns: some View {
        VStack(spacing: 0) {
            // Hole numbers
            HStack(spacing: 0) {
                ForEach(holes) { hole in
                    Text("\(hole.number)")
                        .font(AppFont.rounded(14, .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: cellW, height: numberRowH)
                }
            }
            // Editable par row
            HStack(spacing: 0) {
                ForEach(holes) { hole in
                    ParCell(hole: hole)
                        .frame(width: cellW, height: parRowH)
                }
            }
            // Score rows
            ForEach(players) { player in
                HStack(spacing: 0) {
                    ForEach(holes) { hole in
                        if let score = player.score(forHole: hole) {
                            ScoreCell(score: score, par: hole.par)
                                .frame(width: cellW, height: playerRowH)
                        } else {
                            Color.clear.frame(width: cellW, height: playerRowH)
                        }
                    }
                }
                .background(rowBackground(for: player))
            }
        }
    }

    // MARK: Right frozen column (totals)

    private var frozenTotalsColumn: some View {
        VStack(spacing: 0) {
            headerCell("TOTAL", height: numberRowH, width: totalsW, alignment: .center)
            headerCell("+/-", height: parRowH, width: totalsW, alignment: .center)
            ForEach(players) { player in
                HStack(spacing: 6) {
                    Text("\(player.totalStrokes)")
                        .font(AppFont.rounded(18, .heavy))
                    Text(toParString(player.scoreToPar))
                        .font(AppFont.rounded(13, .semibold))
                        .foregroundStyle(toParColor(player.scoreToPar))
                        .frame(width: 34)
                }
                .frame(width: totalsW, height: playerRowH)
                .background(rowBackground(for: player))
            }
        }
        .overlay(alignment: .leading) {
            Divider()
        }
    }

    // MARK: Helpers

    private func headerCell(_ text: String, height: CGFloat, width: CGFloat, alignment: Alignment) -> some View {
        Text(text)
            .font(AppFont.rounded(12, .bold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, alignment == .leading ? 12 : 0)
            .frame(width: width, height: height, alignment: alignment)
    }

    private func rowBackground(for player: Player) -> Color {
        guard let index = players.firstIndex(where: { $0.persistentModelID == player.persistentModelID }) else {
            return .clear
        }
        return index.isMultiple(of: 2) ? Color(.systemBackground) : Color(.secondarySystemBackground)
    }

    private func toParString(_ value: Int) -> String {
        if value == 0 { return "E" }
        return value > 0 ? "+\(value)" : "\(value)"
    }

    private func toParColor(_ value: Int) -> Color {
        if value == 0 { return .secondary }
        return value < 0 ? .golfGreen : .orange
    }
}

// MARK: - Editable par cell

private struct ParCell: View {
    @Bindable var hole: Hole

    var body: some View {
        Button {
            // Cycle 3 -> 4 -> 5 -> 6 -> 3
            hole.par = hole.par >= 6 ? 3 : hole.par + 1
        } label: {
            Text("\(hole.par)")
                .font(AppFont.rounded(15, .semibold))
                .foregroundStyle(Color.golfGreenDark)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.fairway)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PreviewWrapper { round in
        ScorecardView(round: round)
    }
}
