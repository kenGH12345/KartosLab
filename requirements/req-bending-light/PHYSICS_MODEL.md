# PHYSICS_MODEL.md · Bending Light

> SOURCE OF TRUTH：本地 PhET 源码 + `doc/model.md`  
> **禁止**自行改写公式以迁就 Flutter。  
> 审计日期：2026-09-18

---

## 0. Official Doc Summary (`doc/model.md`)

1. 界面用 **Snell's Law** 计算反射/折射角  
2. 功率用 **Fresnel equations（s-polarized）**  
3. 波：`cos(k·x − ω·t + phase)`  
4. Prisms 多重反射最多 **50** 次后终止  
5. **无衰减**：界面处 `power_in = power_out`  
6. 玻璃 n(λ)：**Sellmeier**  
7. 空气 n(λ)：refractiveindex.info 公式  
8. 白光：Bresenham 光栅化 + 强度叠加；画成 **灰** 以便白底可见  

---

## 1. Coordinate & Angle Conventions

| 项 | 约定 | 来源 |
|---|---|---|
| 模型单位 | SI 米 | `BendingLightConstants` / implementation-notes |
| 模型原点 | 屏幕中心附近；Intro 界面交点 / laser pivot 默认 `(0,0)` | notes + `Laser` |
| 模型轴 | **+x 右，+y 上** | `implementation-notes.md` |
| 视图轴 | +x 右，**+y 下**；`createSinglePointScaleInvertedYMapping` | `BendingLightScreenView` |
| 特征长度 | `CHARACTERISTIC_LENGTH = WAVELENGTH_RED = 650e-9` m | constants |
| 模型宽高 | `width = CL·62`，`height = width·0.7` | `BendingLightModel` |
| layoutBounds | `834 × 504` view units | constants |
| Laser `getAngle()` | `directionUnitVector.angle + π`（弧度，`atan2`） | `Laser.ts` |
| LightRay `getAngle()` | `atan2(tip.y−tail.y, tip.x−tail.x)` | `LightRay.ts` |
| Intro θ1 | `laser.getAngle() − π/2` = **相对向上竖直法线** | `IntroModel.ts:158-159` |
| Intro θ2 | 相对**向下**竖直（注释："angle from the down vertical"） | `IntroModel.ts:161-162` |
| 角度单位 | 内部 **radians**；UI 显示 **degrees**（`AngleNode`） | view |

---

## 2. Fresnel Power（共用）

`BendingLightModel.ts:129-142`：

\[
R = \left(\frac{n_1\cos\theta_1 - n_2\cos\theta_2}{n_1\cos\theta_1 + n_2\cos\theta_2}\right)^2
\]

\[
T = \frac{4\,n_1 n_2 \cos\theta_1\cos\theta_2}{(n_1\cos\theta_1 + n_2\cos\theta_2)^2}
\]

- 对应 **s-polarized**（`doc/model.md`）  
- 参数名注释写 “reflected angle” 的 cos，但调用传入的是 **折射侧** `cos(θ2)`  
- Prisms：结果再 `Utils.clamp(..., 0, 1)`  

---

## 3. Intro / More Tools — Scalar Snell's Law

### 3.1 Core

```text
n1 = indexOfRefraction(topMedium, λ_laser)
n2 = indexOfRefraction(bottomMedium, λ_laser)
θ1 = laser.getAngle() − π/2
θ2 = asin( (n1/n2) · sin(θ1) )
sourcePower = 1.0
```

源码：`IntroModel.propagateRays`（约 L147–162）。

**仅当** `laser.onProperty === true` 才传播。

### 3.2 Wavelength in medium

```text
λ_top = λ_laser / n1
λ_transmitted = λ_laser / n2   // 实现为 λ_incident/n2*n1
```

### 3.3 Total Internal Reflection

```text
θ_c = asin(n2 / n1)
hasTransmittedRay = isNaN(θ_c) || θ1 < θ_c
若 !hasTransmittedRay → reflectedPowerRatio = 1.0
若 reflectedPowerRatio === 1.0 → hasTransmittedRay = false   // issue #296
```

### 3.4 Power & ray creation thresholds

| 条件 | 行为 |
|---|---|
| 有透射 | `R = getReflectedPower(...)`，`T = getTransmittedPower(...)` |
| `R < 0.005` | **不创建**反射射线；并把透射功率视为满（源码强制路径） |
| TIR / R=1 | 无透射射线 |

### 3.5 Ray geometry

| Ray | Tip / Tail | 方向 |
|---|---|---|
| Incident | tip=`(0,0)`，tail=emission | 指向原点 |
| Reflected | 自原点 `createPolar(BEAM_LENGTH, π − laserAngle)`，`BEAM_LENGTH=1e-3` | |
| Transmitted | 自原点 `createPolar(BEAM_LENGTH, θ2 − π/2)` | |

