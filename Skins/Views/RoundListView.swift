//
//  RoundListView.swift
//  Skins
//
//  Home screen: your group's rounds, plus one tap to start a new one.
//

import SwiftUI
import SwiftData

struct RoundListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Round.createdAt, order: .reverse) private var rounds: [Round]

    @State private var showingCreate = false
    @State private var newlyCreated: Round?

    var body: some View {
        NavigationStack {
            Group {
                if rounds.isEmpty {
                    emptyState
                } else {
                    roundList
                }
            }
            .navigationTitle("Skins")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .tint(.golfGreen)
                }
            }
            .navigationDestination(item: $newlyCreated) { round in
                RoundDetailView(round: round)
            }
            .sheet(isPresented: $showingCreate) {
                CreateRoundView { round in
                    newlyCreated = round
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !rounds.isEmpty {
                    startButton
                }
            }
        }
        .tint(.golfGreen)
    }

    private var roundList: some View {
        List {
            ForEach(rounds) { round in
                NavigationLink {
                    RoundDetailView(round: round)
                } label: {
                    RoundRow(round: round)
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "flag.2.crossed.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.golfGreen.gradient)
            Text("No rounds yet")
                .font(AppFont.rounded(22, .bold))
            Text("The golf app built for your group,\nnot your handicap.")
                .font(AppFont.rounded(15))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button {
                showingCreate = true
            } label: {
                Label("Start a Round", systemImage: "plus")
                    .font(AppFont.rounded(17, .semibold))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.golfGreen)
            .padding(.top, 4)
        }
        .padding()
    }

    private var startButton: some View {
        Button {
            showingCreate = true
        } label: {
            Label("Start a Round", systemImage: "plus")
                .font(AppFont.rounded(18, .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(.golfGreen)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(rounds[index])
        }
    }
}

private struct RoundRow: View {
    let round: Round

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.fairway)
                    .frame(width: 48, height: 48)
                Image(systemName: "flag.fill")
                    .foregroundStyle(Color.golfGreen)
                    .font(.title3)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(round.name)
                    .font(AppFont.rounded(17, .semibold))
                Text("\(round.holeCount) holes · \(round.players.count) players")
                    .font(AppFont.rounded(13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(round.joinCode)
                    .font(AppFont.rounded(13, .bold))
                    .foregroundStyle(Color.golfGreen)
                Text(round.createdAt, format: .dateTime.month().day())
                    .font(AppFont.rounded(12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RoundListView()
        .modelContainer(for: [Round.self, Player.self, Hole.self, Score.self], inMemory: true)
}
