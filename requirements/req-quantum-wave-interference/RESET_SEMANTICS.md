# RESET_SEMANTICS

## Reset All

恢复**当前 Screen** 的：

- 全部 4 个 source scenes（参数、hits、snapshots、solver/packet、decoherence）
- playback / TimeSpeed → defaults（playing + NORMAL）
- tools visibility & positions（ruler / tape / stopwatch / plots）
- SP：`detectorProbe.reset()` + probe visibility defaults
- Experiment：detector zoom / scale related view state via view reset helpers

**不**影响其他 Screen 的独立 model。

Flutter：使用 `KratosResetAllButton`（L0），禁止 Material refresh 图标。

---

## Clear Hits / Clear Screen（橡皮擦）

| Family | Clears | Preserves |
|---|---|---|
| Experiment | hits, detector counters, accumulators | wavelength, slits, snapshots?（对照 `clearScreen`——通常保留 snapshots；以 SceneModel.clearScreen 为准） |
| HI | hits + **wave solver reset** + decoherence + pattern formation | source settings；snapshots 通常保留至 Reset All |
| SP | hits + cancel packet；非 auto-repeat 关 emitter | settings；probe 视实现 |

改变 λ / speed / slitSeparation / screenDistance / slitConfiguration → 自动 `clearScreen()`，防止旧 hits 混入新实验。

---

## Clear / Delete Snapshot

- 单张删除 → `renumberSnapshots`
- 删至 0 → 对话框可自动关闭
- Reset All → 清空全部 snapshots（每 scene）

Max：**4 / scene**；满则 Take Snapshot no-op。

---

## Reset Probe

- `DetectorProbe.reset()` → state=`ready`，清除检测结果 UI
- 失败测量留下的 solver projections：随 packet end / scene reset / clear 路径清理（对照 `applyMeasurementProjection` 生命周期）
- Move/resize after Detect → 自动回到 ready

---

## Pause / Step / Speed

| Action | Effect |
|---|---|
| Pause | 停止向 model 注入 dt |
| Play | 恢复 |
| Step（HI/SP） | 固定推进 1/60 model s（经 scene.step，**不受** TimeSpeed 乘子？→ 对照 `stepOnce`：直接 `scene.step(NOMINAL_DT)`，**不**乘 TimeSpeed） |
| Speed | 仅缩放 continuous `step(dt)` 的 effectiveDt |

---

## Emitter OFF vs Clear

HI/SP：关闭发射可清除波/包与 decoherence，但**保留 hits**（与 clearScreen 不同）。对照 `BaseSceneModel` emitter listeners。

---

## Max hits reached

达 `MAX_HITS` → 关闭 emitter；需 clear screen 后才能继续。SP 显示 `MaxHitsReachedPanel`。