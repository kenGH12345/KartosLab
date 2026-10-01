import 'molarity_math.dart';

/// Source: `js/molarity/MolarityConstants.js` + `VerticalSlider.js` keyboard options.
///
/// Molarity is a **separate** PhET sim from Beer's Law Lab Concentration.
/// There is **no** Shaker / Dropper / Probe / Faucet / Drain / Evaporation /
/// `model.step(dt)` in this simulation.
class MolarityConstants {
  MolarityConstants._();

  // --- Solute amount (mol) ---
  static const double soluteAmountMin = 0.0;
  static const double soluteAmountMax = 1.0;
  static const double soluteAmountDefault = 0.5;
  static const int soluteAmountDecimalPlaces = 3;

  // --- Solution volume (L) ---
  static const double volumeMin = 0.2;
  static const double volumeMax = 1.0;
  static const double volumeDefault = 0.5;
  static const int volumeDecimalPlaces = 3;

  /// Concentration display bar range (M): `nMax / Vmin` = 1 / 0.2 = 5.
  /// Actual dissolved concentration is still capped by each solute's `C_sat`.
  static const double concentrationDisplayMin = 0.0;
  static const double concentrationDisplayMax =
      soluteAmountMax / volumeMin; // 5.0

  /// Source: `CONCENTRATION_DECIMAL_PLACES` — applied in the Model Derived value.
  static const int concentrationDecimalPlaces = 3;

  /// Source: `RANGE_DECIMAL_PLACES` (view dual labels).
  static const int rangeDecimalPlaces = 1;

  /// Source: `VerticalSlider` `keyboardStep`.
  static const double keyboardStep = 0.050;

  /// Source: `VerticalSlider` `shiftKeyboardStep` = `10^(-decimalPlaces)`.
  static const double shiftKeyboardStep = 0.001;

  /// Source: `PrecipitateNode.PARTICLES_PER_MOLE` — **global**, not per-solute.
  static const int particlesPerMole = 200;

  /// Source: `PrecipitateNode.PARTICLE_LENGTH`.
  static const double particleLength = 5.0;

  /// Canonical layout (no MVT): `MolarityScreenView` layoutBounds.
  static const double layoutWidth = 1100;
  static const double layoutHeight = 700;

  /// Clamp + `toFixedNumber` for solute amount (slider contract).
  static double constrainSoluteAmount(double value) {
    final clamped = value.clamp(soluteAmountMin, soluteAmountMax).toDouble();
    return MolarityMath.toFixedNumber(clamped, soluteAmountDecimalPlaces);
  }

  /// Clamp + `toFixedNumber` for volume (slider contract).
  static double constrainVolume(double value) {
    final clamped = value.clamp(volumeMin, volumeMax).toDouble();
    return MolarityMath.toFixedNumber(clamped, volumeDecimalPlaces);
  }
}
