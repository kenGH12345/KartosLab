# My Solar System · Flutter 迁移经验（已验证）

> 来源：`req-my-solar-system` · Phase 2 Build Loop 1–6 + Phase 3 Close · 2026-09-02  
> 代码：`lib/astronomy/my_solar_system/` · 测试：135 passed  
> **只记录本项目实际验证过的经验，不含推测。**

---

## 1. 物理 · PEFRL N-body

### 引擎选择

My Solar System 是 **N-body PEFRL**，不是两体椭圆解析。  
**禁止**引入 Kepler 的 `EllipticalOrbitEngine` — MSS 与 Kepler 共用 `solar-system-common` 可见性/布局二次证据，但求解器完全不同。

### 已验证与 MSS 一手源码一致的部分

| 项 | 值 / 行为 | 源 |
|---|---|---|
| PEFRL XI/LAMBDA/CHI | 见 `MySolarSystemConstants` | `NumericalEngine.ts` |
| `engineTimeScale` | 0.05 | `MySolarSystemModel.ts` |
| `iterationCount` | 4000 / N active bodies | `NumericalEngine.run` |
| acceleration reuse | 每 k 外层迭代算一次 F→a，五步共用同一 `accelerations[i]` | TS 注释 + Dart 结构对照 |
| `stepOnce` | dt×timeSpeed → ceil(dt×30) 子步 → ×0.05 → run + collision + path | `MySolarSystemModel.ts` |
| collision | 小体 `isActive=false`；大体 `v += v_small × m_small/m_large`；**不合并质量** | `NumericalEngine.ts` |
| d=0 引力 | 返回零向量 | 同 |

### G 常数

本机无 `solar-system-common` 一手字面量。采用 **Kepler 二次证据** `G=4.45669`（`EllipticalOrbitEngine.INITIAL_G`）。  
`doc/model.md` 的 `4.4567e-3` 与 SUN_PLANET 初速不自洽 — **已弃用**。见 `requirements/req-my-solar-system/G-SOURCE-OF-TRUTH.md`。

### 数值回归策略

目标：**Flutter 输出与当前 Dart NumericalEngine 端口一致**，不是证明物理理论。

- 固定 Sun+Planet 初值 + `stepOnce(1/8)` golden（1 step / 100 steps）
- 机械能用相对漂移阈值（<5%），避免 PE 双计
- `numerical_regression_test.dart` 锁定

---

## 2. 架构 · Solver / Render 分离

```
Controller (ChangeNotifier)
  ├─ NumericalEngine (纯 Dart)
  ├─ 状态：preset / drag / visibility / time
  └─ _renderData() → MssRenderData
         └─ Painters 只读（无 updateForces）
```

**已验证原则**：Physics once → RenderData once → multiple painters consume.

Screen 用 `SimulationClock` 60fps tick → `controller.tick(dt)` → 内部 `stepOnce`.

### MssRenderData

- `BodyRenderDot`：position, velocity, **gravityForce**（力，非 acceleration）, path, offscale flags
- `gravityArrowScale` / `velocityArrowScale` 在 DTO 层预计算，Painter 不重复算

### Preset JSON

- `assets/scenarios/my-solar-system/manifest.json` +  per-scenario JSON
- `MssScenarioManager extends ScenarioManagerBase`（L0 复用）
- `loadScenario()` 驱动 body 初值 + Four Star Ballet `gravityForceScalePower=-1.1`
- 禁止 `if (preset == n)` 硬编码（特例通过 JSON 字段）

### TemporaryImplementations

`config/temporary_implementations.dart` 索引所有 TEMPORARY/BLOCKED 替身，字面量在 `MySolarSystemConstants`。

---

## 3. 迁移 · solar-system-common 缺失

### 事实

MSS `package.json` 依赖 `solar-system-common`，本机 trees 无该库（与 Kepler req 相同根因）。

### 已验证的处理方式

1. **一手 MSS 源码优先**：PEFRL、`engineTimeScale`、preset、Follow CoM 条件、Four Star Ballet -1.1
2. **Kepler 二次证据**：G、MVT Y-up、VectorNode scale、`velocityMinMagnitude`、grid/tape 默认值 — 标签 `[KEPLER-SECONDARY]`
3. **TEMPORARY 替身 + 测试**：AABB drag、\|r\|>50 offscreen、800 path points、overlap nudge — **Close 阶段未猜测 common 算法**
4. **BLOCKED 保留**：`centerOrbitOffset` 父类映射、`MAX_PATH_DISTANCE`、`getClosestPoint` — 文档明示，Flutter 不声称视觉一致

### 为何不复用 EllipticalOrbitEngine

Kepler sim 用解析椭圆 + 开普勒第三定律；MSS 用 PEFRL 数值积分处理任意 N-body 配置（双星、特洛伊、双曲线等）。  
引入 EllipticalOrbitEngine 会改变数学语义，与 AC-3 冲突。

---

## 4. 测试 · 已验证模式

| 类型 | 文件 | 用途 |
|---|---|---|
| Engine unit | `engine_test.dart` | PEFRL step、collision、G |
| Numerical golden | `numerical_regression_test.dart` | Sun+Planet 位置/时间/能量/vector |
| Long-run stability | `loop6_physics_audit_test.dart` | 8 preset × 200 steps，无 NaN/爆炸 |
| State machine | `loop4/loop5_*_test.dart` | preset、Reset 语义、Custom |
| Responsive | `screen_test.dart` | 375/1024/1920 overflow + 截图 |
| MVT/drag | `mvt_and_drag_test.dart` | 坐标变换、AABB 约束 |

**性能**：Stopwatch 阈值测试（非 CI benchmark）；2/3/4 bodies + Four Star Ballet 单步 <200–300ms 宽容阈值。

**Reset 语义（已测）**：

- **Clear**：time=0 + paths，body 保持
- **Return Bodies** = **restart**：恢复 `_starting` 快照
- **Reset All**：UI 默认 + sun_planet + restart
- Preset 切换：保留 zoom/visibility/speed

---

## 5. L0 复用结论（实测）

| 复用 | 未复用及原因 |
|---|---|
| `SimulationClock`, `ArrowPainter`, `ScenarioManagerBase`, `KratosComboBox`, `NineGridLayout` | `TimeControlBar`（缺 MSS 语义）；通用 MVT（sim 专用 Y-up + offset BLOCKED） |

---

## 6. 已知差异（Close 确认）

不得声称为与 PhET 原版完全一致：

- `centerOrbitOffset` — BLOCKED，Flutter 忽略
- Path — TEMPORARY 点数 cap ≠ `MAX_PATH_DISTANCE`
- Drag — TEMPORARY AABB
- Offscreen — TEMPORARY \|r\|>50，physics 仍运行
- Collision prevent — TEMPORARY nudge
- Vector offscale 几何 — INFERRED/BLOCKED

完整清单：`requirements/req-my-solar-system/CLOSE_REPORT.md`

---

## 7. 参考路径

| 文档 | 路径 |
|---|---|
| Close Report | `requirements/req-my-solar-system/CLOSE_REPORT.md` |
| Parameter Audit | `requirements/req-my-solar-system/PARAMETER_AUDIT.md` |
| Loop 6 Physics | `requirements/req-my-solar-system/LOOP6_PHYSICS_AUDIT.md` |
| G 溯源 | `requirements/req-my-solar-system/G-SOURCE-OF-TRUTH.md` |
| 需求 AC | `requirements/req-my-solar-system/spec/需求简述.md` |
