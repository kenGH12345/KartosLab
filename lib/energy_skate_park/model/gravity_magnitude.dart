import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';

/// Gravity magnitude helpers (Skater.gravityMagnitudeProperty + PhysicalComboBox).
class GravityMagnitude {
  GravityMagnitude._();

  static double clamp(double g) => g.clamp(
        EspConstants.gravityMagnitudeMin,
        EspConstants.gravityMagnitudeMax,
      );

  /// GravitySlider / NumberControl constrainValue (default interval 1).
  static double roundToInterval(double g, {double interval = EspConstants.gravityInterval}) {
    if (interval <= 0) return clamp(g);
    return clamp((g / interval).round() * interval);
  }

  /// Finer rounding used by NumberControl delta / shift steps.
  static double roundFine(double g) =>
      roundToInterval(g, interval: EspConstants.gravityShiftInterval);

  /// Exact preset match (PhysicalComboBox.ts uses ===).
  static bool isMoon(double g) => g == EspConstants.moonGravity;
  static bool isEarth(double g) => g == EspConstants.earthGravity;
  static bool isJupiter(double g) => g == EspConstants.jupiterGravity;

  static bool isPreset(double g) => isMoon(g) || isEarth(g) || isJupiter(g);

  /// Adapter value for ComboBox: preset number or null (= Custom).
  static double? comboAdapterValue(double g) {
    if (isMoon(g)) return EspConstants.moonGravity;
    if (isEarth(g)) return EspConstants.earthGravity;
    if (isJupiter(g)) return EspConstants.jupiterGravity;
    return null;
  }

  static String display(double g) =>
      '${clamp(g).toStringAsFixed(1)} ${EspStrings.gravityUnit}';
}
