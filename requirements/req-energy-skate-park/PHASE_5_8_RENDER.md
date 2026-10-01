# Phase 5–8 · Render / Interaction / Animation / Screens

> req-energy-skate-park · 2026-09-03

## Done

- `esp_colors.dart` / `esp_strings.dart`
- Screen models: `TrackSet` / `FullTrackSet` / `Intro` / `Measure` / `Graphs` / `Playground` / `SaveSample` / `DataSample`
- Controllers + Ticker clock in `EspScreenBody`
- `EspMvt` (scale 61.40, y-flip) · `EspRenderData` · `EspRenderBuilder`
- Painters: background, grid, track, skater (geometric), energy bar, pie
- Widgets: page shell, play area (skater drag ≤0.5 m snap), control panel, time control
- Screens: Home tabs Intro / Measure / Graphs / Playground
- Home registration under 力学 after Collision Lab

## Notes

- Skater PNG assets **not** copied — geometric painter; `[待确认]` usaSkater / mountains
- Graphs: sample counter + position/time toggle; full chart painter still thin
- Measure: path samples; Energy Sensor / tape / stopwatch **[待实现]**
- Playground: add/clear/basic join; full CAD (split/15-pt/toolbox drag) **[待实现]**
- Stick default remains `true` (matches PhET `BooleanProperty(true)`)
