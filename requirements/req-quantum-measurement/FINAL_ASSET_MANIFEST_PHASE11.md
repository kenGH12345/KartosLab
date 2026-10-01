# FINAL_ASSET_MANIFEST_PHASE11

| Asset | Source | Flutter Path | Packaging | Runtime Verified | Substituted | Result |
|---|---|---|---|---|---:|---|
| classicalCoinHeads.svg | PhET QM images | `assets/simulations/quantum_measurement/images/classicalCoinHeads.svg` | in release APK | Coins Android/Golden | 0 | PASS |
| classicalCoinTails.svg | PhET QM images | `.../classicalCoinTails.svg` | in release APK | Coins (SVG `<style/>` warning) | 0 | PASS |
| greenPhoton.png | PhET PhotonSprites decode | `.../greenPhoton.png` | in release APK | Photons Android | 0 | PASS |
| spinScreenIcon.png | PhET spin screen icon | `.../spinScreenIcon.png` | in release APK | Home card + Spin | 0 | PASS |

**Substituted Assets = 0**

## SVG warning triage

| Item | Finding |
|---|---|
| Source | `classicalCoinTails.svg` contains `<defs><style>.cls-1{fill:#c0c;}</style></defs>` |
| Runtime | flutter_svg logs `unhandled element <style/>`; path still paints (class fill may fall back) |
| Release impact | Warning only; Coins faces visible on device/golden |
| Fix policy | Do **not** replace original asset; keep as NON-BLOCKING P2 |
| Future risk | Monitor flutter_svg upgrades; normalize only if paint breaks |

## Audio assets

| Item | Finding |
|---|---|
| Source `supportsSound` | `true` in package.json |
| Source `soundDesign` | **empty string** (`QuantumMeasurementConstants.ts`) |
| Local mp3/wav/ogg under QM source | **0 files** |
| Flutter `lib/quantum_measurement` audio code | **none** |
| Decision | **NOT REQUIRED / NOT VERIFIED** for this KartosLab port gate |
