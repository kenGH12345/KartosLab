# PHASE_2_REPORT — Capacitor Lab Basics

> 2026-09-12 · Phase 2 Model / Circuit  
> **STATUS: PASS → 进入 Phase 3**

---

## 1. 范围遵守

| 禁止项 | 遵守 |
|--------|------|
| 大规模 Painter | ✓ 未做 |
| Static Render | ✓ 未做 |
| Home Integration | ✓ 未做 |
| 重构 common | ✓ 未改 |
| 修改其他 Simulation | ✓ 未改 |

---

## 2. 门禁结果

| 检查 | 结果 |
|------|------|
| `dart analyze lib/capacitor_lab_basics test/capacitor_lab_basics` | **No issues found** |
| `flutter test test/capacitor_lab_basics` | **27/27 PASS** |
| Architecture consistency | SSOT 分层清晰；双屏独立 circuit + 共享 switchUsed；无 UI 字段污染物理 Model |
| Regression | 仅本包测试；无跨 sim 变更 |
| Asset policy | 6 PNG 仍在；Substituted=0；本阶段无新替代素材 |

---

## 3. 实现摘要

- `ParallelCircuit` / `CapacitanceCircuit` / `LightBulbCircuit`
- `ClbModel` + `ClbSharedState`
- `CapacitanceModel` / `ClbLightBulbModel`
- Unit：物理公式 8 + 电路/双屏 19 = **27**

证据与缺口见 `MODEL_REPORT.md`。

---

## 4. Architecture consistency checklist

- [x] 公式/默认/range 均可追溯 PhET `file`（见 SOURCE_ANALYSIS / MODEL_REPORT）
- [x] 无 RenderData / Painter 状态复制
- [x] Capacitance 与 Light Bulb **未**合并不同连接态行为
- [x] Reset 顺序对齐各屏源码
- [x] `ClbColors` 仅供后续 View；Model 用 `CurrentArrowStyle` 枚举

---

## 5. Phase 3 入口

按 `ARCHITECTURE_PLAN.md`：

> Phase 3 — MVT + Circuit 静态渲染（电池/板/线/开关）；双屏壳（仍无 Home 集成可选骨架）

优先：`YawPitchMvt` + BatteryGraphic / Plate 的 **源码常量 Painter**（原图组件仍 `Image.asset`）。  
**不**提前做交互完整化或 Home 注册，除非 Phase 3 计划明确需要。
