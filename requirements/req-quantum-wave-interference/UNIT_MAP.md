# UNIT_MAP — QuantumUnits

## Policy

建立 `QuantumUnits` 集中转换；禁止业务代码散落 `0.000001` magic numbers。

PhET 内部混用：

| Quantity | PhET property unit | SI / notes |
|---|---|---|
| Photon wavelength | **nm** | ×1e-9 → m |
| Particle speed | **m/s** | SI |
| Mass | **kg** | constants |
| Planck h | J·s | 6.626e-34 |
| Slit separation (Property) | **mm** | ×1e-3 → m |
| Slit width | **mm** | ×1e-3 → m |
| Screen distance | **m** | Experiment |
| Screen brightness | **percent 0–100** | display |
| Source strength | **0–1** | Experiment |
| Barrier position | **fraction** of region width | [0.38,0.62] |
| Probe position / radius | **normalized** to wave region | [0,1] |
| Hit coordinates | normalized screen space | Exp y∈[-1,1]；HI/SP y∈[0,1]（注意差异！） |
| Measuring tape | μm if regionWidth≥1e-6 else **nm** | display only |
| Experiment ruler | **mm** | display only |
| Solver time | **model seconds** | not wall clock |

## Conversion helpers（建议）

```dart
nmToM(nm) => nm * 1e-9;
mmToM(mm) => mm * 1e-3;
mToMm(m) => m * 1e3;
umToMm(um) => um * 1e-3; // as in HI configs: MICROMETER_TO_MM = 1e-3
nmToMm(nm) => nm * 1e-6; // NANOMETER_TO_MM
deBroglieM(massKg, speedMps) => h / (massKg * speedMps);
```

## Display scale mapping

HI/SP：`regionWidth/Height`（米）由 `defaultEffectiveWavelength * DISPLAY_WAVELENGTHS(15)` 推导；物理 slitSeparation（mm Property）×1e-3 后与 display range 映射进求解器。

Neutrons：**故意**使用电子默认 λ 作为 display scale（`BaseSceneModel` 注释）。