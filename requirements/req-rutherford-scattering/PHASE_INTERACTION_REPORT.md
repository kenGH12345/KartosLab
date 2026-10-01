# PHASE_INTERACTION_REPORT

## Done

- Gun ON/OFF continuous emission; OFF keeps existing particles
- Energy slider → new particle speed + clears particles
- Protons / Neutrons controls with userInteraction drag gating
- Traces toggle (view property on model)
- Atomic ↔ Nuclear scale switch + particle clear
- Pause / Resume via SimulationClock
- Step = manualStepDt 1/60
- Reset All via KratosResetAllButton → full model + traces
- Two independent screens (Rutherford Atom / Plum Pudding)

## Remaining

- Emulator manual QA checklist sign-off
- Legend / panel spacing visual QA

## P0

0 for wired interactions

## P1

- Foil size / gun placement vs PhET screenshots
- Energy slider thumb color (PhET blue vs current)
- Scene radio currently in panel stack (PhET: left vertical)

## P2

- a11y labels

## Tests

Model interaction contracts covered in unit tests

## Analyze

0 errors

## Build

Pending

## Known Differences

- Play/Step icons are Material glyphs inside PhET-colored round buttons (not scenery-phet SVG paths) — acceptable interim; Reset All uses L0 KratosResetAllButton
