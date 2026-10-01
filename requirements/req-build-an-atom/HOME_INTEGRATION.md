# Build an Atom — Home Integration (Phase 8)

## Current Home hierarchy

```
HomeScreen
├── 物理 (Physics)
└── 化学 (Chemistry)
    ├── …溶液 / 浓度…
    ├── 原子核
    │   ├── 构建原子核
    │   └── Rutherford…
    ├── 原子结构          ← target
    │   ├── 构建原子      ← formal (this phase)
    │   └── 同位素与原子质量
    ├── 分子搭建
    └── …
```

## Target

| Field | Value |
| --- | --- |
| Category | 化学 → **原子结构** |
| Position | First card in 原子结构 (before 同位素与原子质量) |
| Title | `构建原子` |
| Subtitle | `质子 · 中子 · 电子 · 符号 · 游戏` |
| Thumbnail | `assets/build_an_atom/images/atomIcon.png` (PhET `atomIcon.png`) |
| Accent | `#1177AA` |
| Entry widget | `BuildAnAtomHome` |
| Navigation | `Navigator.push(MaterialPageRoute(builder: …))` via `_SimCard` |
| Default screen | Atom (PhET `build-an-atom-main.ts` order) |

## Existing similar simulations

- `构建原子核` → `BuildANucleusHome` + `KratosTabbedScreen`
- `同位素与原子质量` → `IsotopesAndAtomicMassHome` + TabBar

## Temporary QA (removed from user-facing Home)

Deleted:

- `构建原子 (QA)`
- `构建原子 Symbol (QA)`
- `构建原子 Game (QA)`

Internal tests may still construct `BuildAnAtomAtomScreen` / Symbol / Game directly.

## Model ownership (unchanged)

Each tab embeds its screen with `embedded: true`; each screen still owns an independent `BAAModel` / `GameModel`. No Home singleton.

## Phase 8 verification

| Gate | Result |
| --- | --- |
| Formal Home path | Home → 化学 → 原子结构 → 构建原子 → `BuildAnAtomHome` (Atom default) |
| QA user entry | REMOVED (`构建原子 (QA)` / Symbol / Game QA cards gone) |
| Duplicate entry | NONE |
| Home golden | `golden/home/chemistry_category_with_baa.png` + `atomic_structure_with_baa.png` |
| Internal QA harness | RETAINED (tests construct screens directly) |
