# Physics Analysis · My Solar System

> 唯一算法源：本地 `js/common/model/NumericalEngine.ts` + `MySolarSystemModel.stepOnce` + `CenterOfMass.ts`。  
> **禁止**用教科书 RK4 / 欧拉法「改进」原版。

---

## 1. 单位链

| 层 | 量 | 单位 | 证据 |
|---|---|---|---|
| Model 质量 | massProperty | **10²⁸ kg**（UI 字符串 `10<sup>28</sup> kg`） | `strings` + `doc/model.md` |
| Model 位置 | position | **AU** | CenterOfMass `units: 'AU'` |
| Model 速度 | velocity | **km/s** | CenterOfMass `units: 'km/s'` |
| Model 时间 | timeProperty | **year** | TimePanel units.years |
| 显示 | 同上 | 不经 SI | ValuesPanel |
| 屏幕 | MVT | zoomScale px/AU，Y 向上 | `[二次证据]` Kepler `createSinglePointScaleInvertedYMapping` |

`doc/model.md` Flash 换算：距离 ×0.01，速度 ×0.2112，质量数值不变。HTML5 以本树 preset 为准，不还原 Flash。

### G 的文档冲突

`doc/model.md` 写 `G = 4.4567 × 10⁻³`。  
`NumericalEngine` 从 `SolarSystemCommonConstants.G` 取值，**本机无此文件**。

闭合检验（圆轨道 `v ≈ √(GM/r)`）：SUN_PLANET 行星 m_sun=250、r=2、v≈23.45。

- 若 G=4.45669：`√(4.45669×250/2) ≈ 23.60` 与 23.4457 同量级（太阳自身 vy=-2.34 修正 CoM）。
- 若 G=4.4567e-3：`√ ≈ 0.75`，与 preset **矛盾**。

**结论**：以 preset + Kepler `INITIAL_G=4.45669` 为准。`model.md` 的 10⁻³ 视为文档错误。Build 使用 `G = 4.45669`，标 `[二次证据 + preset 闭合]`。若日后补到 common 文件，以文件字面量为准。

质量显示「Jupiter → 1.5 太阳」：滑条下限 0.1（~木星）、上限 `[BLOCKED]` body.range.max；文档 1.5 太阳 ×200 = **300**。

---

## 2. 牛顿力（成对，无自力）

```
direction = pos_j - pos_i
F_on_i = G * m_i * m_j * direction / |r|³
F_on_j = -F_on_i
a = F / m
```

源码：`gravityForceMagnitude = G * mass1 * mass2 * pow(distance, -3)` 再 `direction.multiplyScalar`（`NumericalEngine.ts:106-114` 与 `getGravityForce:234-243`）。

`distance===0`：`getGravityForce` 返回 0（`:237-239`）。`run` 内 assert distance>=0，无零除保护。

---

## 3. PEFRL 积分 `[已确认 NumericalEngine.run :82-198]`

论文：Omelyan, Myrglod & Folk 2001。系数字面量：

```
XI     = 0.1786178958448091
LAMBDA = -0.2123418310626054
CHI    = -0.06626458266981849
```

每个 `engine.run(dt)`：

1. `iterationCount = 4000 / N`（N=当前 bodies 长度；2 体 → 2000 内层）
2. `dt_inner = dt / iterationCount`
3. 拷贝 mass/pos/vel/acc/force 到局部数组
4. 对 k in [0, iterationCount)：
   - 由**当前** positions 算全部 pairwise F 与 a
   - 对每个 i 做 PEFRL 五步（源码注释 Step One–Five），全程使用**这一轮开始时的 a**
   - **不在五步中间重算力**
5. 写回 Body；仅当 `notifyPropertyListeners` 时替换 Property，否则 mutate Vector2

这与「每半步更新力」的教科书 PEFRL 不同。**必须原样移植**，否则轨道会漂。

`update(bodies)`：换 bodies 引用 → `checkCollisions` → `updateForces`（`:36-40`）。

---

## 4. 时间步进 `[已确认 MySolarSystemModel.stepOnce :262-284]`

输入 `dt` 为墙钟秒（Play 循环来自父类 `[BLOCKED]`；Step 传入 `1/8`）。

```
dt *= timeSpeedMap[speed]     # [二次证据] FAST=7/4, NORMAL=1, SLOW=1/4
n = ceil(dt * 30)             # desiredStepsPerSecond = 30
dt /= n
dt *= engineTimeScale         # 0.05
for i in 0..n-1:
  engine.run(dt, notify = (i == n-1))
  engine.checkCollisions()
  time += dt * modelToViewTime   # [二次证据] 1000/12.6
  if addingPathPoints: each body.addPathPoint()
```

性能：2 体每帧 Step 约 `n * 2000` 次 PEFRL 内层；N=4 时 `4000/4=1000`。这是 60 FPS 主风险。

---

## 5. 碰撞 `[已确认 checkCollisions :46-73]`

- 条件：`body1.isOverlapping(body2)` `[BLOCKED]` 几何。`[二次证据]` Kepler `massToRadius = max(0.03, 0.023 * m^(1/3))`，重叠即半径和。
- 质量**大**者保留；相等则 body1 视为更大（`mass1 > mass2`）
- `v_large += v_small * (m_small / m_large)`  ⇒ Δp_large = p_small（动量并入）
- **不把 m_small 加到 m_large**
- `smaller.collidedEmitter`；`isActive=false`
- while 循环直到本轮无新碰撞

`doc/model.md`：撞击被大幅简化。

---

## 6. 质心

```
M = Σ m_i
r_com = Σ (m_i / M) r_i
v_com = Σ (m_i / M) v_i
```

`CenterOfMass.update`（`:52-74`）。assert M≠0。

`followCenterOfMass`：全体 `v -= v_com`（不移位置），再 update CoM（`MySolarSystemModel.ts:231-243`）。

`followAndCenterCenterOfMass`：pause → update → 全体 `r -= r_com`、`v -= v_com`、`clearPath` → 若原先在玩则恢复 play（`:214-228`）。

---

## 7. 与 Kepler 的物理差异（禁止混引擎）

| | Kepler | My Solar System |
|---|---|---|
| 引擎 | EllipticalOrbitEngine 解析 | NumericalEngine PEFRL |
| 太阳 | 钉在原点 | 可动、可被拖 |
| engineTimeScale | 0.002 | **0.05** |
| zoom | 1–2 → 45–100 | **1–6 → 25–125**，默认 4 → **85** |
| 碰撞 | 进入太阳半径 = CRASH 停表 | 小体消失 |

可复用：Body 字段、massToRadius、速度矢倍率、网格 1 AU、测量尺、Time 三档、Restart/Reset 语义骨架。

---

## 8. `[二次证据]` 待 common 文件核对

来自 Kepler `keplers_laws_constants.dart` / `SOURCE_ANALYSIS.md`（声称摘自 SolarSystemCommonConstants / Body.ts）：

```
G = 4.45669
modelToViewTime = 1000/12.6
timeSpeed Fast/Normal/Slow = 7/4, 1, 1/4
massToRadius: max(0.03, 0.023 * m^(1/3))
VELOCITY_TO_VIEW_MULTIPLIER ≈ 0.04997
gravityForceScalePower 默认 0，范围 -2..8
INITIAL_VECTOR_OFFSCALE = -3
GRID_SPACING = 1 AU
测量尺默认 (0,1)–(1,1)
```

`isOffscreen`、`MAX_PATH_DISTANCE`、`MASS_SLIDER_STEP`、massProperty.max：**仍 BLOCKED**。
