//
//  ScoreCell.swift
//  Skins
//
//  One-tap score entry. Tap to add a stroke; long-press to adjust or clear.
//  Birdies get a circle, bogeys a square — like a real scorecard.
//

import SwiftUI

struct ScoreCell: View {
    @Bindable var score: Score
    let par: Int

    private var diff: Int { score.strokes - par }

    var body: some View {
        Button {
            increment()
        } label: {
            ZStack {
                shapeOverlay
                Text(score.strokes == 0 ? "–" : "\(score.strokes)")
                    .font(AppFont.rounded(19, .bold))
                    .foregroundStyle(score.strokes == 0 ? Color.secondary.opacity(0.5) : textColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                if score.strokes > 0 { score.strokes -= 1 }
            } label: {
                Label("Remove a stroke", systemImage: "minus.circle")
            }
            Button(role: .destructive) {
                score.strokes = 0
            } label: {
                Label("Clear", systemImage: "xmark.circle")
            }
        }
    }

    private func increment() {
        // Tap cycles up; wraps back to empty after a generous max.
        score.strokes = score.strokes >= 12 ? 0 : score.strokes + 1
    }

    @ViewBuilder
    private var shapeOverlay: some View {
        if score.strokes > 0 {
            if diff <= -1 {
                // Birdie or better: circle (double circle for eagle+)
                Circle()
                    .strokeBorder(Color.golfGreen, lineWidth: diff <= -2 ? 3 : 1.8)
                    .frame(width: 34, height: 34)
            } else if diff >= 1 {
                // Bogey or worse: square (heavier for double+)
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(diff >= 2 ? Color.red.opacity(0.8) : Color.orange, lineWidth: 1.8)
                    .frame(width: 32, height: 32)
            }
        }
    }

    private var textColor: Color {
        if diff <= -1 { return .golfGreenDark }
        if diff >= 2 { return .red }
        if diff == 1 { return .orange }
        return .primary
    }
}
