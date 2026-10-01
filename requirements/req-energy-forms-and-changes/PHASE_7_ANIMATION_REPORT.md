# Phase 7 Animation Report

> 2026-09-10

## PHASE: 7
## STATUS: PARTIAL — 关键时间线已对齐

### 1. Completed
- Carousel：**0.75s CUBIC_IN_OUT**（`cubicInOut` ≡ twixt Easing.CUBIC_IN_OUT）；pause 时仍 step
- EC wander：`EnergyChunkWanderController`（0.06–0.10 m/s，±π×0.2，0.4–0.8s 变向）
- Systems `EnergyChunkPathMover`：折线 path Source→Converter→User
- Intro burner 加热向空气发射上升 chunk
- Beaker steamingProportion 近沸点动画（软圆蒸汽）
- snap-fall：g=−9.8，burner topSurface 支撑

### 2. Not yet / deferred
- Biker 18 腿帧 / Fan 10 帧时序（asset 已在盘，未绑 crankAngle）
- Generator 轮旋转、LightRays、TeaKettle steam canvas 全量
- Intro EC balance transfer 完整 bookkeeping（连续能量已通）

### 3. Evidence
- `[已确认]` TRANSITION_DURATION=0.75；CUBIC_IN_OUT 端点/中点单测
- `[已确认]` wander 速度/角度常量来自 EnergyChunkWanderController.ts
- `[待确认]` path chunk 生成节奏 vs PhET ENERGY_PER_CHUNK 门控

### 4. Tests: carousel 0.75s + path spawn + snap-fall + steam
### 5. Analyze: 0 error
### 9. Next: Phase 8 lifecycle 再验证 + Phase 9 Visual QA
