# Balancing Act — Model Architecture

> Phase 0 · Source-only · 2026-09-23  
> 禁止在本文件中发明物理规则；所有断言均有源码路径。

---

## 1. Model hierarchy

```
Mass (abstract)
├── ImageMass
│   ├── HumanMass → Boy, Girl, Man, Woman
│   ├── LabeledImageMass → MysteryMass
│   └── Barrel, BigRock, CinderBlock, Crate, FireExtinguisher, FireHydrant,
│       FlowerPot, LargeBucket, LargeTrashCan, MediumBucket, MediumRock,
│       PottedPlant, Puppy, SmallBucket, SmallRock, SmallTrashCan,
│       SodaBottle, Television, TinyRock, Tire
└── BrickStack

BalanceModel                          // Intro + Lab 基类
├── fulcrum: Fulcrum
├── plank: Plank
├── supportColumns: LevelSupportColumn[2]
├── columnStateProperty
├── massList / userControlledMasses
├── BAIntroModel                      // 预置 3 个 mass
└── BalanceLabModel                   // brickStackGroup / mysteryMassGroup / people creators

BalanceGameModel                      // 不继承 BalanceModel；几何常量重复
├── plank, fulcrum, levelSupportColumns
├── tiltedSupportColumn               // SINGLE_COLUMN
├── fixedMasses / movableMasses
└── game state / scoring / challenges
```

---

## 2. Screen → Model mapping

| Screen | Model class | File | Extends |
|--------|-------------|------|---------|
| Intro | `BAIntroModel` | `js/intro/model/BAIntroModel.ts` | `BalanceModel` |
| Balance Lab | `BalanceLabModel` | `js/balancelab/model/BalanceLabModel.ts` | `BalanceModel` |
| Game | `BalanceGameModel` | `js/game/model/BalanceGameModel.ts` | （独立） |

---

## 3. BalanceModel entities

| Entity | Class | Key properties | Notes |
|--------|-------|----------------|-------|
| Fulcrum | `Fulcrum` | `size` Dimension2(1, 0.85), `shape` A-frame | **不可拖动**；纯几何 |
| Plank | `Plank` | `tiltAngleProperty`, `bottomCenterPositionProperty`, `massesOnSurface`, `forceVectors`, `activeDropPositions` | 物理核心 |
| Support | `LevelSupportColumn` | height=`PLANK_HEIGHT`, x=±1.625 | Model；可见性由 ColumnState 驱动 View |
| Column state | `ColumnState` enum | DOUBLE / SINGLE / NO | 默认 DOUBLE_COLUMNS |
| Mass list | `ObservableArray<Mass>` | position, rotation, onPlank, userControlled | |

常量（`BalanceModel.ts`）：
- `FULCRUM_HEIGHT = 0.85` m（pivot Y）
- `PLANK_HEIGHT = 0.75` m（未旋转 plank 底边 Y）
- plank 位置 `(0, 0.75)`，pivot `(0, 0.85)`

Game 复用相同高度常量（`BalanceGameModel.ts` L38–39）。

---

## 4. Plank observables & internals

| Name | Type | Meaning |
|------|------|---------|
| `tiltAngleProperty` | NumberProperty | 0=水平；**正=左倾**；负=右倾 |
| `bottomCenterPositionProperty` | Property\<Vector2\> | plank 底边中心（可与 pivot 分离） |
| `massesOnSurface` | ObservableArray | 板上物体 |
| `forceVectors` | ObservableArray\<MassForceVector\> | 显示用力 |
| `activeDropPositions` | ObservableArray\<number\> | 拖拽时高亮吸附位（距中心 m） |
| `massDistancePairs` | array | 板上 mass → 有符号表面距离 |
| `angularVelocity` | private number | 角速度 |
| `currentNetTorque` | private number | 净力矩 |
| `maxTiltAngle` | number | `asin(0.75/2.25)` |

---

## 5. Mass base state

`Mass.ts` 关键：
- `massValue` (kg)
- `positionProperty`
- `rotationAngleProperty`
- `userControlledProperty`
- `onPlank` / animation flags
- `step(dt)`：仅处理移回 toolbox 的动画（非自由落体）

---

## 6. Intro seed masses

`BAIntroModel.ts` L23–25：
| Instance | Class | Initial position (m) | Mass |
|----------|-------|----------------------|------|
| fireExtinguisher1 | FireExtinguisher | (2.7, 0) | 5 kg |
| fireExtinguisher2 | FireExtinguisher | (3.2, 0) | 5 kg |
| smallTrashCan | SmallTrashCan | (3.7, 0) | 10 kg |

---

## 7. Lab model extras

`BalanceLabModel`：
- 通过 Creator Nodes 动态 `addMass`
- 松手未上板 → `removeMassAnimated`（动画回 toolbox 后 dispose）
- reset：清空所有 mass + `super.reset()`

---

## 8. Game model extras

常量（`BalanceGameModel.ts`）：
- `MAX_LEVELS = 4`
- `CHALLENGES_PER_PROBLEM_SET = 6`
- `MAX_POINTS_PER_PROBLEM = 2`
- `MAX_SCORE_PER_GAME = 12`

挑战类型：
- `BalanceMassesChallenge` — 把可动物放到板上使平衡
- `MassDeductionChallenge` — 推断神秘物质量
- `TiltPredictionChallenge` — 预测倾斜方向

GameState 字符串联合：`choosingLevel` | `presentingInteractiveChallenge` | … | `showingLevelResults`

`TiltedSupportColumn`：Game 专用；SINGLE_COLUMN 时 x≈1.8 m。

---

## 9. Simulation clock

- Joist Screen 调用 `model.step(dt)`，`dt` 单位秒
- Intro/Lab：`BalanceModel.step` → `plank.step` + 各 `mass.step`
- Game：`BalanceGameModel.step` → plank + movable + fixed masses
- Game UI 计时器：`stepTimer.setInterval(..., 1000)` 递增 `elapsedTimeProperty`（非物理时钟）
- **无**自定义 Clock 类；**无**固定物理 timestep（跟随 frame dt）

---

## 10. Reset semantics

| Model | Reset |
|-------|-------|
| `BalanceModel` | `plank.removeAllMasses()`；`columnStateProperty.reset()` → DOUBLE |
| `BAIntroModel` | 各 mass position/rotation reset → `super.reset()` |
| `BalanceLabModel` | `super.reset()` + 移除/dispose 全部 mass |
| `BalanceGameModel` | timer/level/score/gameState/columnState/bestScores/bestTimes；板上清空在开局 setChallenge |

View 层额外重置：Show/Position 可见性属性、打断拖拽、Lab Carousel page。
