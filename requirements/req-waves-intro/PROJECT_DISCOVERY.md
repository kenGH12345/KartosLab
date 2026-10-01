# PROJECT_DISCOVERY — Waves Intro

> req-id: `req-waves-intro` · waves-intro **1.2.0-dev.0**

## 结论摘要

PhET Waves Intro 是 thin shell：3 个 `MediumScreen`（Water / Sound / Light），每个只挂一个 `WavesModel` scene。物理与 UI 控件来自 **wave-interference**；晶格步进来自 **scenery-phet Lattice**。

## 本地证据

| 项 | 标记 | 说明 |
|---|---|---|
| 版本 | [已确认] | `phet sourses/waves-intro-main/waves-intro-main/package.json` → `1.2.0-dev.0` |
| 3 Screens | [已确认] | `waves-intro-main.ts`：Water / Sound / Light；默认 Water（首屏） |
| WI clone SHA | [已确认] | `wave-interference-for-waves-intro` git HEAD = `5443da0…` |
| deps.json SHA | [待确认] | 文档记录存在 SHA mismatch 风险；以 clone HEAD 为准 |
| 物理归属 | [已确认] | `WavesModel` / `Scene` / `SoundScene` / `TemporalMask` 在 WI；`Lattice` 在 scenery-phet |
| Flutter 落点 | [已确认] | 仅 `lib/waves_intro/` + Home 单条入口；不抽 `lib/common` 波动框架 |

## 范围边界

- **做**：点源连续/脉冲、振幅/频率、晶格热图、中心线图、声波粒子（seeded）、三介质 Tab
- **不做（本期）**：卷尺 / 秒表 / 波表 / a11y / 水滴水龙头动画 / 侧视 / 双源

## 入口

Home → 物理 → 光学与波动 → **Waves Intro**
