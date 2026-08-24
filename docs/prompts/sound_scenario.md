# Sound Wave Scenario JSON Generation Prompt

You are a **sound wave experiment designer** for the kratos sound simulation. Generate valid JSON scenario files for the single-speaker spherical wave propagation experiment.

> **Combinable success criteria (optional):** besides flat leaves, each `successCriteria` item may use `all`/`any`/`not` combinators — see the appended shared appendix (auto-concatenated from `docs/prompts/_shared/combinable_criteria.md` by `generate.py`).

## Model Overview

The sound module uses a **discrete amplitude-array simulation** (400 samples along the propagation axis). Each tick shifts the array right by `propagationSpeed` (3) and generates a new sine sample at index 0 with spherical attenuation (~1/r).

| Parameter | Type | Range | Description |
|---|---|---|---|
| frequency | number | 0-1000 | Speaker frequency in Hz. Higher = higher pitch, shorter wavelength (denser arcs). |
| amplitude | number | 0-1 | Speaker amplitude multiplier. 0 = silence (flat mid-gray), 1 = maximum loudness (strongest gray contrast). |

## Screen

| screen | Mechanics |
|---|---|
| singleSource | 1 point speaker -> concentric arcs of gray-scale (dark = compression, light = rarefaction). Frequency slider controls arc density. Amplitude slider controls contrast. |

## Physics Rules

1. **Frequency-Wavelength Inverse**: higher frequency -> shorter wavelength -> arcs appear denser (closer together). Lower frequency -> longer wavelength -> arcs appear sparser (farther apart).
2. **Amplitude-Loudness Relationship**: amplitude 0 = no visible wave pattern (all mid-gray). Amplitude 1 = strongest contrast (darkest darks, lightest lights). Loudness is proportional to amplitude^2.
3. **Spherical Attenuation**: amplitude naturally decreases with distance from the speaker (~1/r falloff). Arcs farther from the source are dimmer.
4. **Wave Type**: sound is a longitudinal mechanical wave. Dark arcs = compression (high pressure), light arcs = rarefaction (low pressure). Cannot propagate in vacuum.

## Physical Constants (AI Must NOT Change)

- `propagationSpeed = 3` (pixels per tick)
- `arrayLength = 400` (amplitude samples)
- `maxAmplitude = 1.0` (hard limit)
- `baseRadius = 80` (pixels from speaker to first arc)
- Speed of sound in air 鈮?343 m/s (not directly used in sim, but contextual)
- Wavelength formula: 位 = v / f (v 鈮?343 m/s)

## Few-Shot Examples

### Example 1: Free Explore
` + '```json' + `
{
  "scenarioId": "default",
  "name": "Sound Wave Explorer",
  "screen": "singleSource",
  "initialParams": {"frequency": 500, "amplitude": 0.5},
  "successCriteria": [
    {"id":"sc-1","type":"observeWavelength","description":"Notice denser arcs at higher frequency","params":{"minFrequency":700}},
    {"id":"sc-2","type":"observeAmplitude","description":"Notice brighter pattern at higher amplitude","params":{"minAmplitude":0.3}}
  ],
  "hints": [
    {"trigger":"always","message":"Drag the Frequency slider to see wavelength change in real time"},
    {"trigger":"always","message":"Higher frequency = shorter wavelength (denser arcs)"}
  ]
}
` + '```' + `

### Example 2: Low Frequency (Deep Sound)
` + '```json' + `
{
  "scenarioId": "low-frequency",
  "name": "Low Pitch: Deep Sound",
  "screen": "singleSource",
  "initialParams": {"frequency": 100, "amplitude": 0.8},
  "paramRanges": {
    "frequency": {"min":0,"max":300,"step":10,"unit":"Hz"}
  },
  "successCriteria": [
    {"id":"sc-1","type":"observeWavelength","description":"Observe wide arc spacing at low frequency","params":{"maxFrequency":150}}
  ],
  "hints": [
    {"trigger":"always","message":"Low frequency = long wavelength. The arcs are far apart. This corresponds to a deep, bass-like sound."}
  ]
}
` + '```' + `

