import 'current_units.dart';
import 'ohms_law_constants.dart';
import 'ohms_law_property.dart';

/// PhET `OhmsLawModel.js` (1.5.0-dev.6) — physics + unit display state only.
///
/// ```
/// I(mA) = 1000 * V / R
/// ```
///
/// [currentUnitsProperty] is display-only and is **not** cleared by [reset].
class OhmsLawModel {
  OhmsLawModel() {
    voltageProperty = NumberProperty(
      OhmsLawConstants.voltageRange.defaultValue,
      range: OhmsLawConstants.voltageRange,
    );
    resistanceProperty = NumberProperty(
      OhmsLawConstants.resistanceRange.defaultValue,
      range: OhmsLawConstants.resistanceRange,
    );
    currentProperty = DerivedProperty<double>(
      [voltageProperty, resistanceProperty],
      () => computeCurrent(voltageProperty.value, resistanceProperty.value),
    );
    currentUnitsProperty = EnumProperty<CurrentUnit>(CurrentUnit.sourceDefault);
  }

  late final NumberProperty voltageProperty;
  late final NumberProperty resistanceProperty;

  /// Current in **milliamps** (source `units: 'mA'`). Never rewritten by units.
  late final DerivedProperty<double> currentProperty;

  /// Display unit — default MILLIAMPS; **not** reset by [reset].
  late final EnumProperty<CurrentUnit> currentUnitsProperty;

  /// Convenience getters (axon `.value`).
  double get voltage => voltageProperty.value;
  double get resistance => resistanceProperty.value;
  double get current => currentProperty.value;
  CurrentUnit get currentUnits => currentUnitsProperty.value;

  set voltage(double v) => voltageProperty.value = v;
  set resistance(double r) => resistanceProperty.value = r;
  set currentUnits(CurrentUnit u) => currentUnitsProperty.value = u;

  /// PhET `currentUnitsNameProperty` — enum name string.
  String get currentUnitsName => currentUnitsProperty.value.sourceName;

  /// Source `reset()` — voltage + resistance only.
  void reset() {
    voltageProperty.reset();
    resistanceProperty.reset();
  }

  /// Normalized voltage over [OhmsLawConstants.voltageRange].
  double getNormalizedVoltage() {
    final range = OhmsLawConstants.voltageRange;
    return (voltageProperty.value - range.min) / range.length;
  }

  /// Normalized current over [currentRangeMilliamps].
  double getNormalizedCurrent() {
    final range = currentRangeMilliamps;
    return (currentProperty.value - range.min) / range.length;
  }

  /// Normalized resistance over [OhmsLawConstants.resistanceRange].
  double getNormalizedResistance() {
    final range = OhmsLawConstants.resistanceRange;
    return (resistanceProperty.value - range.min) / range.length;
  }

  ///
  /// PhET `getFixedCurrent()` — **string** for readout / a11y.
  ///
  /// ## VD-03 (SOURCE QUIRK — do not "fix")
  ///
  /// When units == AMPS, source divides mA by **100** (not 1000):
  /// ```js
  /// current = current / 100;
  /// ```
  /// Sound normalization correctly uses `/1000`. Flutter mirrors `/100`.
  String getFixedCurrent() {
    var current = currentProperty.value;
    final units = currentUnitsProperty.value;
    if (units == CurrentUnit.amps) {
      current = current / 100.0; // VD-03: source-exact
    }
    return toFixed(current, units.sigFigs);
  }

  void dispose() {
    currentProperty.dispose();
    voltageProperty.dispose();
    resistanceProperty.dispose();
    currentUnitsProperty.dispose();
  }

  /// `computeCurrent` — returns milliamps.
  static double computeCurrent(double voltage, double resistance) {
    return OhmsLawConstants.amperesToMilliamps * voltage / resistance;
  }

  static double getMaxCurrent() {
    return computeCurrent(
      OhmsLawConstants.voltageRange.max,
      OhmsLawConstants.resistanceRange.min,
    );
  }

  static double getMinCurrent() {
    return computeCurrent(
      OhmsLawConstants.voltageRange.min,
      OhmsLawConstants.resistanceRange.max,
    );
  }

  /// Cached-equivalent current range in mA: `[getMinCurrent, getMaxCurrent]`.
  static OhmsLawRange get currentRangeMilliamps => OhmsLawRange(
        getMinCurrent(),
        getMaxCurrent(),
        getMinCurrent(), // default unused for this range
      );
}
