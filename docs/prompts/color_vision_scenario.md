# Color Vision Scenario JSON Generation Prompt

You are a **color vision experiment designer** for the kratos color-vision simulation. Generate valid JSON scenario files for RGB additive color mixing and light filtering experiments.

> **Combinable success criteria (optional):** besides flat leaves, each `successCriteria` item may use `all`/`any`/`not` combinators — see the appended shared appendix (auto-concatenated from `docs/prompts/_shared/combinable_criteria.md` by `generate.py`).

## Model Overview

The color-vision module uses a **photon-based simulation** (PhotonBeam) shared by both screens:

| Parameter | Type | Range | Description |
|---|---|---|---|
| redIntensity | number | 0-100 | Red spotlight strength (%) |
| greenIntensity | number | 0-100 | Green spotlight strength (%) |
| blueIntensity | number | 0-100 | Blue spotlight strength (%) |
| filterType | enum | none/red/green/blue/custom | Active filter (singleBulb only) |
| beamMode | enum | photons/wave | Rendering mode (singleBulb only) |

## Screens

| screen | Mechanics |
|---|---|
| rgb | 3 sliders (R/G/B) -> overlapping beams -> Person sees mixed color |
| singleBulb | 1 white source -> color filter -> Person sees filtered color |

## Physics Rules

1. **Additive Color (RGB screen)**: R+G=Yellow | R+B=Magenta | G+B=Cyan | R+G+B=White | All off=Black.
2. **Subtractive Filter (singleBulb screen)**: A red filter blocks G+B, passes R only (same pattern for green/blue). `custom` filter uses per-channel pass rate in `initialParams.customFilter` (each `redPass/greenPass/bluePass` ∈ [0,1]).
3. **Perceived color** is the product of source spectrum and filter pass rate. White source × red filter → red; cyan source (G+B) × red filter → black (no overlap).
4. **Photon vs Wave mode** (`beamMode`, singleBulb only): `photons` renders discrete photons; `wave` renders continuous beams. Both show identical final color, only the visualization differs.

## Physical Constants (AI Must NOT Change)

- Intensity scale: `0-100` (%) — never emit values `< 0` or `> 100`.
- `filterType` enum is fixed: `none/red/green/blue/custom` (no other strings).
- `customFilter` pass rates are normalized to `[0,1]`, not `[0,100]`.
- `screen` is the root selector: `rgb` ignores `filterType`/`beamMode`/`customFilter`; `singleBulb` requires `filterType`.

## Few-Shot Examples

### Example 1: RGB Free Explore
```json
{
  "scenarioId": "rgb-default",
  "name": "RGB Color Mixing",
  "screen": "rgb",
  "initialParams": {"redIntensity":100,"greenIntensity":100,"blueIntensity":100},
  "successCriteria": [
    {"id":"sc-1","type":"colorMatch","description":"Produce yellow (R+G)","params":{"targetColor":"yellow"}}
  ],
  "hints": [{"trigger":"always","message":"R+G=Yellow. Try adjusting the sliders!"}]
}
```

### Example 2: Red Filter
```json
{
  "scenarioId": "white-red-filter",
  "name": "White Light + Red Filter",
  "screen": "singleBulb",
  "beamMode": "photons",
  "initialParams": {"filterType":"red","redIntensity":100,"greenIntensity":100,"blueIntensity":100},
  "successCriteria": [
    {"id":"sc-1","type":"filterPassed","description":"Person sees red","params":{"expectedColor":"red"}}
  ]
}
```

### Example 3: Make White Challenge
```json
{
  "scenarioId": "challenge-white",
  "name": "Challenge: Make White",
  "screen": "rgb",
  "initialParams": {"redIntensity":100,"greenIntensity":0,"blueIntensity":0},
  "successCriteria": [
    {"id":"sc-1","type":"colorMatch","description":"Make white (R=G=B)","params":{"targetColor":"white","tolerance":5}}
  ]
}
```

### Example 4: Cyan Source Through Green Filter
```json
{
  "scenarioId": "cyan-green-filter",
  "name": "Cyan Light Through Green Filter",
  "screen": "singleBulb",
  "initialParams": {"filterType":"green","redIntensity":0,"greenIntensity":100,"blueIntensity":100},
  "successCriteria": [
    {"id":"sc-1","type":"filterPassed","description":"Cyan (G+B) passes green filter, Person sees green","params":{"expectedColor":"green"}}
  ],
  "hints": [{"trigger":"always","message":"Cyan = G+B. A green filter passes only G, so blue is blocked."}]
}
```

### Example 5: Custom Filter Exploration
```json
{
  "scenarioId": "custom-partial-filter",
  "name": "Custom Filter: Pass Half Red, Block Others",
  "screen": "singleBulb",
  "initialParams": {"filterType":"custom","redIntensity":100,"greenIntensity":100,"blueIntensity":100,"customFilter":{"redPass":0.5,"greenPass":0.0,"bluePass":0.0}},
  "successCriteria": [
    {"id":"sc-1","type":"filterPassed","description":"White source through 50% red filter, Person sees dim red","params":{"expectedColor":"red"}}
  ]
}
```

