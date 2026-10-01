# PHASE 1 — Feature Spec · Gravity and Orbits

> 基于本地源码 1.7.0-dev.7 · 不引入源码未有之功能

---

## 1. Screens

1. **Model** — 夸张半径、太阳固定、月球轨道修正、无 Mass checkbox / Measuring Tape  
2. **To Scale** — 真实半径、太阳可动、有 Mass + Measuring Tape

每屏 4 个场景预设（互斥 radio/icon）：

| ID | Bodies | UI 时间单位 |
|---|---|---|
| starPlanet | Star + Planet | Earth Days |
| starPlanetMoon | Star + Planet + Moon | Earth Days |
| planetMoon | Planet + Moon | Earth Days |
| planetSatellite | Planet + Satellite | Earth Minutes |

用户**不能**自由增删天体；只能切换预设。

---

## 2. Celestial Bodies（仅此四类）

| type | 标签 | mass 可调 | 典型 asset |
|---|---|---|---|
| star | Star / Our Sun tick | ✅（Model 太阳位置固定不可拖） | sun.png |
| planet | Planet / Earth tick | ✅ | earth ↔ planetGeneric |
| moon | Moon / Our Moon tick | ✅（Sun+Planet+Moon 场景无 moon 滑条） | moon ↔ moonGeneric |
| satellite | Satellite / Space Station tick | ✅ | spaceStation.png |

每 body：`position(m)`, `velocity(m/s)`, `mass(kg)`, `diameter(m)`（=2×radius×scale）, `force`, `acceleration`, `rotation`, `isCollided`, `isMovable`, `path[]`。

**physics radius vs display**：Model 屏半径乘数放大显示/碰撞半径；To Scale 用真实半径。二者同一字段。

---

## 3. User Can Change

| 控制 | 范围 | Model 绑定 |
|---|---|---|
| Gravity on/off | bool | gravityEnabledProperty |
| Mass slider | 0.5×–2.0× tick mass | massProperty（密度不变 → diameter∝∛m 需确认源码） |
| Zoom | 0.5–1.3，step 0.1 | zoomLevelProperty |
| Time speed | Slow / Normal / Fast | timeSpeedProperty |
| Play / Pause | | isPlayingProperty |
| Step forward | 暂停时 1 帧 | steppingProperty |
| Rewind | | rewind bodies |
| Scene preset | 4 选 1 | sceneProperty |
| Scene reset（小箭头） | 该场景初值 | resetScene |
| Reset All | 全局 | model.reset |
| Checkboxes | Force / Velocity / Path / Grid / (Mass) / (Tape) | show*Property |
| Drag body | position only | positionProperty |
| Drag velocity arrow | velocity | velocityProperty |
| Measuring tape | To Scale | start/end points |
| Clear | 时间读数归零 | clock.time=0 |

**质量与直径**：`Body` 中 `density = mass0/volume0`；改质量时需查 MassSlider / Body 是否更新 diameter。  
→ 源码：`MassSlider` 只改 `massProperty`；diameter 不随 mass 变（density 仅构造时算一次）。**实现：改质量不改直径。**

---

## 4. Observation Tools

- Gravity force vectors（蓝）
- Velocity vectors（绿，可拖）
- Orbit path trail
- Grid
- Mass readout（To Scale + showMass）
- Measuring tape（To Scale）
- Time counter + Clear
- Return Objects（出界且非 rewind 位）
- Explosion（碰撞后较小体）

---

## 5. Animation Speeds

| Speed | 子步数 / 帧 | 相对推进 |
|---|---|---|
| Slow | 1 × (baseDT×0.13125) | 1× |
| Normal | 4 × | 4× |
| Fast | 7 × | 7× |

非简单 `0.1 / 1.0` 倍率。

---

## 6. Reset Behaviors

见 PHASE_0 §12。验收：Reset All 后场景=starPlanet、gravity on、vectors off、mass=1.0×、time=0、playing=false、speed=Normal。

---

## 7. Non-Goals

- 不增加其他行星 / 自定义 N-body UI  
- 不接入声音  
- 不提前改 Home  
- 不用椭圆解析轨道替代 PEFRL  
- 不用 MSS 物理引擎