### 3.6 Wave widths（wave mode）

```text
a = CHARACTERISTIC_LENGTH * 4
sourceWaveWidth = a / 2
trapeziumWidth = |sourceWaveWidth / sin(laserAngle)|
# 透射波宽依赖 cos(θ2) 与入射半宽几何（见 IntroModel 后续行）
```

### 3.7 Time step

```text
Δt = (speed == NORMAL) ? 1e-16 : 0.5e-16   // 仿真秒
```

### 3.8 Sensors（More Tools 继承）

| Sensor | 采样 |
|---|---|
| IntensityMeter | 探头圆半径 `1e-6` m；累加命中 `powerFraction`；显示 `value*100` % |
| VelocitySensor | 命中射线 → `direction · (c/n)` |
| WaveSensor | `amplitude = √(powerFraction)`；`magnitude = amplitude · cos(phase+π)` |

---

## 4. Prisms — Vector Snell's Law

### 4.1 Wikipedia vector form（`PrismsModel.propagateTheRay`）

入射方向单位向量 `L`，界面法线单位向量 `n`（指向入射侧）：

```text
cosθ1 = n · (−L)
radicand = 1 − (n1/n2)² · (1 − cosθ1²)
TIR ⇔ radicand < 0
cosθ2 = √|radicand|

vReflect = 2·cosθ1 · n + L

vRefract =
  cosθ1 > 0 :
    (n1/n2)·L + n·(n1/n2·cosθ1 − cosθ2)
  else :
    (n1/n2)·L + n·(n1/n2·cosθ1 + cosθ2)
vRefract = normalize(vRefract)

R = TIR ? 1 : clamp(getReflectedPower(n1,n2,cosθ1,cosθ2), 0, 1)
T = TIR ? 0 : clamp(getTransmittedPower(...), 0, 1)
```

### 4.2 Recursion terminate

```text
depth > maxLightRaySteps (50)  OR  power < 0.001  → return
```

### 4.3 Reflection visibility

仅当 `showReflectionsProperty || TIR` 时创建反射分支。

### 4.4 Medium selection at hit

交点后沿射线方向微移 `1e-12`；若与棱镜 shape 交点数为奇数 → 仍在棱镜内 → 用 `prismMedium`，否则 `environmentMedium`。

### 4.5 PrismIntersection normals

| 边类型 | 法线 |
|---|---|
| Polygon edge | `(end−start).rotate(+π/2).normalize()`；若 `n·direction > 0` 则取反 |
| Arc / circle | `(hit−center).normalize()`；同样保证与入射夹角 ≤ 90° |

### 4.6 Beam modes

| Mode | 行为 |
|---|---|
| Single | `manyRaysProperty === 1` |
| Many (5×) | 垂直于传播方向偏移 `x ∈ [−λ_red, λ_red·1.1]`，步长 `λ_red/2` |
| White | `WHITE_LIGHT_WAVELENGTHS = 400..690 step 10` nm → 米；每波长独立 n；交点法线仅首末波长 |

### 4.7 Prism prototypes（几何）

特征 `a = CHARACTERISTIC_LENGTH * 10`：

| typeName | Shape |
|---|---|
| `triangle` | 等边三角形顶点 |
| `trapezoid` | 等腰梯形 |
| `square` | 边长 `a` 正方形 |
| `circle` | 半径 `a/2` |
| `semicircle` | 半圆 |
| `diverging-lens` | 凹透镜多边形（两弧参数 `radius`） |

每类型最多 **6** 个（fuzz 时 2）。

---

## 5. Dispersion (`DispersionFunction.ts`)

### 5.1 Sellmeier（玻璃）

```text
n_G(λ) = √( 1 + B1·L²/(L²−C1) + B2·L²/(L²−C2) + B3·L²/(L²−C3) )
L² = λ²
B1=1.03961212, B2=0.231792344, B3=1.01046945
C1=6.00069867e-3·1e-12, C2=2.00179144e-2·1e-12, C3=1.03560653e2·1e-12
```

### 5.2 Air

```text
n_A(λ) = 1
  + 5792105e-8 / (238.0185 − (λ·1e6)^(−2))
  + 167917e-8  / (57.362   − (λ·1e6)^(−2))
```

### 5.3 Interpolation to substance n_ref @ 650 nm

```text
λ_ref = 650e-9
x = clamp( (n_ref − n_A(λ_ref)) / (n_G(λ_ref) − n_A(λ_ref)), 0, +∞ )
n(λ) = x·n_G(λ) + (1−x)·n_A(λ)
```

