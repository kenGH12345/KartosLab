# STRING_MAP — Accessibility & i18n

Source: `quantum-wave-interference-strings_en.yaml` (+ generated `QuantumWaveInterferenceStrings.ts` / Fluent)

## Policy

- 禁止硬编码英文 UI 字符串。
- 优先导入原版 key → KartosLab i18n 架构。
- a11y 字符串体量很大；PHASE 2+ 按屏逐步接入。

---

## Key categories

| Category | Examples | Notes |
|---|---|---|
| Sim / screens | `quantum-wave-interference.title`, `screen.experiment.name`, `screen.highIntensity.name`, `screen.singleParticles.name` | Home + tab titles |
| Source types | photons, electrons, neutrons, heliumAtoms, `*Source` | radios / labels |
| Controls | intensity, hits, brightness, wavelength, speed, slit configuration labels, auto-repeat, wave display modes | panels |
| Slit orientations | coverLeft/Right vs coverTop/Bottom；detectorLeft/Right vs Top/Bottom | Experiment vs wave-region wording |
| Mass annotations | electron/neutron/helium HTML mass labels | ParticleMassAnnotationNode |
| Snapshots | snapshot heading/label/number；`snapshotSlitConfiguration.*` | dialog metadata |
| Probe | probability, detect, reset detector, size | SP |
| Tools | ruler, measuring tape, stopwatch, plots | checkboxes |
| a11y.* | screen summaries, responses, slider descriptions, pattern kinds, clock speed | majority of YAML |

---

## Keyboard / Focus（源码事实）

`QuantumWaveInterferenceKeyboardHelpContent` **仅**包含通用 PhET sections：

- Move Draggable Items
- Slider Controls
- ComboBox
- Time Controls
- Basic Actions（含 checkbox）

**未**定义自定义快捷键表 → Flutter **不得发明** Pause/Step/Ruler 专有快捷键，除非后续对照 scenery 默认行为并文档化。

Focus 目标（移植时）：source controls、barrier/slit、detector/graph、ruler/tape、probe、time controls、snapshots。

---

## Sample control → string roles

| UI | String role |
|---|---|
| Intensity / Hits switch | detection mode labels |
| Both Slits Open / Covered / Detectors / No Barrier | slit configuration |
| Auto-fire Mode | SP autoRepeat |
| Detect / Reset Detector | probe actions |
| Take Snapshot / View Snapshots | camera / eye |
| Screen brightness | percent |