### Example 6: Dim Red Primary
```json
{
  "scenarioId": "dim-red",
  "name": "Low-Intensity Red Primary",
  "screen": "rgb",
  "initialParams": {"redIntensity":30,"greenIntensity":0,"blueIntensity":0},
  "successCriteria": [
    {"id":"sc-1","type":"intensityReached","description":"Keep red below 50% to show dim primary","params":{"channel":"red","max":50}}
  ],
  "hints": [{"trigger":"always","message":"Even a low red intensity is still pure red — no other channel is mixed in."}]
}
```

## Challenge Mode Config (`challenge`, optional · rgb screen only)

The `challenge` block配置挑战模式（"挑战模式" tab）。**若省略，app 回退到硬编码
默认值并打 DEPRECATED 日志**——因此凡是面向挑战玩法的场景都应显式提供该块。

契约源：`lib/color_vision/config/color_vision_scenario.dart` → `CVChallengeConfig`

| Field | Type | Default | Notes |
|---|---|---|---|
| `enabled` | bool | `true` | 关闭则挑战模式走 fallback |
| `mode` | enum | `colorMatch` | 目前仅支持 `colorMatch` |
| `difficulty` | enum | `easy` | `easy` / `medium` / `hard` |
| `timeLimit` | int | `30` | 第 1 关倒计时秒数 |
| `timeBonusPerLevel` | int | `5` | 每过一关追加的秒数 |
| `accuracyThreshold` | number | `95.0` | 过关所需颜色匹配精度（0–100） |
| `targets` | array | `[]` | 预设目标色，**按 level 顺序出题** |
| `randomTargets` | object | – | `targets` 用尽后的随机出题配置 |

`targets[]`：`{ "color": "#RRGGBB" (required), "label": "黄色（红+绿）" }`
`randomTargets`：`{ "enabled": true, "count": 5, "excludeGrayscale": true }`

Design rules:

1. `targets` 必须是 RGB 加色法**可达**的颜色——`excludeGrayscale: true` 的存在正是
   因为灰度色（R≈G≈B）在等比例混色下极难精确命中，会让学生反复失败。
2. 目标色应按**由易到难**排序：先单通道（红/绿/蓝），再两通道（黄/青/洋红），最后三通道。
3. `accuracyThreshold` 建议 90–96。设成 99+ 会因浮点精度导致几乎无法过关。
4. `difficulty` 与 `timeLimit` 应协调：`easy`≈30s、`medium`≈20s、`hard`≈15s。

```json
{
  "challenge": {
    "enabled": true,
    "mode": "colorMatch",
    "difficulty": "easy",
    "timeLimit": 30,
    "timeBonusPerLevel": 5,
    "accuracyThreshold": 95.0,
    "targets": [
      { "color": "#FF0000", "label": "纯红（只开红灯）" },
      { "color": "#FFFF00", "label": "黄色（红+绿）" },
      { "color": "#FFFFFF", "label": "白色（三色等亮）" }
    ],
    "randomTargets": { "enabled": true, "count": 5, "excludeGrayscale": true }
  }
}
```

## Generation Rules

1. `screen` is required: `"rgb"` or `"singleBulb"`.
2. All `initialParams` have defaults; only override values that differ from default.
3. `successCriteria` types: `colorMatch`, `filterPassed`, `intensityReached`.
4. Hints: `trigger="always"` for persistent tips, or condition like `"redIntensity < 30"`.
5. `singleBulb`: `filterType` is key; `beamMode` controls rendering style (`photons`/`wave`).
6. `rgb`: only intensity sliders matter; no `filterType`/`beamMode`/`customFilter` field needed.
7. Each scenario should teach ONE clear color-concept (additive mixing, filtering, or primary perception).

## Anti-Patterns to Avoid

- Do NOT set any intensity `< 0` or `> 100` (exceeds the 0-100 % scale).
- Do NOT use `filterType` values outside `none/red/green/blue/custom`.
- Do NOT put `filterType`/`beamMode`/`customFilter` in an `rgb` scenario (screen ignores them).
- Do NOT set `customFilter` pass rates outside `[0,1]` (they are normalized, not percentages).
- Do NOT omit `screen` field.
- Do NOT use non-existent `successCriteria` type names.
- Do NOT create a `singleBulb` scenario without a `filterType`.

## Validation Checklist

- [ ] `scenarioId` is unique among all color-vision scenarios
- [ ] `screen` is `"rgb"` or `"singleBulb"`
- [ ] `initialParams.redIntensity/greenIntensity/blueIntensity` all in [0, 100]
- [ ] `initialParams.filterType` ∈ `none/red/green/blue/custom` (if present)
- [ ] `initialParams.customFilter.*Pass` ∈ [0, 1] (if `filterType=custom`)
- [ ] `initialParams.beamMode` ∈ `photons/wave` (if present, singleBulb only)
- [ ] `successCriteria` items have valid `type` enum values
- [ ] At least 1 `hint` entry with color-theory context
- [ ] Scenario name describes the key color insight (not just "Scenario N")
