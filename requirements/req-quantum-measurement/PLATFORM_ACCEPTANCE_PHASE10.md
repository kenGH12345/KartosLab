# PLATFORM_ACCEPTANCE_PHASE10

| Test | Result | Evidence |
|---|---|---|
| Home launch | PASS | `KratosApp` → `HomeScreen` |
| Card visible | PASS | `find.text('Quantum Measurement')` unit + Android H1 |
| Card clickable | PASS | tap opens route |
| QM opens | PASS | `QuantumMeasurementHome` |
| QM internal screens | PASS | Coins/Photons/Spin/Bloch tabs |
| Back → Home | PASS | AppBar Back; Home found; QM disposed |
| Re-entry | PASS | Android H1 reopen |
| Other Simulation | PASS | Android H2 Membrane Transport open/back |
| Host lifecycle dispose | PASS | leave QM → findsNothing |
| Event failure isolation | PASS | throwing sink swallowed |
| Lazy loading | PASS | Registry builder only on tap; Home does not construct Models |
| Asset boundary | PASS | Home uses metadata + `spinScreenIcon` thumbnail only |
| Session persistence | NOT IMPLEMENTED | `NoOpSimulationSessionStore` |
| Analytics backend | NOT IMPLEMENTED | `NoOpSimulationEventSink` |
| Audio | NOT VERIFIED | carry-over from PHASE 9 |

## Android device

| Path | Result | Log |
|---|---|---|
| Home → QM → tabs → Back → reopen | PASS | `android-qa/phase10_android_home_log.txt` H1 |
| Peer Membrane Transport | PASS | H2 |

Device: Pixel Tablet `emulator-5554` (same as PHASE 9).

## Desktop suites

| Suite | Result |
|---|---|
| `phase10_platform_test.dart` | 7 PASS |
| `test/quantum_measurement/` full | **207 PASS** |
| Golden PNG | 30 retained |
