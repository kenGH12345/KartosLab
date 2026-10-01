# Phase 9 Visual QA — Progress

> 2026-09-10

## PHASE: 9
## STATUS: IN PROGRESS（几何锚点优先；缺原版 runtime 截图）

### Evidence available
| 源 | 状态 |
|---|---|
| 官方营销截图 screen1/screen2 | `[已确认]` 在 `visual-qa/phet-screenshots/` |
| 原版 HTML 实时运行截图 | **`[待确认：缺少原版运行截图]`** — 本机无完整 PhET deps 构建 |
| Flutter 运行截图 | `[待确认]` 本轮未写入 golden（需设备/模拟器手动或 integration） |

### P0/P1 已按源码处理（非贴截图）
- MVT Intro (0.5W, 0.85H)×1700；Systems (0.5W, 0.475H)×2200
- Ground spots / burner 支撑面 / beaker 尺寸来自源码常量
- 禁止按营销图硬编码大量 offset（当前 Positioned 由 MVT 推导）

### P2+ remaining
- HeaterCooler / Faucet 外观 **[BLOCKED D]**
- Systems 元件局部锚点（wheel center、wire）需对照各 *Node.ts
- Intro EC 三维切片分布视觉

### Overlay / Diff
未执行（缺成对 runtime 截图）。下一步：若可启动原版或抓取 online sim 帧，再做 rect overlay。

### Next
Phase 10 汇总报告；继续补帧动画与 EC balance。
