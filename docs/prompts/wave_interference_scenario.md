# Wave Interference Scenario JSON Generation Prompt

You are a **wave optics experiment designer** for the PhET wave-interference simulation. Generate valid JSON scenario files for the water-wave double-slit interference experiment.

## Model Overview

The wave-interference module uses a **finite-difference time-domain (FDTD) 2D wave equation solver** on an 80x55 grid. A point oscillator generates circular ripples. An optional barrier with two slits creates two coherent secondary sources, producing the classic Young double-slit interference pattern.

| Parameter | Type | Range | Description |
|---|---|---|---|
| frequency | number | 0.1-1.0 | Oscillator frequency. Higher = shorter wavelength, denser fringes. |
| amplitude | number | 0.2-3.0 | Wave amplitude. Higher = brighter heatmap (stronger crests/troughs). |
| barrierEnabled | boolean | true/false | Show the double-slit barrier. False = free single-source propagation. |
| slitSize | integer | 4-20 | Height of each slit (grid cells). Narrower = more ideal point source. |
| slitSeparation | integer | 12-36 | Center-to-center slit distance. Wider = more fringes (d sin theta = n lambda). |

## Screen

| screen | Mechanics |
|---|---|
| waterDoubleSlit | 1 point oscillator (left side) -> circular wave propagation -> optional double-slit barrier (center) -> interference pattern on 80x55 FDTD grid rendered as water-blue heatmap |

## Physics Rules

1. **Wave Equation (FDTD)**: `u_new = 2u - u_old + c虏 * laplacian(u)`. c虏=0.25, grid=80x55, damped edges prevent reflections.
2. **Huygens Principle**: Each slit acts as a new point source. The two slit sources are coherent (same frequency/phase from the parent oscillator).
3. **Double-Slit Equation**: Bright fringes at angles where `d * sin(theta) = n * lambda`. Wider separation (d) = more fringes. Shorter wavelength (higher f) = more fringes.
4. **Constructive Interference**: Crest + Crest = brighter (amplitudes add). Trough + Trough = deeper blue.
5. **Destructive Interference**: Crest + Trough = cancel (near zero, mid-blue). These form the dark bands between bright fringes.
6. **Single Source (no barrier)**: Clean circular ripples. No interference pattern 鈥?proving that two coherent sources are required.

## Physical Constants (AI Must NOT Change)

- `c虏 = 0.25` (wave speed squared, fixed by FDTD stability criteria)
- `grid = 80x55` (simulation lattice dimensions)
- `dampWidth = 15` (absorbing boundary zone on all 4 edges)
- `oscillatorRadius = 2` (source excitation radius in grid cells)
- `barrierX = 35` (barrier column position)
- `barrierThickness = 2` (wall width in grid cells)
- `fps = 30` (simulation tick rate)

## Few-Shot Examples

### Example 1: Classic Double-Slit (Default)
```json
{
  "scenarioId": "default",
  "name": "Water Wave Double-Slit",
  "screen": "waterDoubleSlit",
  "initialParams": {"frequency":0.4,"amplitude":1.5,"barrierEnabled":true,"slitSize":10,"slitSeparation":24},
  "successCriteria": [
    {"id":"sc-1","type":"observePattern","description":"Observe alternating bright/dark radial bands","params":{"minFrequency":0.2}}
  ],
  "hints": [
    {"trigger":"always","message":"The two slits act as coherent sources. Crest overlap = bright; crest + trough = dark."}
  ]
}
```

### Example 2: Free Propagation (No Barrier)
```json
{
  "scenarioId": "free-propagation",
  "name": "Discovery: What Happens Without Slits?",
  "screen": "waterDoubleSlit",
  "initialParams": {"frequency":0.4,"amplitude":1.5,"barrierEnabled":false,"slitSize":10,"slitSeparation":24},
  "successCriteria": [
    {"id":"sc-1","type":"observePattern","description":"Confirm clean circular ripples only","params":{"barrierEnabled":false}},
    {"id":"sc-2","type":"toggleBarrier","description":"Enable barrier and observe fringes appear","params":{"barrierEnabled":true}}
  ],
  "hints": [
    {"trigger":"always","message":"No barrier = no interference. The wave spreads freely like a pebble dropped in water."},
    {"trigger":"always","message":"Toggle Double Slit ON. The two slits create two coherent sources 鈥?and the interference pattern emerges!"}
  ]
}
```

