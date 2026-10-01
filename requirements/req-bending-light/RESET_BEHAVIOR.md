# RESET_BEHAVIOR.md

## BendingLightModel.reset

Order (matches `BendingLightModel.ts`):

1. `laserView` → RAY  
2. `wavelength` → 650e-9 m  
3. `isPlaying` → true  
4. `speed` → NORMAL  
5. `showNormal` → true  
6. `showAngles` → false  
7. `laser.reset()` (pivot, emission, on=false, wave=false, colorMode=SINGLE)  
8. clear rays  

## IntroModel.reset

1. `super.reset()`  
2. restore initial top/bottom Medium (Air / ctor bottom substance)  
3. `intensityMeter.reset()`  
4. `time = 0`  
5. `updateModel()`  

## MoreToolsModel.reset

1. `super.reset()` (Intro)  
2. `velocitySensor.reset()`  
3. `waveSensor.reset()` (probes + series + enabled)  

## PrismsModel.reset

1. `super.reset()`  
2. `manyRays=1`, `showReflections/Normals/Protractor=false`  
3. restore environment=Air, prismMedium=Glass  
4. clear `prisms` and `intersections`  
5. laser angle → π  
6. `updateModel()`  

## Notes

- Screen navigation does **not** auto-reset other screens (joist semantics; Phase 8).  
- Reset All UI button → call corresponding `model.reset()` (Phase 4; radius 19).
