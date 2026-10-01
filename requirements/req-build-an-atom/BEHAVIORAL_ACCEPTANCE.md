# Build an Atom — Behavioral Acceptance Matrix (Phase 6)

Evidence root: `test/chemistry/build_an_atom/behavioral_acceptance_test.dart`  
Harness: `test/chemistry/build_an_atom/behavioral_harness.dart`  
(Interaction path = View `GestureDetector` → `beginDrag`/`endDrag`, plus UI taps.)

| Area | Task | Result | Evidence |
| --- | --- | --- | --- |
| Atom | Hydrogen (A) | PASS | behavioral_acceptance_test A |
| Atom | Helium (B) | PASS | B |
| Atom | Ion + (C) | PASS | C |
| Atom | Ion − (D) | PASS | D |
| Atom | Isotope (E) | PASS | E |
| Atom | Empty nucleus (F) | PASS | F |
| Atom | Unstable (G) | PASS | G |
| Atom | Shell/Cloud ×10 (H) | PASS | H |
| Atom | Remove particle (I) | PASS | I |
| Atom | Bucket maxima (J) | PASS | J |
| Atom | Capture / round-trip (K/L) | PASS | K/L |
| Atom | Accordion ×10 (M) | PASS | M |
| Atom | Periodic Table sync (N) | PASS | N |
| Symbol | H/He/C / ions (O) | PASS | O |
| Symbol | ChargeMeter −2..+2 (P) | PASS | P |
| Symbol | Atom↔Symbol sync (Q) | PASS | Q |
| Game | Level selection 1–4 (R) | PASS | R |
| Game | Level 1 five correct (S) | PASS | S |
| Game | Level 2 charge/mass (T) | PASS | T |
| Game | Level 3 / 4 (U/V) | PASS | U/V |
| Game | Retry (W/X) | PASS | W/X |
| Game | Show Answer (Y/Z) | PASS | Y/Z |
| Game | Timer OFF/ON + retry (AA–AC) | PASS | AA/AB/AC |
| Game | Reset vs Start Over (AD–AF) | PASS | AD/AE/AF |
| Game | Double action (AG) | PASS | AG |
| Cross-screen | Rapid switch (AH) | PASS | AH |
| Lifecycle | Reset mid-animation (AI) | PASS | AI |
| Keyboard | WASD / no answer corrupt (AJ–AL) | PASS | AJ/AK |
| Educational | Carbon-12 (AM) | PASS | AM |
| Educational | Carbon +1 (AN) | PASS | AN |
| Educational | Isotope pair (AO) | PASS | AO |
| Sanity | 0p+e explorative (Reality) | PASS | Reality group |

## Phase 6 behavioral fix

| Issue | Fix |
| --- | --- |
| Game interactive PT cells (He/C/…) overflowed answer pane (~504px in ~360px half-width) | `GameInteractivePeriodicTable` wrapped in `FittedBox` so all Z remain tappable |

## P2 (unchanged from Phase 5)

1. Audio — no original mp3 in BAA repo; hooks only  
2. PhetFont / Symbol baseline — Arial platform glyph micro-diff  

## Gate

- Atom / Symbol / Game real-user tasks: PASS  
- No hidden UX shortcuts added  
- Home: PASS (Phase 8 formal entry)  
- Android: VERIFIED (Phase 9 `integration_test/build_an_atom_android_smoke_test.dart` on emulator-5554)  
