# PHASE7C_AUDIO

> Audio isolation for ZH golden capture — production audio semantics unchanged.

| Simulation | Source Audio | Flutter Audio | Golden Dependency | Resolution |
|---|---|---|---|---|
| circuit | Optional tap SFX | `SoundEffects` + audioplayers | No — audio has no visual effect on default frame | Lazy `AudioPlayer` (construct on first `tap`); screen defers `SoundEffects` until first playback; MethodChannel mocks in 7C test |
| cck-ac-virtual-lab | Optional SFX paths | audioplayers (if present) | No visual dependency for default | Channel mocks + layout overflow fix only |
| beers-law-lab | Concentration faucet drag SFX | `ConcentrationAudio` on home shell | No — inject silent audio | `_SilentConcentrationAudio` in golden harness |
| molarity | Solute / concentration / precipitate cues | `MolarityAudioPlayer` | No — inject recording sink | `RecordingMolarityAudio` (no platform player) |
| friction | Cloth / dish SFX | `AudioPlayer` gated by `enableAudio` | No | Golden uses `enableAudio: false` |
| resistance-in-a-wire | Optional RIAW hooks | Hooks only | No | Seeded `dotRandom` only (visual dots) |
| collision-lab / fourier / QCT / ABS / SoM | N/A or non-blocking | — | Animation / ListTile Material / particles | See PHASE7C_REPORT — not audio |

## Rules followed

- Did **not** mute or alter production audio paths to force golden PASS.
- Did **not** add fake audio where source has none.
- Where audio has no visual impact, isolated via injection / lazy init / mocks.
