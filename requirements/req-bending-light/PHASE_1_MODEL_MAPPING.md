# PHASE_1_MODEL_MAPPING.md

| PhET Class | Dart Class | Responsibility | State | Methods | Status |
|---|---|---|---|---|---|
| `BendingLightModel` | `BendingLightModel` | 基类：rays、laser、时间、显示开关 | wavelength, laserView, speed, isPlaying, showNormal, showAngles, rays | updateModel, reset, setLaserOn… | DONE |
| `Laser` | `Laser` | 发射点、角度、开关、颜色模式 | pivot, emissionPoint, on, wave, colorMode | setAngle, translate, getAngle, reset | DONE |
| `LaserColor` | `LaserColor` | 波长包装 | wavelength (m) | — | DONE |
| `LightRay` | `LightRay` | 单段射线 | tip/tail, n, λ, power, phase | getCosArg, contains, getVelocityVector | DONE |
| `Medium` | `Medium` | 介质 | substance, colorArgb | getIndexOfRefraction | DONE |
| `Substance` | `Substance` | Air/Water/Glass/… | indexForRed, mystery, custom | presets | DONE |
| `DispersionFunction` | `DispersionFunction` | n(λ) | reference n, λ_ref | Sellmeier, air, interpolate | DONE |
| `IntensityMeter` | `IntensityMeter` | 强度计 | positions, reading, enabled | clear/addRayReading | DONE |
| `Reading` | `Reading` | 读数 / MISS | value, isMiss | isHit | DONE |
| `IntroModel` | `IntroModel` | 上下介质 + 标量 Snell | top/bottom Medium, time, intensityMeter | propagateRays, getWaveValue, reset | DONE |
| `MoreToolsModel` | `MoreToolsModel` | Intro + 传感器 | velocitySensor, waveSensor | reset, step sync | DONE |
| `VelocitySensor` | `VelocitySensor` | 速度探头 | position, value, enabled | reset | DONE |
| `WaveSensor` / `Probe` | `WaveSensor` / `Probe` | 波时序 | probes, series | step, reset | DONE |
| `PrismsModel` | `PrismsModel` | 向量 Snell 递归 | prisms, media, manyRays, reflections | propagateTheRay, addPrism | DONE |
| `Prism` | `Prism` | 可移动棱镜 | shape, position, typeName | translate, rotate, intersections | DONE |
| `Polygon` / `Circle` / `SemiCircle` | `PolygonShape` / `CircleShape` / `SemiCircleShape` | 几何 | points/center/radius | getIntersections, contains | DONE |
| `PrismIntersection` | `PrismIntersection` | 交点+法线 | — | getIntersections | DONE |
| `ColoredRay` | `ColoredRay` | 传播射线 | tail, dir, power, n, f | getBaseWavelength | DONE |
| `Intersection` | `Intersection` | 交点 | unitNormal, point | — | DONE |
| `BendingLightModel.get*Power` | `Fresnel` | s-pol R/T | — | getReflected/TransmittedPower | DONE |
| Intro Snell | `IntroSnell` | 标量 θ2=asin… | — | compute | DONE |
| Vector Snell | `VectorSnell` | Wikipedia 向量形式 | — | compute | DONE |
| Wave phase | `WaveMath` | cos(kx−ωt+φ) | — | cosArg, waveMagnitude | DONE |
| — | `IntroInteractionCommands` / `PrismsInteractionCommands` | Model 命令（无 Gesture） | — | setLaser*, resetAll | DONE |

**未迁移（属 View / Phase 2+）**：`MediumColorFactory` 精确 RGB、`WaveParticle` 粒子推进、`WhiteLightCanvas` Bresenham/XYZ 渲染、全部 ScreenView。