### 5.4 Preset substances（红光参考 n）

| Substance | n_red |
|---|---|
| AIR | 1.000293 |
| WATER | 1.333 |
| GLASS | 1.5 |
| DIAMOND / MYSTERY_A | 2.419 |
| MYSTERY_B | 1.4 |
| CUSTOM | 用户滑块；范围约 `AIR.indexForRed` … **1.6** |

Mystery 选择时 UI 隐藏真实 n（显示 “?” / “What is n?”）。

---

## 6. Wave Mechanics (`LightRay`)

```text
v = c / n
f = v / λ_medium
ω = 2π f
phaseOffset = ω·t − 2π·numWavelengthsPhaseOffset
cosArg(x) = k·x − ω·t + 2π·numWavelengthsPhaseOffset   // k = 2π/λ
```

Wave vs Ray：

| | RAY | WAVE |
|---|---|---|
| 默认 | ✅ | |
| 几何 | 细线 `RAY_WIDTH` | 梯形 `waveShape` + particles（非 WebGL） |
| Laser 角上限 | 无额外 | `MAX_ANGLE_IN_WAVE_MODE = 3.0194` |
| Intensity 相交 | 细 Ray2 | 波束内平行射线采样 |

---

## 7. Observable Properties（Model）

### 7.1 BendingLightModel

| Property | Default | Reset |
|---|---|---|
| `laserViewProperty` | `RAY` | ✓ |
| `wavelengthProperty` | `650e-9` m | ✓ |
| `isPlayingProperty` | `true` | ✓ |
| `speedProperty` | `TimeSpeed.NORMAL` | ✓ |
| `showNormalProperty` | `true` | ✓ |
| `showAnglesProperty` | `false` | ✓ |
| `rays` | `[]` | clear |

### 7.2 Laser

| Property | Intro/MT Default | Prisms Default | Reset |
|---|---|---|---|
| `onProperty` | `false` | `false` | ✓ |
| `pivotProperty` | `(0,0)` | `(0,0)` | ✓ |
| `emissionPoint` | polar(`9.225e-6`, `3π/4`) | polar(`1e-16`, `π`) | ✓ |
| `waveProperty` | `false` | `false` | ✓ |
| `colorModeProperty` | `SINGLE_COLOR` | `SINGLE_COLOR` | ✓ |
| `topLeftQuadrant` | `true`（角限制 Q2） | `false`（可 360°） | ctor |

### 7.3 IntroModel / MoreToolsModel

| Property | Intro | More Tools |
|---|---|---|
| `topMediumProperty` | Air | Air |
| `bottomMediumProperty` | **Water** | **Glass** |
| `horizontalPlayAreaOffset` | `true` | `false` |
| IntensityMeter | ✓ | ✓ |
| VelocitySensor / WaveSensor | — | ✓ |

### 7.4 PrismsModel

| Property | Default |
|---|---|
| `manyRaysProperty` | `1` |
| `showReflectionsProperty` | `false` |
| `showNormalsProperty` | `false` |
| `showProtractorProperty` | `false` |
| `environmentMediumProperty` | Air |
| `prismMediumProperty` | Glass |
| `prisms` | `[]` |

---

## 8. Edge Cases（测试金标）

| Case | Expected（源码语义） |
|---|---|
| `θ1 = 0`（垂直入射） | θ2=0；R 按 Fresnel；对称 |
| `θ1 → 90°` | sin 大；可能 TIR；wave 模式角钳位 |
| `n1 = n2` | θ2=θ1；反射功率≈0；可能无反射射线（R\<0.005） |
| `n1 < n2` | 折射靠近法线 |
| `n1 > n2` | 可能 TIR |
| Critical angle | `asin(n2/n1)`（Intro）；向量 radicand=0（Prisms） |
| `n` 滑到 1.6 | Custom 上限 |
| Mystery | 固定 n，UI 隐藏 |
| Laser off | 无射线 |
| White light | 多波长独立色散 |
| depth>50 / power\<0.001 | 停止递归 |
| Reset | 上述默认值全部恢复 |

---

## 9. Flutter Physics Module Plan（Phase 1 预告 · 本阶段不实现）

```
lib/bending_light/physics/
  fresnel.dart                 # getReflectedPower / getTransmittedPower
  dispersion_function.dart
  intro_propagation.dart       # scalar Snell
  prisms_propagation.dart      # vector Snell + recurse
  prism_intersection.dart
```

测试文件应对拍本节公式，**不得**用“看起来对”的近似角。

---

*PHYSICS_MODEL · req-bending-light · Phase 0*
