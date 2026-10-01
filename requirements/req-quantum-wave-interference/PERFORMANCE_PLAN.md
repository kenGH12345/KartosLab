# PERFORMANCE_PLAN

## Targets

| Context | Target |
|---|---|
| Desktop default | ~60 FPS |
| Mid Android default | ≥30 FPS |
| Stress 10k hits + wave on | ≥30 FPS desktop；Android 可降 graph/wave 质量 |

物理正确性 **≠** FPS：用 fixed/accumulated dt harness 保证。

---

## Workloads

| Item | Default cost | Cap / knob |
|---|---|---|
| Wave grid | 120×120 | `waveSolverGridSize` ≤1000 |
| Wave colorPower | display | query 1.8 / amp×1.5 |
| Detector texture HI/SP | scale 1 | `detectorScreenTextureScale` |
| Detector texture Experiment | scale 2 | `experimentDetectorTextureScale` |
| Hits stored | ≤25000 / scene | `maxHits` |
| Hits rendered | ≤10000 stamps | PhET `MAX_RENDERED_HITS` |
| Graph HI/SP | 200 samples × scale | `detectorPatternGraphSampleScale` |
| Graph Experiment | 8× px | `experimentGraphSamplesPerPixel` |
| Time plot | 600 samples | `timePlotMaxSamples` |
| Position plot | 2× px | `positionPlotSamplesPerPixel` |
| Snapshots | 4 × 4 sources × 3 screens | memory of hits/PDF copies |

---

## Hit storage strategy（Flutter）

优先：

```text
Float32List / typed buffer / Image/Bitmap accumulation
```

禁止：`List<Widget>` per hit。

---

## Solver vs render decoupling

| Path | Rate |
|---|---|
| Solver step | model clock（可能 sub-frame accumulate） |
| Wave raster | dirty \|\| playing |
| Detector intensity | on PDF change |
| Hits texture | incremental stamp on new hits |
| Graph | throttled OK if model PDF unchanged |

---

## Stress plan

| Hits | Checks |
|---|---|
| 100 | functional |
| 1000 | FPS / memory baseline |
| 5000 | FPS |
| 10000 | render cap behavior |
| 25000 | max-hits shutoff + memory |

Also：Fast×16 SP auto-fire long run；HI continuous 5+ minutes。

---

## Snapshot memory

Intensity snapshot：store PDF array（HI）。  
Hits snapshot：copy hit vectors。  
Delete/renumber must release copies。

---

## Risk mitigations

1. Lower grid to 80–100 on low-end Android（显式质量档，不改物理方程）。  
2. Cap rendered hits with reservoir/downsample **仅视觉**，统计仍用全量或声明限制。  
3. Isolate wave raster to background isolate only if profiling 证明需要（Phase 5+）。