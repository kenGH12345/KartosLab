# PHASE_1_REPORT — Capacitor Lab Basics

> 日期：2026-09-12  
> 阶段：1 · Intake / Source Analysis  
> 状态：**PASS → 自动进入 Phase 2**

---

## 1. 完成物

| 文件 | 状态 |
|------|------|
| `SOURCE_ANALYSIS.md` | DONE |
| `SOURCE_TO_FLUTTER_MAP.md` | DONE |
| `ARCHITECTURE_PLAN.md` | DONE |
| `SOURCE_BEHAVIOR_MATRIX.md` | DONE |
| `ASSET_MAP.md`（含六图深挖） | DONE |
| `VISUAL_ASSET_POLICY.md` | DONE |
| `spec/需求简述.md`（AC-01…14） | DONE |
| `meta.yaml` / `process.txt` | 已更新 |

本阶段：**未**大规模 Flutter 编码；**未**拷贝 assets 进工程。

---

## 2. 自动检查（本地脚本）

```
CHECKS: 38/38 PASS
```

覆盖：

- 全部 Phase 1 交付文件存在
- 6 PNG intrinsic 尺寸匹配
- 关键源文件存在
- `EPSILON_0` / 电池范围 / 背景色 / R=5e12
- MVT scale=12000 / yaw
- probe scale 0.25 / body 0.336 / battery graphic 0.30
- discharge `Math.exp` / ½CV² 存在于 Capacitor.js
- 文档 STATUS / 行为矩阵关键词

脚本可复跑：对 `requirements/req-capacitor-lab-basics` + PhET 源做存在性与常量断言。

---

## 3. 关键证据摘要

| 主题 | 结论 |
|------|------|
| 结构 | 双屏；共享 `switchUsedProperty` |
| 画布 | 1024×618；MVT 12000 / 30° / −45° |
| 物理 | C=ε₀A/d；Q=CV；U=½CV²；E=V/d；放电 exp(−dt/RC), R=5e12 |
| 原图×6 | probeBlack/Red, voltmeterBody, switchCueArrow, capacitanceScreenIcon, lightBulbBase |
| Canvas | 电池/板/场/电荷/线/表/手柄/开关几何 — 均有源码常量 |
| 架构决策 | **无阻塞人工决策**（专用 ParallelCircuit，不用 CCK 网表） |

---

## 4. 残余 `[待确认]`（不阻塞 Phase 2）

1. joist `DEFAULT_LAYOUT_BOUNDS` 本地无 joist 源（有 CLBModel 1024×618）
2. Capacitance 2-connection 下 snap 右区运行时细节
3. mipmap 多分辨率层（仅主 PNG 已测）

`PhetColorScheme.RED_COLORBLIND`：项目他处已用 **rgb(255,85,0)** — Phase 2 写入 `clb_colors.dart` 并对照 `PhetColorScheme.ts`。

---

## 5. Visual / Asset 阶段声明

```
Assets (Phase 1 规划，尚未打包):
Original Assets Reused:   6 (计划)
Original SVG Reused:      0
Original PNG Reused:      5 (+1 scenery-phet mipmap base)
Original Mipmap Reused:   1 (+ bulb base from scenery-phet)
Canvas Reconstructed:     (计划：battery/plates/field/charge/wires/bars/handles/…)
Custom Assets:            0
Substituted Assets:       0
```

视觉判定：**本阶段不做 Visual PASS**（尚无 Flutter UI）。政策已锁定为：

`[原版资源一致]` 为目标；禁止截图写死像素。

---

## 6. Go / No-Go

| 项 | |
|----|--|
| 行为证据充分？ | **Yes** |
| 坐标/锚点充分？ | **Yes**（面板锚点 + MVT + 模型位） |
| 资产策略清晰？ | **Yes** |
| 人工架构决策？ | **No** |
| **进入 Phase 2** | **GO** |

Phase 2 起步（自动）：`clb_constants` / `clb_colors` / `clb_strings` / 电路枚举 + Capacitor 纯函数与 unit test；**随后**拷贝 6 PNG（仍不做大规模 Painter / Home 集成，直到模型测试通过）。
