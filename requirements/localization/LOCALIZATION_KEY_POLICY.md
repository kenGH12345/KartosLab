# LOCALIZATION_KEY_POLICY

> PHASE 1 · KartosLab

## Principles

1. Keys express **semantics**, not UI chrome wording or widget type.
2. Default product locale is **zh-CN**; English remains a second locale for future switching.
3. Do not encode English text into the key (`common.resetAllButtonText` ❌).
4. Prefer namespaces over one giant flat bag.

## Namespace map

| Prefix | Scope |
|---|---|
| `common.*` | Cross-sim chrome: reset, play/pause, dialogs, tabs Intro/Lab… |
| `home.*` | Home chrome: title, search, empty/error/loading |
| `category.*` | Home discipline / subject group names |
| `shared.*` | Façade over common+a11y for L0 widgets (`loc.shared`) |
| `physics.*` | Canonical science terms (mass, gravity, pressure…) |
| `mechanics.*` | Reserved for mechanics-sim batches (PHASE 2+) |
| `fluids.*` | Reserved (density/buoyancy/pressure sims) |
| `optics.*` / `waves.*` | Reserved |
| `electricity.*` | Reserved |
| `chemistry.*` | Reserved |
| `quantum.*` | Reserved |
| `accessibility.*` | Screen-reader / semantics strings |
| `sim.<id>.title` / `sim.<id>.subtitle` | Home display names; `<id>` is stable English kebab-case |

## Correct vs incorrect

| Correct | Incorrect |
|---|---|
| `common.resetAll` | `common.resetAllButtonText` |
| `physics.gravity` | `physics.gravityLabel9` |
| `home.search` | `home.searchText` |
| `sim.bending-light.title` | `sim.bendingLightCardTitleString` |
| `accessibility.increaseMass` | `a11y.btnIncMass` |

## Parameterized keys

Use `{name}` placeholders:

- `physics.massWithValue` → `质量: {value} kg`
- `home.tagline` → `…共 {count} 个实验`
- `accessibility.openSimulation` → `打开实验：{title}`

Do **not** create `mass_1kg` / `mass_2kg` keys.

## Units & symbols

Units (`kg`, `m³`, `Pa`) stay in the template as scientific tokens — not translated.

## Ownership

- New shared chrome string → `common.*` (+ a11y twin if needed)
- New Home-only string → `home.*` / `category.*`
- New science term → `physics.*` (or domain namespace after PHASE 2)
- Sim-internal strings remain in legacy `*Strings` until that sim migrates
