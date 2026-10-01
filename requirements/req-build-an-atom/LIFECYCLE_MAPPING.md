# Build an Atom — Lifecycle Mapping (Phase 7)

Evidence: PhET `AtomScreen.ts` / `SymbolScreen.ts` / `GameScreen.ts` + Flutter `lib/chemistry/build_an_atom/screens/`.

## PhET Screen ownership

| Screen | Model factory | Shared with other screens? |
| --- | --- | --- |
| Atom | `() => new BAAModel(...)` | **No** — own instance |
| Symbol | `() => new BAAModel(...)` | **No** — own instance |
| Game | `() => new GameModel(...)` | **No** — own instance |

Joist keeps each Screen’s model for the sim lifetime when switching tabs. Atom mutations never write into Symbol’s model (and vice versa). Game score never mutates Atom/Symbol.

## Flutter ownership (QA entry + production screens)

| Question | Answer |
| --- | --- |
| Who owns `BAAModel`? | Each of `BuildAnAtomAtomScreen` / `BuildAnAtomSymbolScreen` when `model == null` (`_ownsModel`) |
| Who disposes `BAAModel`? | Screen `dispose()` → `_model.dispose()` if owned |
| Leaving screen destroy model? | **Yes** for owned models (Navigator pop / `pumpWidget` replace) |
| Returning create new model? | **Yes** for QA routes (`const BuildAnAtom*Screen()` with no inject) |
| Does Game persist between transitions? | Only if a `GameModel` is **injected** and the host keeps it; owned Game creates fresh model each open |
| Who owns `GameTimer`? | Domain object inside `GameModel`; advanced by Screen `Ticker` via `GameModel.step` |
| Timer on leave? | Screen `dispose` → `timer.stop()` (+ owned `GameModel.dispose()`) |
| Timer on return (injected)? | `_resumeTimerIfNeeded()` restarts if mid-level + `timerEnabled` |
| Focus / keyboard? | Per-particle `FocusableActionDetector` in play area; disposed with widget tree |
| Reward / FaceNode? | Built under Game views; leave disposes State + reward ticker |
| Accordion / view state? | `AtomViewState` / `SymbolViewState` disposed with owning screen |

## Formal Home entry (Phase 8)

```dart
_buildBuildAnAtom → BuildAnAtomHome()  // Atom | Symbol | Game tabs
```

Temporary QA cards (`构建原子 (QA)` / Symbol / Game QA) **removed** from user-facing Home.
Each tab still embeds an independent owned model (`embedded: true`).

## Isolation rules (must hold)

```
Atom mutation ≠ Symbol mutation ≠ Game mutation
```

Tests that inject one shared `BAAModel` into Atom+Symbol are **harness-only** (Phase 6 Q). Production QA path must not share.

## Dispose rules

1. Always dispose Screen `Ticker` first.
2. Stop Game timer so no invisible accumulation.
3. Remove `GameModel` listeners in `GameChallengeView.dispose`.
4. Dispose owned `BAAModel` / schematic answer `BAAModel`.
5. Never `setState` after dispose (verified by stress tests).
