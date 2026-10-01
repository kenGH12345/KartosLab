# Greenhouse Effect Final Acceptance

## Status
READY

## Behavioral
Greenhouse tests: `flutter test test/greenhouse_effect/` → **42 PASS**

Analyze: `dart analyze lib/greenhouse_effect test/greenhouse_effect` → **No issues found**

## Home
Entry: 物理 → 热学与气体 → Greenhouse Effect → `GreenhouseEffectHome` → `GreenhouseEffectScreen`

Back: AppBar back pops the route and disposes the clock

Re-entry: sunlight off, Waves selected

Lifecycle: enter / play / pause / step / reset / back covered by greenhouse tests

## Screens
Waves: concentration, cloud, wave legend, energy balance, surface thermometer

Photons: photons, more photons, flux meter, photon legend

Layer Model: solar intensity, albedo, 0–3 layers, numeric layer readouts, smaller surface thermometer

## Controls
Pause: PASS

Slow: PASS

Step: PASS

Reset: PASS

Time Period: PASS

Concentration: PASS

Cloud: PASS

Flux Meter: PASS (values unchanged; arrows are vertical ArrowShape)

Energy Balance: PASS (In / Out / Net vertical arrows, same rates)

Temperature: PASS (formatter unchanged; body is ThermometerNode geometry)

Layer Model: PASS

## Visual
P0: 0

P1: 0

P2: 0

P2 close-out:

- Flux sunlight / infrared use separate vertical `ArrowNode` wells (head 16, tail width 8)
- Energy balance In / Out / Net use vertical arrows (head 10, tail 5, fill `#00BB73`)
- Surface thermometer follows scenery-phet `ThermometerNode` (landscape bulb 40 / tube 150; Layer Model bulb 25 / tube 80)
- Screen selector is one bar with an underline on the selected screen; Home route was not changed

## Assets
Original: period landscapes + photon PNGs

Substituted: 0

## Global Regression
Project test: **2467 PASS, 1 skipped, 56 FAIL**

Global failures: unrelated simulation visual screenshot timeouts. No Greenhouse Effect test is in the failure set. Those sims were not modified.

## Platform
Web: widget tests on the Flutter test binding

Windows: widget tests and analyze on this machine

Android: **NOT VERIFIED**

## Remaining VERSION_DELTA
- Flux well is a scaled panel, not the full 340px PhET `EnergyFluxDisplay`
- Waves / Photons / Layer Model stay on one route with a selector (not three Flutter routes)
- Atmosphere layer temperatures stay numeric readouts, matching source `NumberDisplay`
