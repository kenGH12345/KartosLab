# ARCHITECTURE_PLAN — Diffusion

## 原则

- **不**迁 Ideal Gas Law / Pressure / Heater  
- **不**复制 Collision Lab `CollisionEngine`  
- 在 `lib/diffusion/` **sim-local** 移植 gas-properties Diffusion + common CollisionDetector 语义  
- 不改 common API / 一级 taxonomy

## 模块

```
DiffusionModel (ChangeNotifier)
  ├── DiffusionContainer (bounds, divider)
  ├── leftSettings / rightSettings
  ├── particles1[] / particles2[]
  ├── DiffusionCollisionDetector
  ├── leftData / rightData
  ├── centerOfMass1/2
  ├── isPlaying, timeSpeed (normal|slow), stopwatchTime
  └── stepRealTime / stepModelTime / reset

DiffusionRenderData → Painters (container, particles, COM, divider)
DiffusionControls / TimeBar
DiffusionHome → NineGrid + shell
```

## 数据流

```
Clock (Ticker)
 → DiffusionModel.step(realDt)
 → timeTransform → stepModelTime
 → move particles → collide → update Data/COM
 → notifyListeners
 → Painter(read-only)
```

## Home

物理 → **热学与气体** → Diffusion

## 暂停条件

本设计不触发暂停条件。
