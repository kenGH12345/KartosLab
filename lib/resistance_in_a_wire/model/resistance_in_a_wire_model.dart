import 'resistance_in_a_wire_constants.dart';
import 'resistance_in_a_wire_property.dart';

/// PhET `ResistanceInAWireModel.ts` (1.8.0-dev.0) — physics only.
///
/// ```
/// R(Ω) = ρ(Ω·cm) * L(cm) / A(cm²)
/// ```
///
/// No display-unit property. No `step(dt)`. View/sound/a11y stay out.
class ResistanceInAWireModel {
  ResistanceInAWireModel() {
    resistivityProperty = NumberProperty(
      ResistanceInAWireConstants.resistivityRange.defaultValue,
      range: ResistanceInAWireConstants.resistivityRange,
    );
    lengthProperty = NumberProperty(
      ResistanceInAWireConstants.lengthRange.defaultValue,
      range: ResistanceInAWireConstants.lengthRange,
    );
    areaProperty = NumberProperty(
      ResistanceInAWireConstants.areaRange.defaultValue,
      range: ResistanceInAWireConstants.areaRange,
    );
    resistanceProperty = DerivedProperty<double>(
      [resistivityProperty, lengthProperty, areaProperty],
      () => computeResistance(
        resistivityProperty.value,
        lengthProperty.value,
        areaProperty.value,
      ),
    );
  }

  late final NumberProperty resistivityProperty;
  late final NumberProperty lengthProperty;
  late final NumberProperty areaProperty;

  /// Resistance in **ohms** (source `units: 'Ω'`).
  late final DerivedProperty<double> resistanceProperty;

  double get resistivity => resistivityProperty.value;
  double get length => lengthProperty.value;
  double get area => areaProperty.value;
  double get resistance => resistanceProperty.value;

  set resistivity(double v) => resistivityProperty.value = v;
  set length(double v) => lengthProperty.value = v;
  set area(double v) => areaProperty.value = v;

  /// Source `reset()` — independent properties only; R re-derives.
  void reset() {
    resistivityProperty.reset();
    lengthProperty.reset();
    areaProperty.reset();
  }

  /// PhET `getFormattedResistanceValue` — panel / a11y readout string.
  String getFormattedResistanceValue([double? value]) {
    final r = value ?? resistanceProperty.value;
    return toFixed(r, ResistanceInAWireConstants.getResistanceDecimals(r));
  }

  /// Slider readout string — always 2 decimals (`SLIDER_READOUT_DECIMALS`).
  String getFormattedSliderValue(double value) {
    return toFixed(value, ResistanceInAWireConstants.sliderReadoutDecimals);
  }

  /// Formula letter scale from `FormulaNode`:
  /// `scaleMagnitude = (7 / defaultValue) * value + 1`.
  ///
  /// VD-02: **no** R size cap — source ignores `cappedSize`.
  double formulaScaleMagnitude(double value, double defaultValue) {
    return ResistanceInAWireConstants.formulaLetterScaleNumerator /
            defaultValue *
            value +
        1.0;
  }

  void dispose() {
    resistanceProperty.dispose();
    resistivityProperty.dispose();
    lengthProperty.dispose();
    areaProperty.dispose();
  }

  /// Core formula — ohms.
  static double computeResistance(
    double resistivity,
    double length,
    double area,
  ) {
    return resistivity * length / area;
  }

  static double getMinResistance() {
    return computeResistance(
      ResistanceInAWireConstants.resistivityRange.min,
      ResistanceInAWireConstants.lengthRange.min,
      ResistanceInAWireConstants.areaRange.max,
    );
  }

  static double getMaxResistance() {
    return computeResistance(
      ResistanceInAWireConstants.resistivityRange.max,
      ResistanceInAWireConstants.lengthRange.max,
      ResistanceInAWireConstants.areaRange.min,
    );
  }
}
