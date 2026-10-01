# FINAL_REPORT · Gravity and Orbits

**Status: DONE / READY**  
**Date:** 2026-09-16  
**Source:** local PhET `gravity-and-orbits` **1.7.0-dev.7**（网页仅交叉验证）

---

## 1. 结论

Gravity and Orbits 已完整迁入 KARTOSLAB Flutter，物理以本地源码 PEFRL 为准，UI/交互对齐 Model + To Scale 双屏，已接入 Home「天体力学」。用户反馈的右侧栏溢出与 To Scale 标注缺失已修复。

---

## 2. Gate checklist

| Gate | Result |
|---|---|
| P0 | **0** |
| P1 | **0** |
| Compilation | PASS |
| `flutter test test/gravity_and_orbits` | **16 PASS** |
| `flutter analyze` (sim + Home) | **No issues**（Errors=0 Warnings=0） |
| Physics PEFRL | PASS |
| Clock substeps Slow/Normal/Fast = 1/4/7 × 0.13125 | PASS |
| Orbit regression（2000 frames） | PASS |
| Body labels（viewDiameter ≤ 12） | PASS |
| Scene selector vertical layout（无 overflow） | PASS |
| Assets Substituted | **0** |
| Reset All = `KratosResetAllButton` | PASS |
| Browser QA | PASS |
| Home 接入 | PASS |

---

## 3. 交付物

| 路径 | 内容 |
|---|---|
| `lib/astronomy/gravity_and_orbits/` | Model / Physics / MVT / Painters / Controls / Screens |
| `assets/astronomy/gravity_and_orbits/` | 原版 mipmaps + images PNG |
| `test/gravity_and_orbits/` | 物理 / 轨道 / 标注 回归 |
| `requirements/req-gravity-and-orbits/` | PHASE_0–5、ASSET_MAP、BROWSER_QA、FINAL_REPORT |

**入口：** Home → 天体力学 → **Gravity and Orbits** → `GravityAndOrbitsHome`（Model | To Scale）

---

## 4. 源码对齐要点

- **积分：** PEFRL（ξ/λ/χ），非 Euler / 椭圆公式 / MSS 引擎  
- **力：** \(F = G m_1 m_2 / r^2\)；Model 月球→地球 `fudgeFactor=10200`  
- **时间：** `DEFAULT_DT=36000`；子步按 TimeSpeed  
- **拖拽：** 天体只改 position；速度箭头改 velocity  
- **标注：** `BodyNode` 规则 — 视直径 ≤ 12 显示黄线 + Star/Planet/…  
- **场景选择：** 纵向 radio（修复横向 overflow）

---

## 5. 数据链

```
User Controls → Initial Conditions → PEFRL Physics → SimulationClock
  → Body State → GaoMvt → Renderer / Vectors / Path / Labels / Readouts
```

Trail = `body.path` · Velocity display = `body.velocity` · Force display = `body.force × forceScale`

---

## 6. 收尾修复（相对首版 READY）

| 问题 | 修复 |
|---|---|
| 右侧栏 RIGHT OVERFLOWED BY 136 | 场景选择改为纵向列表 + 选中行旁 reset |
| To Scale 无 Star/Planet 标注 | `GaoBodyLabelsPainter`（≤12px 阈值） |

---

## 7. Known P2（非阻塞）

- 碰撞爆炸芒刺动画细化  
- 速度箭头 view 长度 &lt; 10 时清零  
- 完整 ORIGINAL↔FLUTTER 像素 diff 批跑（manifest 已备）  
- 面板微间距 / Joist chrome（A 类壳层差异）

---

## 8. 判定标签

`[原版资源一致]` `[布局已对齐]` `[动态绘制已对齐]` `[Physics=PASS]` `[Reset=PASS]` `[Lifecycle=PASS]` `[Home=PASS]`

**Final Status: DONE**
