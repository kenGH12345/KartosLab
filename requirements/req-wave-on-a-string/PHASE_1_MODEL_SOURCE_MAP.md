# PHASE 1 — MODEL SOURCE MAP

| PhET source | Dart |
| ----------- | ---- |
| `WOASModel` | `WoasModel` |
| `yLast` / `yNow` / `yNext` / `yDraw` | `_yLast` / `_yNow` / `_yNext` / `_yDraw` (`Float64List`) |
| `waveModeProperty` | `waveMode` + `setWaveMode` → `restart()` |
| `stringEndTypeProperty` | `stringEndType` + `setStringEndType` → Fixed `zeroOutEndPoint()` |
| `isPlayingProperty` | `isPlaying` / `setPlaying` |
| `timeSpeedProperty` | `timeSpeed` (`WoasTimeSpeed`) |
| `tensionProperty` | `tension` (0.2…0.8) |
| `dampingProperty` | `damping` (0…1) |
| `frequencyProperty` | `frequencyHz` |
| `pulseWidthProperty` | `pulseWidthS` |
| `amplitudeProperty` | `amplitudeCm` |
| `nextLeftYProperty` | `nextLeftY` / `setManualDisplacement` |
| `angleProperty` | `angle` |
| `pulsePending` / `pulseSign` / `isPulseActive` | same fields |
| `stopwatch` | `WoasStopwatch` |
| `rulersVisibleProperty` | `rulersVisible` |
| `referenceLineVisibleProperty` | `referenceLineVisible` |
| `step(dt)` | `step(dt)` |
| `manualStep(dt?)` | `manualStep([dt])` |
| `evolve()` | `evolve()` |
| `manualPulse()` | `triggerPulse()` |
| `manualRestart()` | `restart()` |
| `reset()` | `resetAll()` |
| `zeroOutEndPoint()` | `zeroOutEndPoint()` |
| `WOASMode` | `WoasMode` |
| `WOASEndType` | `WoasEndType` |
| `TimeSpeed` | `WoasTimeSpeed` |
| `WOASConstants` | `woas_constants.dart` |
| `yNowChangedEmitter` | `notifyListeners` + still heuristic |

## Read API for Phase 2

```dart
List<double> get drawPositions; // unmodifiable
double yNowAt(i) / yLastAt(i) / yDrawAt(i);
```
