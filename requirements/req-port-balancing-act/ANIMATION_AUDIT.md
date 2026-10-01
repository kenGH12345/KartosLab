# Balancing Act — Animation Audit

> Phase 0 · Source-only · 2026-09-23

---

## Summary

| Category | Present? | Mechanism |
|----------|----------|-----------|
| Physics animation | **Yes** | `Plank.step` 角动力学 |
| Mass return animation | **Yes** | `Mass.initiateAnimation` / `step` |
| UI tween library (twixt) | Declared, **unused in js/** | — |
| Particle / decorative | **No** | — |
| Feedback animation | Instant show/hide + Face | Game |

---

## 1. Physics animation (Plank)

**Source**: `js/common/model/Plank.ts` `step(dt)`

驱动链：
```
model.step(dt)
  → plank.step(dt)
      → updateNetTorque / ω / θ
      → updatePlank() / updateMassPositions()
  → view: PlankNode.rotateAround(pivot); mass.rotation = tilt
```

类型：**Physics animation**（非 tween）。

阻尼：`angularVelocity *= 0.91` 每帧。  
触地：夹到 `±maxTiltAngle`，ω=0。  
近水平：`|θ|<1e-4` → θ=0。

支撑柱切换时：
- DOUBLE → `forceToLevelAndStill`（瞬时强制，非插值）
- SINGLE → `forceToMaxAndStill`（瞬时）

---

## 2. Mass removal / return animation

**Source**: `js/common/model/Mass.ts`

| Constant | Value |
|----------|-------|
| Min animation speed | 3 m/s |
| Max duration | 0.75 s |
| Scale | `animationScale` 缩小至消失 |

触发：
- Lab：`BalanceLabModel.removeMassAnimated` 当落点失败
- 线性移向 `animationDestination`（toolbox 位置）

类型：**UI / feedback motion**（模型空间线性移动，非物理自由落体）。

---

## 3. Drag highlight

拖拽中 `activeDropPositions` 更新 → `PlankNode` 高亮 snap 格。  
非时间插值动画。

---

## 4. Game feedback

- `FaceWithPointsNode` 即时显示
- Challenge 面板 show/hide
- **无** twixt / Animation.js 调用

---

## 5. twixt

- `package.json` `phetLibs` 含 `twixt`
- `dependencies.json` 有 SHA
- **本仓库 `js/` 无 `import` twixt**

结论：迁移可忽略 twixt。

---

## 6. Flutter implications

1. 必须每帧驱动与 PhET 等价的 `Plank.step`（含 quirks）。
2. Lab 回 toolbox 动画需复刻速度/时长/缩放。
3. 不要引入无关的 Flutter 物理引擎动画替代 plank 动力学。
4. Reset All 按下动画 → 使用项目 `KratosResetAllButton`（elasticOut）。
