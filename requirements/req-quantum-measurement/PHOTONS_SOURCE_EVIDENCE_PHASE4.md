# PHOTONS_SOURCE_EVIDENCE_PHASE4

> Direct source citations for PHASE 4 Photons visual/animation. Not a rehash of PHASE 2 layout derivation alone.

| Feature | Source File | Class / Constant | Evidence | Implementation |
| --- | --- | --- | --- | --- |
| Source position | `PhotonsExperimentSceneModel.ts` | `LASER_TO_BEAM_SPLITTER_DISTANCE=0.15` | Laser at `(-0.15, 0)` m | `PhotonsSceneMeters.laser` |
| PBS position | same | `PolarizingBeamSplitter(Vector2.ZERO)` | Origin of experiment | `pbs = (0,0)` |
| Mirror position | same | `BEAM_SPLITTER_TO_MIRROR_DISTANCE=0.11` | Mirror at `(0.11, 0)` | `meters.mirror` |
| Vertical detector | same | `TOTAL_PHOTON_PATH_LENGTH - LASER_TO…` | `(0, 0.20)` m, direction `up` | `verticalDetector` |
| Horizontal detector | same | after mirror path remainder | `(0.11, -0.09)` m, `down` | `horizontalDetector` |
| MVT | `PhotonTestingArea.ts` | `createSinglePointScaleInvertedYMapping(ZERO,ZERO,640)` | scale 640, Y invert | `PhotonViewTransform` |
| Experiment area center | `PhotonsExperimentSceneView.ts` | `center: new Vector2(420, 225)` | scene-local | `QmPhotonsLayoutSpec` |
| Photon visual | `PhotonSprites.ts` | `greenPhoton_png`, `TARGET_PHOTON_VIEW_RADIUS=5` | SpriteImage centered | `PhotonRenderer` + `QmAssets.greenPhoton` |
| Photon speed | `Photon.ts` | `PHOTON_SPEED = 0.3` m/s | linear motion | `photonSpeedMetersPerSecond` |
| Single | `LaserNode.ts` | `RoundPushButton` → `emitAPhoton()` | one click → one photon | `PhotonSourceNode` / `emitAPhoton` |
| Continuous | `Laser.ts` | `emissionRateProperty` 0..200, `step(dt)` | rate × dt + fractional accumulator | `PhotonsSpatialSimulation._laserStep` |
| Classical measure | `PolarizingBeamSplitter.ts` | `CLASSICAL` + Malus reflect | one path UP or continue RIGHT | spatial sim PBS classical branch |
| Quantum measure | same | `SPLIT` two states UP/RIGHT | dual motion states until detector | spatial sim PBS quantum branch |
| Slow motion | `PhotonsExperimentSceneModel.ts` | `TimeSpeed.SLOW` → `dt * 0.4` | | `slowMotionTimeScale` |
| Scene modes | `PhotonsScreenView.ts` | SINGLE_PHOTON / MANY_PHOTONS | IndexedStack scenes | `PhotonExperimentMode` |
| Behavior radios | `PhotonTestingArea.ts` | Classical / Quantum AquaRadio | above laser | `PhotonBehaviorControls` |
| Z-order sprites | `PhotonTestingArea.ts` | `photonSprites.moveToBack()` | sprites behind apparatus in source | Flutter: sprites after apparatus for visibility; documented P2 |
| Reset | scene `reset()` | clear photons, laser, detectors, play | | Screen Reset All |