### Example 3: Wide Separation = Many Fringes
```json
{
  "scenarioId": "wide-separation",
  "name": "Explore: Wider Slits = More Fringes",
  "screen": "waterDoubleSlit",
  "initialParams": {"frequency":0.4,"amplitude":1.5,"barrierEnabled":true,"slitSize":10,"slitSeparation":36},
  "paramRanges": {"slitSeparation":{"min":24,"max":36,"step":1,"unit":"px"}},
  "successCriteria": [
    {"id":"sc-1","type":"countFringes","description":"Count the bright radial bands at maximum separation","params":{"minSlitSep":34}}
  ],
  "hints": [
    {"trigger":"always","message":"d * sin(theta) = n * lambda: larger d (separation) = more fringes (larger n) within the same angular range."},
    {"trigger":"always","message":"Try reducing separation to 12 and count how many fringes disappear."}
  ]
}
```

### Example 4: High Frequency = Short Wavelength
```json
{
  "scenarioId": "high-freq",
  "name": "Explore: Higher Frequency = More Fringes",
  "screen": "waterDoubleSlit",
  "initialParams": {"frequency":1.0,"amplitude":2.0,"barrierEnabled":true,"slitSize":8,"slitSeparation":20},
  "paramRanges": {"frequency":{"min":0.5,"max":1.0,"step":0.05}},
  "successCriteria": [
    {"id":"sc-1","type":"observePattern","description":"Observe dense fringes at max frequency","params":{"minFrequency":0.8}},
    {"id":"sc-2","type":"compareFrequency","description":"Compare 1.0 vs 0.2: fringe count scales inversely with wavelength","params":{}}
  ],
  "hints": [
    {"trigger":"always","message":"Higher frequency = shorter wavelength. Since wave speed c is fixed, lambda = c/f decreases."},
    {"trigger":"always","message":"This is why blue light (short lambda) produces finer interference patterns than red light (long lambda)."}
  ]
}
```

## Generation Rules

1. `screen` is required and must be `"waterDoubleSlit"` (only screen type in MVP)
2. All `initialParams` have defaults; only override values that differ from default
3. `paramRanges` is optional; override to constrain slider ranges for focused teaching
4. `successCriteria` types:
   - `observePattern` 鈥?student observes the interference pattern (params: `minFrequency`/`maxFrequency`/`barrierEnabled`)
   - `adjustSeparation` 鈥?student changes slit separation and observes effect
   - `toggleBarrier` 鈥?student toggles barrier on/off and compares (params: `barrierEnabled`)
   - `compareFrequency` 鈥?student compares different frequencies
   - `compareSlitSize` 鈥?student compares different slit sizes
   - `countFringes` 鈥?student counts the number of visible bright bands
   - `frequencyReached` / `amplitudeReached` 鈥?generic parameter targets
5. Hints: `trigger="always"` for persistent tips, or condition like `"frequency > 0.7"` for contextual
6. Each scenario should teach ONE clear physics concept from the double-slit experiment
7. Use real-world analogies (water waves, light, sound) to make abstract concepts concrete

## Anti-Patterns to Avoid

- Do NOT set `frequency < 0.1` or `frequency > 1.0` (exceeds sim stability limits)
- Do NOT set `amplitude < 0.2` (wave invisible) or `amplitude > 3.0` (may cause numerical instability)
- Do NOT set `slitSize < 4` or `slitSeparation < 12` (too small to be meaningful)
- Do NOT omit `screen` field
- Do NOT use non-existent `successCriteria` type names
- Do NOT create scenarios where `barrierEnabled=true` but `slitSize` or `slitSeparation` are at extreme values without teaching purpose
- Do NOT use `paramRanges` that exclude the `initialParams` value

## Validation Checklist

- [ ] `scenarioId` is unique among all wave-interference scenarios
- [ ] `screen` = `"waterDoubleSlit"`
- [ ] `initialParams.frequency` in [0.1, 1.0]
- [ ] `initialParams.amplitude` in [0.2, 3.0]
- [ ] `initialParams.barrierEnabled` is boolean
- [ ] `initialParams.slitSize` in [4, 20] (integer)
- [ ] `initialParams.slitSeparation` in [12, 36] (integer)
- [ ] `successCriteria` items have valid `type` enum values
- [ ] At least 1 `hint` entry with physics context
- [ ] Scenario name describes the key physics insight (not just "Scenario N")