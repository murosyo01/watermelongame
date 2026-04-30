# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a device/emulator
flutter run

# Run on web
flutter run -d chrome

# Build
flutter build apk          # Android
flutter build web          # Web

# Analyze and lint
flutter analyze

# Run tests
flutter test
flutter test test/widget_test.dart   # single test file
flutter test test/game/              # game-specific tests
flutter test test/models/            # model tests

# Check for outdated packages
flutter pub outdated
```

## Architecture

This is a Flutter implementation of the Suika (watermelon) drop-and-merge game, built on **Flame** (game engine) + **flame_forge2d** (2D physics via Box2D).

### Key layers

- **`lib/main.dart`** — Flutter entry point. Wraps `WatermelonGame` in `GameWidget` and defines the `GameOver` overlay UI.
- **`lib/game/watermelon_game.dart`** — Core game class (`Forge2DGame + TapCallbacks`). Owns the game loop, tap handling, merge processing, game-over detection, and score state. Coordinate system is physics-world units (not pixels); camera zoom maps world units to screen pixels.
- **`lib/models/fruit_level.dart`** — `FruitLevel` enum defining the 11 fruit tiers (cherry → watermelon), each with `radius`, `color`, and `score`. The `next` getter drives the merge chain.
- **`lib/components/fruit.dart`** — `Fruit extends BodyComponent`; creates a dynamic Box2D circle body. `pendingMerge` flag prevents double-merge within a single physics step.
- **`lib/components/walls.dart`** — Static Box2D edge bodies for left wall, right wall, and floor, plus visual `WallLine` renderers.
- **`lib/components/drop_indicator.dart`** — Thin vertical line drawn at the current drop X position.
- **`lib/systems/merge_contact_listener.dart`** — `ContactListener` subclass. On `beginContact`, if two `Fruit` bodies with the same level touch, it marks both `pendingMerge = true` and enqueues a `MergePair` callback. Actual removal and spawning happen in `WatermelonGame._processMerges()` to stay outside the physics step.

### Merge flow

1. Two same-level fruits collide → `MergeContactListener.beginContact` fires, enqueues `MergePair`.
2. `WatermelonGame.update` calls `_processMerges` after `super.update` (outside physics step).
3. Both fruits are removed; a new `Fruit` at `level.next` spawns at their midpoint; score increments by `nextLevel.score`.

### Physics coordinate system

World coordinates run from `(-2, -7)` top-left to `(2, 8)` bottom-right. Gravity is `(0, 30)`. Camera zoom is computed from screen size to fit the container with 10% padding.

### Game-over logic

A 2-second grace timer (`_gameOverTimer`) accumulates whenever any non-pending fruit is above `gameOverLineY = -5.5` with near-zero velocity. If the timer reaches 2 s, the `GameOver` overlay is shown.

## Testing

Uses `flame_test` + `flutter_test`. Game tests use `testWithGame`:

```dart
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermelongame/game/watermelon_game.dart';

testWithGame<WatermelonGame>(
  'description',
  WatermelonGame.new,
  (game) async {
    // game is fully loaded when this callback runs
    game.update(0.016); // advance one physics frame (≈60 fps)
    expect(game.score, 0);
  },
);
```

Key rules:
- Never add/remove bodies inside the physics step — use `game.update()` to advance frames first.
- `game.score` is public; `game.restart()` resets all state.
- Test files live in `test/game/` (game logic) and `test/models/` (enum/data).

## Improvement backlog

Pending improvements are tracked in `.claude/work/output/improvement_proposals.md`.
Use the `feature-implementer` agent to implement them one at a time.

## Workflow tips

- After implementing a feature, run `/simplify` to catch redundant code.
- For recurring tasks (e.g. backlog triage), use `/schedule` to set up a background agent.

## Self-improvement loop

Run `/improve-claude` to execute one cycle of Claude Code self-improvement:

1. `claude-config-auditor` scans `.claude/` and `CLAUDE.md` for stale references, hook gaps, and missing configs.
2. The top-priority candidate is picked from `.claude/work/output/claude_setup_backlog.md`.
3. `claude-config-implementer` applies the change and validates it.
4. The change is committed (gated by the existing `flutter analyze + test` PreToolUse hook).

Backlog file: `.claude/work/output/claude_setup_backlog.md`
ID prefixes: `CFG-*` (settings/hooks/permissions) | `AGT-*` (agents) | `DOC-*` (CLAUDE.md) | `CMD-*` (commands/skills)

Game-code improvements are tracked separately in `.claude/work/output/improvement_proposals.md` and use `feature-implementer`.
You can also add items to the backlog manually — just follow the format in the file.
