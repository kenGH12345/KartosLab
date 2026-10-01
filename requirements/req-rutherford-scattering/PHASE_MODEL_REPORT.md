# PHASE_MODEL_REPORT

## Done

- Widget-free Model port of PhET RSBaseModel / Gun / AlphaParticle / AtomSpace / RutherfordAtom trajectory / PlumPuddingAtomSpace
- RutherfordAtomModel with Atomic↔Nuclear scenes (clears particles on switch — matches PhET)
- PlumPuddingAtomModel (straight-line only)
- Critical fix: `RsVec2.perpendicular = (y, -x)` matching PhET Vector2 (−π/2)
- Neutrons visual-only for physics (documented)
- Energy used as speed; Multilink-equivalent clears on energy/protons/neutrons/userInteraction

## Remaining

- Visual polish of nucleon packing (P1)
- Projector color profile (P2)

## P0

0 (core physics behaviors covered by unit tests)

## P1

- Nucleus nucleon layout vs shred ParticleAtom packing fidelity
- Scene radio left-column placement vs PhET

## P2

- Projector colors

## Tests

15/15 PASS (`test/rutherford_scattering/rutherford_model_test.dart`)

## Analyze

0 errors on `lib/rutherford_scattering`

## Build

Pending Phase 7

## Known Differences

- Nucleus nucleons: simplified radial cluster, not full shred ParticleAtom animation
- `userInteraction` clear-on-toggle matches PhET Multilink (may clear twice around slider drag)
