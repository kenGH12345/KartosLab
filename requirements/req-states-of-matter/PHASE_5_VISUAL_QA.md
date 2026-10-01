# PHASE 5 — Visual QA · States of Matter

Status: **ORIGINAL 15/15 + smoke · FLUTTER 15/15 · DIFF 15/15** (2026-09-15)  
Attribution: `DIFF_ATTRIBUTION.md` · Visual Gate (content): **PASS**

## Source caveat

| 角色 | 来源 |
|---|---|
| PRIMARY behavior | 本地 **1.3.0-dev.3** |
| Visual ORIGINAL | published latest（本地 HTML unbuilt） |

## Renderer probe

Published build: **Scenery** (`canvas:0`, `svg:4`) — ready = `phet.joist.sim.screenProperty`，**不要**死等 canvas。

## Capture

| 侧 | 命令 |
|---|---|
| ORIGINAL | `tool\run_som_original_capture.bat`（tandem click/drag） |
| FLUTTER | `tool\run_som_capture.bat` |
| DIFF | `tool\run_som_diff_all.bat` |

所有帧 **paused**。

## Matrix

| id | Screen |
|---|---|
| 01–09 | States |
| 10–12 | Phase Changes |
| 13–15 | Interaction |
| smoke_test | ORIGINAL only |

## Visual Gate

- B (Simulation Content) P1 cleared: TimeControl, `14 K` ComboBox, container bevel, pump, orange Reset  
- A (Joist bottom bar / framing): known — **not modified**  
- Residual P2: heater art, diagram chrome  

→ **Visual Gate = PASS**（Simulation Content）
