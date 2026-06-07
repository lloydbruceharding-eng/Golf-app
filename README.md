# Skins ⛳️

**The golf app built for your group, not your handicap.**

A SwiftUI prototype of a social golf scorecard for casual friend groups —
think the WhatsApp group for your golf mates, with a scorecard and automatic
bet settlement. It is **not** a GPS rangefinder, **not** a handicap tracker,
**not** analytics, and **not** a swing simulator.

This is a local, offline prototype: there's no backend. "Real-time sync" and
"a friend joining via code" are simulated with local state (you add the other
players by name yourself).

---

## V1 features (and nothing more)

1. **Group round creation with a shareable join code**
   - One tap to start a round, name it, add **2–6 players by name only**
     (no accounts, no phone numbers — that friction is the whole thing this app avoids).
   - A 6-character join code is generated and shown with a **Copy** button.
     Mock "others joining" with the **Add player** button on the round screen.
   - Choose **9 or 18 holes**. Par defaults to 4 and is editable per hole
     (tap a par cell on the scorecard). No course database.

2. **Live scorecard**
   - Hole-by-hole grid with all players visible at once (names frozen left,
     totals frozen right, holes scroll in the middle).
   - **Tap a cell to add a stroke**; long-press for "remove a stroke" / "clear".
   - Running totals and score-to-par update live.

3. **Skins auto-calculation + shareable results card**
   - **Skins logic:** lowest *unique* score on a hole wins that hole's skin;
     **ties carry the skin over** to the next hole.
   - Settlement screen: skins won per player and **who owes who**, using an
     **editable stake per skin** (default **R10** — the founder's in South Africa).
   - A clean, screenshot-worthy **results card** rendered to a `UIImage` via
     `ImageRenderer` and shared through `ShareLink`. This card is the core
     growth feature.

---

## Tech

- **SwiftUI** only, **iOS 17+**, **Swift 5.9+**
- **MVVM**-flavoured structure (views + observable `@Model` data + pure logic)
- **SwiftData** for local persistence
- **Zero external dependencies** — Apple frameworks only

## How to run

1. Open `Skins.xcodeproj` in **Xcode 16** (or newer).
2. Select the **Skins** scheme and an **iOS 17+ simulator** (e.g. iPhone 15).
3. Press **Run** (⌘R).

The app launches with a seeded **"Sunday Fourball"** sample round (Lloyd, Sipho,
James, Thandi) with the first seven holes scored so you can immediately see
skins, a carry-over, and the settlement/results card. To start clean, swipe to
delete the sample round and tap **Start a Round**.

> The project uses Xcode's **synchronized file groups** (objectVersion 77), so
> any file you add under `Skins/` is picked up automatically — no manual
> project edits needed.

## Project structure

```
Skins/
├─ SkinsApp.swift            App entry; sets up the SwiftData container + seed
├─ Models/
│  ├─ Round.swift            Round + join-code generation
│  ├─ Player.swift           Player (name only) + score helpers
│  ├─ Hole.swift             Hole number + editable par
│  └─ Score.swift            One player's strokes on one hole
├─ Logic/
│  ├─ SkinsCalculator.swift  Skins rules, net cash, greedy settlement
│  └─ RoundFactory.swift     Builds rounds/holes/players + the score grid
├─ Views/
│  ├─ RoundListView.swift    Home: list of rounds + start
│  ├─ CreateRoundView.swift  30-second setup flow
│  ├─ RoundDetailView.swift  Join-code banner + scorecard + settle button
│  ├─ ScorecardView.swift    The live grid
│  ├─ ScoreCell.swift        One-tap score entry cell
│  ├─ SettlementView.swift   Skins, who-owes-who, editable stake, share
│  └─ ResultsCardView.swift  The shareable card (rendered to an image)
├─ Support/
│  ├─ Theme.swift            Golf-green palette, rounded fonts, Rand money, avatar
│  ├─ SeedData.swift         Sample round for first launch
│  └─ PreviewWrapper.swift   In-memory seeded container for #Previews
└─ Assets.xcassets           Accent color + app icon slot
```

## How skins settlement is calculated

Each hole is worth one skin. The lowest **unique** score wins it; on a tie the
skin carries to the next hole and is awarded with that hole's skin. For cash,
every skin a player wins collects the stake from each *other* player, so a
player's net is `stake × (skinsWon × playerCount − totalSkinsAwarded)`. Nets
always sum to zero, and the "who owes who" list is a greedy debtor/creditor
match that settles the group in the fewest payments.

---

*Prototype only — V1 scope is intentionally narrow. No GPS, handicaps,
analytics, chat, season leaderboards, profiles, or social feeds.*
