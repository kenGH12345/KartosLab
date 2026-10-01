# PHOTONS_ASSET_GEOMETRY_PHASE4

## greenPhoton.png

| Property | Value | Evidence |
| --- | --- | --- |
| Source path | `images/greenPhoton.png` (PhET) | PhotonSprites.ts import |
| Flutter path | `assets/simulations/quantum_measurement/images/greenPhoton.png` | `QmAssets.greenPhoton` |
| Intrinsic size | **50 × 50** px | PNG IHDR |
| Aspect ratio | 1:1 | |
| Display radius | 5 screen coords | `PhotonSprites.TARGET_PHOTON_VIEW_RADIUS` |
| Display diameter | 10 | `2 * 5` |
| Asset scale | `10 / 50 = 0.2` | `TARGET / (width/2)` ⇒ diameter/intrinsic |
| Anchor | image center | SpriteImage offset `(w/2, h/2)` |
| Rotation | none (identity) | source sprites use translation + uniform scale |
| Opacity | motion-state probability | PhotonSprites interior opacity from probability |
| Outline | stroke `#0A0` (photonStroke) | QuantumMeasurementColors |
| Substituted | **0** | original PNG only |

## Other Photons visuals

| Element | Asset / Draw | Notes |
| --- | --- | --- |
| Laser | Programmatic LaserPointerNode-like | body 95×55, nozzle 15×45 (LaserNode.ts) |
| PBS | Rectangle + diagonal Line | enclosure fill / cyan line |
| Mirror | Diagonal stroke | length 0.095 m |
| Detectors | Programmatic body 85×50 | PhotonDetectorNode.ts |
