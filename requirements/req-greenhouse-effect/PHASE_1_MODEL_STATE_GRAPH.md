# PHASE_1_MODEL_STATE_GRAPH · Greenhouse Effect

> Source: `phet sourses/greenhouse-effect-main/greenhouse-effect-main` @ SHA `6c84ad0f43dfc71f8abd72119eef59a3b8b5de9d`  
> Date: 2026-09-21

---

## Screen → Model inheritance

```
GreenhouseEffectModel          (isPlaying, timeSpeed NORMAL|SLOW, step/stepModel/reset)
        │
        ▼
LayersModel                    (EMEnergyPacket pipeline + 12 AtmosphereLayers + Ground + Sun + Space)
        │
        ▼
ConcentrationModel             (GHG concentration → layer absorbance; Cloud; date/albedo)
        │
   ┌────┴────┐
   ▼         ▼
WavesModel  PhotonsModel       (view-oriented waves / PhotonCollection on top)
LayerModelModel extends LayersModel directly (3 layers, manual IR absorbance)
```

Phase 1 Flutter 优先迁移：**GreenhouseEffectModel → LayersModel → ConcentrationModel**（能量语义真源）。  
`PhotonCollection` / `Wave` 为 Photons/Waves 屏可视化+交互扩展，记为 Known Gap（能量包路径已覆盖吸收/反射/发射）。

---

## Energy / radiation state graph（source 语义）

```
SunEnergySource.produceEnergy(dt)
  │  if isShining
  │  energy = 343.6 W/m² × surfaceArea × proportionateOutputRate × dt
  ▼
EMEnergyPacket(VISIBLE, energy, altitude=HEIGHT_OF_ATMOSPHERE=50000m, DOWN)
  │
  ▼ step: altitude ± SPEED_OF_LIGHT(9000 m/s) × dt
  │
  ├─► Cloud.interactWithEnergy          (optional; visible reflection fraction)
  ├─► AtmosphereLayer.interactWithEnergy (IR only × absorptionProportion; glass radiates UP+DOWN)
  ├─► GroundLayer.interactWithEnergy     (DOWN: visible albedo reflect / absorb; IR fully absorb)
  │       │  T ← specific-heat; radiate IR UP via Stefan–Boltzmann
  │       ▼
  │   new EMEnergyPacket(INFRARED, …, altitude=0, UP)
  │
  └─► SpaceEnergySink.interactWithEnergy (UP & altitude≥50000 → remove; track outgoing rate)

netInflowOfEnergy = sunOutputRate − spaceOutgoingRate/SURFACE_AREA
inRadiativeBalance = |net| < 5 W/m²
```

### Atmosphere GHG coupling（ConcentrationModel）

```
concentration ∈ [0,1]
  → proportionToAbsorbAtSeaLevel = 0.85 × concentration
  → each layer: absorb = seaLevel × exp(−altitude / 8400)
```

### Ground albedo

```
BY_DATE + ICE_AGE → albedo 0.225
else → albedo 0.2
```

---

## Time system

```
step(dt):
  if !isPlaying → return
  timeStep = (timeSpeed==NORMAL) ? dt : dt/2
  stepModel(timeStep)

stepModel(dt):
  modelSteppingTime += dt
  while modelSteppingTime >= 1/60:
    sun.produceEnergy(1/60)
    packets.step(1/60)
    ground / atmosphereLayers / cloud / space.interact(1/60)
    fluxMeter?.measure(...)
    modelSteppingTime -= 1/60
  update netInflow + radiativeBalance
  steppedEmitter

manualStep (UI Step Forward): stepModel(1/60)  // bypasses isPlaying
```

---

## Default initial state（ConcentrationModel / Waves & Photons base）

| Field | Default |
|---|---|
| isPlaying | true |
| timeSpeed | NORMAL |
| sun.isShining | **false** (`initiallyStarted` default) |
| proportionateOutputRate | 1.0 |
| concentrationControlMode | BY_VALUE |
| manuallyControlledConcentration | 0.5 |
| date | SEVENTEEN_FIFTY |
| cloudEnabled | true |
| ground.albedo | 0.2 |
| ground.temperature | minimumEarthNight = **245 K** |
| atmosphere layers | 12, active, absorbance from concentration |
| emEnergyPackets | [] |
| surfaceThermometerVisible | true |
| energyBalanceVisible | false |
| surfaceTemperatureVisible | false |
| fluxMeterVisible | false |
| temperatureUnits | Celsius |

---

## Status

Graph derived entirely from local source files under `js/common/model/*` and `js/waves|photons|layer-model/model/*`.
