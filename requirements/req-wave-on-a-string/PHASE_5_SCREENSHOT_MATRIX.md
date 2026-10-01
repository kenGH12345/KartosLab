# PHASE 5 — SCREENSHOT MATRIX

Directory: `requirements/req-wave-on-a-string/visual-qa/screenshots/`  
Viewport: **1024×618** · DPR 1.0 · Model-driven (not View-side fake wave)

| # | File | State | Diff vs source intent | Severity |
| - | ---- | ----- | --------------------- | -------- |
| 01 | `01_initial.png` | Manual · Fixed · defaults · tools OFF · flat string | Structure aligned; wrench+arrows+clamp | OK |
| 02 | `02_manual_high.png` | Manual high displacement | Driver+string from Model | OK |
| 03 | `03_manual_low.png` | Manual low displacement | OK | OK |
| 04 | `04_oscillate.png` | Oscillate mid-run · Fixed clamp · wave | Oscillate wheel; Amp+Freq controls | OK |
| 05 | `05_pulse.png` | Pulse mid propagation | Packet from Model | OK |
| 06 | `06_fixed.png` | Fixed End clamp | Distinct Fixed chrome | OK |
| 07 | `07_loose.png` | Loose End rings+post | Distinct Loose chrome | OK |
| 08 | `08_no_end.png` | No End windows | Distinct No End; window sandwich | OK / P2 offset |
| 09 | `09_amp_max.png` | Amp 1.3 Oscillate | Larger drive excursion | OK |
| 10 | `10_freq_min.png` | Freq 0 | Flat drive angle hold | OK |
| 11 | `11_freq_max.png` | Freq 3 | Denser phase advance | OK |
| 12 | `12_damp_max.png` | Damping 1 | UI + attenuated wave | OK |
| 13 | `13_damp_min.png` | Damping 0 | Stronger residual wave | OK |
| 14 | `14_tension_min.png` | Tension 0.2 | Slower evolve cadence visual | OK |
| 15 | `15_tension_max.png` | Tension 0.8 | Faster evolve | OK |
| 16 | `16_ruler_on.png` | Rulers visible | Overlay on; wave unchanged | OK / P2 ticks |
| 17 | `17_timer_on.png` | Stopwatch visible + running | Sim-time digits | OK |
| 18 | `18_reference_line_on.png` | Ref line ON moved | Independent of center dash | OK |
| 19 | `19_pause.png` | Paused Oscillate | Pause glyph; frozen Model | OK |
| 20 | `20_step.png` | After Step while paused | One-frame advance chrome | OK |
| 21 | `21_slow.png` | Slow Motion selected | Speed radio | OK |
| 22 | `22_restart.png` | After Restart (params kept) | Flat string; Oscillate+tools kept | OK |
| 23 | `23_reset_all.png` | After Reset All | Initial chrome | OK |
| 24 | `24_combined.png` | Oscillate+Loose+tools+params | Complex stack OK | OK |
| 25 | `25_pulse_mode_controls.png` | Pulse mode → Pulse Width UI | Conditional control | OK |
| 26 | `26_center_dash_ref_off.png` | Ref OFF · center still on | Separation proof | OK |

Each PNG has companion `*.meta.txt` with Model snapshot fields.

Capture test: `test/wave_on_a_string/visual/phase5_visual_qa_capture_test.dart`  
Structural gates: `test/wave_on_a_string/visual/phase5_structural_visual_test.dart`
