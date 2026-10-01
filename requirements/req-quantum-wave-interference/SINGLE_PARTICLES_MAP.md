# SINGLE_PARTICLES_MAP — Highest-Risk Screen

Screen: **Single Particles**  
Model: `SingleParticlesModel` → 4× `SingleParticlesSceneModel` → `SingleParticleSolver`  
View: `SingleParticlesScreenView`

---

## Purpose

一次发射一个量子波包；屏上每次完成探测产生 **一个** 局域 hit；多次重复积累干涉/衍射图案。

---

## Emission

| Item | Value / Behavior |
|---|---|
| Manual emit | `emitPacket()` if no active packet & under max hits |
| Auto Repeat | `autoRepeatProperty` default **false** |
| Min interval | `MIN_EMISSION_INTERVAL = 0.3` s |
| On emit | Sample `targetDetectionTime` (+ optional on-slit time)；reset solver with active packet |
| On detect | Sample 1 hit from detector PDF；`endPacket()` |
| Auto-repeat after end | Keep emitting；wait ≥0.3 s；emit next |
| Non-auto after end | Turn emitter off |

---

## Wave packet

| Param | Constant | Value |
|---|---|---|
| Traversal time | `WAVE_PACKET_TRAVERSAL_TIME` | 1.5 s |
| σx / σy fraction | `WAVE_PACKET_SIGMA_*_FRACTION` | 0.15 |
| Start offset | `WAVE_PACKET_START_OFFSET_SIGMAS` | 2 |
| Re-emission advance | `WAVE_PACKET_RE_EMISSION_TIME_ADVANCE_SIGMAS` | 1.5 |
| Longitudinal spread | `WAVE_PACKET_LONGITUDINAL_SPREAD_TRAVERSALS` | 2.5 |
| Transverse spread | `WAVE_PACKET_TRANSVERSE_SPREAD_TRAVERSALS` | 1.5 |

Display speed ∝ `regionWidth / 1.5 * (v / v_default)`。

---

## Detection timing

`SCREEN_DETECTION_TIMING_PARAMETERS`:

```text
startWeight: 0.30
peakWeight: 0.50
endWeight: 0.70
leadingPower: 1.0
trailingPower: 1.0
```

1. Acceptance-rejection on weight curve（最多 100 次；失败 → peakWeight）
2. `inverseStandardNormalCDF(weight) * sigmaX0` → 时间偏移  
证据：`SingleParticlesSceneModel.sampleScreenDetectionWeight`

---

## Detector screen

- Mode：**always Hits**（无 Intensity toggle）
- Graph：hits histogram，默认 zoom max
- Max hits：25000

---

## Which-path / slits

Uses full `SlitConfigurationWithNoBarrierValues`（含 detectors + noBarrier）。  
每包最多一次 on-slit 交互：

| Case | Behavior |
|---|---|
| Selected slit has detector | Increment detector count；`startPacketReEmission` from that slit |
| Selected slit has no detector | `addDecoherenceEvent`；downstream from that path |
| bothOpen, no detector | Coherent double-slit packet |

（文件头注释写 “no detector variants” 已过时——以 Property validValues 与 decoherence 代码为准。）

---

## Detector Probe

| Item | Detail |
|---|---|
| Availability | `slitConfiguration === 'noBarrier'` only |
| Default position | (0.5, 0.5) normalized |
| Default radius | 0.1；range [0.06, 0.3] |
| Probability | ∫_circle \|ψ\|² / ∫_all \|ψ\|² |
| Detect success | `U < p` → state=`detected`；**end packet**；**no screen hit** |
| Detect fail | state=`notDetected`；`applyMeasurementProjection`（bite + renorm） |
| Reset Detector | Clear probe state；projection 行为对照 `DetectorProbe.reset` / scene |
| Move/resize after result | Auto return to `ready` |

**禁止** `Random.nextBoolean()` 无概率。

---

## Time controls

| Speed | Factor |
|---|---|
| Slow | 0.15 |
| Normal | 0.7 |
| Fast | **16** |
| Step | fixed dt = 1/60 |

Fast 极大加速积累；Slow 观察波包。

---

## Snapshots

- Max 4 / scene
- Always `detectionMode: 'hits'`
- Stores hit list + metadata；`intensityDistribution: []`

---

## Tools

Measuring tape（μm/nm by region）、stopwatch、time plot、position plot、probe。  
**无** Experiment mm ruler。

---

## Flutter isolation requirements

必须独立模块（不得塞进巨型 Screen widget）：

```text
single_particles/
  model/   SingleParticlesModel, SceneModel, DetectorProbe
  solver/  SingleParticleSolver (+ shared WaveKernel)
  render/  packet_renderer, probe_renderer, hit_renderer, graph_renderer
  view/    SingleParticlesScreen
```

---

## Acceptance user path

```text
Single Particles
→ choose particle
→ Auto Fire ON → observe accumulation → OFF
→ emit single particle → watch packet → hit
→ No Barrier → show Probe → move → Size → Detect (success/fail)
→ Detect again / Reset Detector
→ Graph / Snapshot ×4 / Ruler(tape) / Pause / Step / Speed
→ Reset All
```

---

## Test priorities (Phase 1+)

1. Packet traversal time vs speed scale  
2. Detection timing distribution reproducibility (seeded)  
3. Double-slit accumulation → interference-like histogram  
4. Single-slit → diffraction-like（无细条纹）  
5. Probe p integral + Bernoulli + projection renorm  
6. Auto-fire min interval 0.3 s  
7. Max hits shutoff  
8. Fast=16× does not break determinism under fixed dt harness