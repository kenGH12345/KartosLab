# Coordinate Shell — Energy Forms and Changes

> Stage A (P0): shell only. Design-space object coordinates untouched.

## Mapping (restored)

```text
PhET design 1024×618
  → simulation viewport (full tab body; no NineGrid)
  → EfacSimulationShell (PhET layout() semantics)
  → Flutter scene (IntroScreenBody / SystemsScreenBody)
  → screen
```

## Shell rules

| Case | Scale | Align |
|---|---|---|
| Width-limited (`scaleX ≤ scaleY`) | `min(sx,sy)` | **bottom** + flush H (`offsetY ≥ 0`) |
| Height-limited | `min(sx,sy)` | **top** + horizontal center (`dx ≥ 0`) |
| Exact 1024×618 | 1 | identity |

Source: `EFACIntroScreenView.layout` / `SystemsScreenView.layout`.

## What changed

- Home: removed EFAC `NineGridLayout` wrap → `EfacSimulationShell`
- Bodies: removed inner `FittedBox`; remain design-space Stacks
- Global NineGrid API: **unchanged**

## QA paths

| Path | How | Output |
|---|---|---|
| Design-space | Body @ 1024×618 | `runtime/flutter/*.png` |
| Live-shell | `EnergyFormsAndChangesHome` @ 1280×800 | `runtime/flutter/live_shell/*` |

Do **not** use design-space captures to validate shell transform.
