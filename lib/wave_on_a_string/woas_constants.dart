/// PhET `WOASConstants.ts` — simulation constants for Wave on a String.
///
/// Source: wave-on-a-string 1.3.0-dev.0
library;

import 'dart:math' as math;

/// Maximum start / drive amplitude in centimeters (`MAX_START_AMPLITUDE_CM`).
const double maxStartAmplitudeCm = 1.3;

/// Number of discrete string beads (`NUMBER_OF_BEADS`).
const int numberOfBeads = 61;

/// Model units per centimeter (`MODEL_UNITS_PER_CM`).
///
/// Oscillate/Pulse: `y[0] = amplitudeCm * modelUnitsPerCm * sin(...)`.
const double modelUnitsPerCm = 80;

/// Conceptual frames per second used by tension / evolve cadence (`FRAMES_PER_SECOND`).
const double framesPerSecond = 50;

/// Fixed subdivision for `manualStep` (`FRAME_DURATION = 1/50`).
const double frameDuration = 1 / framesPerSecond;

/// Horizontal spacing between beads in model units (`MODEL_UNITS_PER_GAP`).
const double modelUnitsPerGap = 10;

/// View mapping constants (for Phase 2; kept for coordinate docs).
const double viewOriginX = 150;
const double viewOriginY = 265;
const double scaleFromOriginal = 1.25;

/// Last bead index.
const int lastIndex = numberOfBeads - 1;

/// Next-to-last bead index (boundary neighbor).
const int nextToLastIndex = numberOfBeads - 2;

/// Default control values (source `NumberProperty` defaults).
const double defaultTension = 0.8;
const double defaultDamping = 0.2;
const double defaultFrequencyHz = 1.50;
const double defaultPulseWidthS = 0.5;
const double defaultAmplitudeCm = 0.75;

/// Control ranges (source `Range`).
const double tensionMin = 0.2;
const double tensionMax = 0.8;
const double dampingMin = 0.0;
const double dampingMax = 1.0;
const double frequencyMinHz = 0.0;
const double frequencyMaxHz = 3.0;
const double pulseWidthMinS = 0.2;
const double pulseWidthMaxS = 1.0;
const double amplitudeMinCm = 0.0;

/// Soft dt limiter seed (`lastDtProperty` default 0.03).
const double defaultLastDt = 0.03;

/// Flatness heuristic for `isStringStill` (`FLAT_IN_A_ROW_FOR_STILL`).
const int flatInARowForStill = 4;

/// Linear map used by PhET `dot/js/util/linear` / `Utils.linear`.
double linearMap(
  double a1,
  double a2,
  double b1,
  double b2,
  double a3,
) {
  return (b2 - b1) / (a2 - a1) * (a3 - a1) + b1;
}

/// Source `tensionFactor` from `manualStep` (maps tension → evolve cadence).
double tensionFactorFor(double tension) {
  return linearMap(
    math.sqrt(tensionMin),
    math.sqrt(tensionMax),
    0.2,
    1.0,
    math.sqrt(tension),
  );
}

/// Source `minDt` from `manualStep`.
double minDtFor({
  required double tension,
  required double speedMultiplier,
}) {
  return 1 / (framesPerSecond * tensionFactorFor(tension) * speedMultiplier);
}