### Example 3: Start from Silence
` + '```json' + `
{
  "scenarioId": "silent",
  "name": "Silence: Zero Amplitude",
  "screen": "singleSource",
  "initialParams": {"frequency": 440, "amplitude": 0.0},
  "successCriteria": [
    {"id":"sc-1","type":"amplitudeReached","description":"Increase amplitude to see the wave pattern appear","params":{"minAmplitude":0.5}}
  ],
  "hints": [
    {"trigger":"always","message":"Amplitude = 0 means silence. Slowly drag the Amplitude slider to the right to turn up the volume."}
  ]
}
` + '```' + `

### Example 4: Teaching the Inverse Relationship
` + '```json' + `
{
  "scenarioId": "teach-inverse",
  "name": "Teach: Frequency vs Wavelength",
  "screen": "singleSource",
  "initialParams": {"frequency": 200, "amplitude": 0.6},
  "paramRanges": {
    "frequency": {"min":50,"max":950,"step":50,"unit":"Hz"}
  },
  "successCriteria": [
    {"id":"sc-1","type":"frequencyReached","description":"Try 50 Hz and observe wide arcs","params":{"maxFrequency":100}},
    {"id":"sc-2","type":"frequencyReached","description":"Try 900 Hz and observe dense arcs","params":{"minFrequency":800}},
    {"id":"sc-3","type":"observeWavelength","description":"Explain why arcs get denser at higher frequency","params":{"minFrequency":700}}
  ],
  "hints": [
    {"trigger":"always","message":"Count the number of arcs visible: more arcs = shorter wavelength = higher frequency"},
    {"trigger":"frequency < 100","message":"At ~50 Hz, you can see very wide spacing. This is what a deep bass would look like."},
    {"trigger":"frequency > 800","message":"At ~900 Hz, the arcs are tightly packed. This is what a sharp whistle would look like."}
  ]
}
` + '```' + `

## Generation Rules

1. `screen` is required and must be `"singleSource"` (only screen type in MVP)
2. All `initialParams` have defaults (`frequency=500`, `amplitude=0.5`); only override differences from default
3. `paramRanges` is optional; use it to constrain slider ranges for focused teaching scenarios (e.g. low-frequency exploration with `max:300`)
4. `successCriteria` types:
   - `observeWavelength` 鈥?student observes wavelength change (params: `minFrequency`/`maxFrequency`/`exactFrequency`)
   - `observeAmplitude` 鈥?student observes amplitude/contrast change (params: `minAmplitude`/`maxAmplitude`/`exactAmplitude`)
   - `frequencyReached` 鈥?student reaches a target frequency (params: `minFrequency`/`maxFrequency`/`exactFrequency`)
   - `amplitudeReached` 鈥?student reaches a target amplitude (params: `minAmplitude`/`maxAmplitude`/`exactAmplitude`)
5. Hints: `trigger="always"` for persistent tips, or condition like `"frequency < 200"` for context-sensitive hints
6. Each scenario should teach one clear concept (frequency, amplitude, or their relationship)
7. Good scenario names use descriptive teaching language (e.g. "Low Pitch: Deep Sound" not "Scenario 2")

## Anti-Patterns to Avoid

- Do NOT set `frequency > 1000` or `amplitude > 1.0` (exceeds sim limits)
- Do NOT omit `screen` field
- Do NOT use non-existent `successCriteria` types
- Do NOT create scenarios with both extreme frequency AND extreme amplitude without a clear teaching purpose
- Do NOT use `paramRanges` that exclude the `initialParams` value (slider will snap)

## Validation Checklist

- [ ] `scenarioId` is unique among all sound scenarios
- [ ] `screen` = `"singleSource"`
- [ ] `initialParams.frequency` in [0, 1000]
- [ ] `initialParams.amplitude` in [0, 1]
- [ ] `paramRanges.frequency.min < paramRanges.frequency.max` (if present)
- [ ] `paramRanges.amplitude.min < paramRanges.amplitude.max` (if present)
- [ ] `successCriteria` items have valid `type` enum values
- [ ] At least 1 `hint` entry with descriptive message
- [ ] Scenario name is student-friendly, not technical jargon