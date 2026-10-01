# VISUAL_ASSET_AUDIT — Quantum Wave Interference

Source tree: `phet sourses/quantum-wave-interference-main/quantum-wave-interference-main`  
scenery-phet tape: `phet sourses/scenery-phet/images/measuringTape_png.ts`

## Inventory

| Asset | Source path | Used by screen | Used by node | Flutter destination | Reuse / redraw / unavailable | Status | P |
|---|---|---|---|---|---|---|---|
| photon.svg | `images/photon.svg` | All | SceneRadioButtonGroup | `assets/.../images/photon.svg` | **reuse** | DONE | — |
| electron.svg | `images/electron.svg` | All | SceneRadioButtonGroup | same | **reuse** | DONE | — |
| neutron.svg | `images/neutron.svg` | All | SceneRadioButtonGroup | same | **reuse** | DONE | — |
| heliumAtom.svg | `images/heliumAtom.svg` | All | SceneRadioButtonGroup | same | **reuse** | DONE | — |
| singleParticleEmitter.svg | `images/singleParticleEmitter.svg` | SP | SingleParticleEmitterNode | same | **reuse** (available) | PARTIAL — fire button still circle chrome | P2 |
| experimentScreenIcon.svg | `images/experimentScreenIcon.svg` | Home (future) | ExperimentScreen | same | **reuse** | deferred Home | P2 |
| highIntensityScreenIcon.svg | `images/highIntensityScreenIcon.svg` | Home | HighIntensityScreen | same | **reuse** | deferred Home | P2 |
| singleParticlesScreenIcon.svg | `images/singleParticlesScreenIcon.svg` | Home | SingleParticlesScreen | same | **reuse** | deferred Home | P2 |
| measuringTape.png | scenery-phet `measuringTape_png.ts` | HI / SP | MeasuringTapeNode | `assets/.../images/measuringTape.png` | **reuse** (decoded from source) | DONE | — |
| snapshotCaptured.mp3 | `sounds/snapshotCaptured_mp3.js` (base64) | All | SnapshotButton | `assets/.../sounds/snapshotCaptured.mp3` | **reuse** (decoded from source) | DONE | — |
| Slit / barrier / detector | program Path/Shape | Exp / HI / SP | *SlitNode / WaveBarrier | CustomPainter geometry | **redraw** from source geometry | DONE (no bitmap) | P2 pixel |
| Wave field | FieldSample raster | HI / SP | WaveVisualizationCanvasNode | WaveFieldRenderData blit | **redraw** (solver→RGBA) | DONE | P2 opt |
| Probe circle / panel | Circle + Panel + wire | SP | DetectorProbeNode | `QwiProbeNode` | **redraw** from source colors/layout | DONE | P2 chrome |
| Reset All | scenery-phet ResetAllButton | All | ResetAllButton | `KratosResetAllButton` L0 | **reuse** L0 | DONE | — |
| IntensityGraph.svg | design mockup ref only | Exp | GraphAccordionBox | Canvas graph | **redraw** | DONE | P2 |
| .ai design masters | `assets/*.ai` | design | — | — | **unavailable** in runtime | N/A | — |

## Rules applied

1. No AI-generated / forged assets masquerading as PhET originals.
2. Base64-decoded `snapshotCaptured.mp3` and `measuringTape.png` are **original** PhET payloads from source modules.
3. Program-drawn scenery (slits, wave, probe fill) follows TypeScript geometry/colors — not Material icons.
4. Font: PhET `PhetFont` ≈ Arial/Helvetica; Flutter uses `Arial` with platform fallback → **P2 font provenance**.

## Conversion notes

| Asset | Conversion |
|---|---|
| snapshotCaptured.mp3 | Extracted via `tooling/extract_qwi_snapshot_mp3.py` from data-URI in JS |
| measuringTape.png | Extracted via `tooling/extract_qwi_measuring_tape_png.py` from scenery-phet TS |
| SVGs | Byte-copied from `images/` without modification |
