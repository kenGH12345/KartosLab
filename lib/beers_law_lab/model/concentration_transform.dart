/// PhET `ConcentrationTransform` — model mol/L ↔ view mM / µM.
enum ConcentrationUnit {
  /// millimolar — scale 1000
  millimolar,

  /// micromolar — scale 1_000_000
  micromolar,
}

class ConcentrationTransform {
  const ConcentrationTransform._(this.scale, this.unit, this.unitLabel);

  final double scale;
  final ConcentrationUnit unit;
  final String unitLabel;

  static const ConcentrationTransform millimolar =
      ConcentrationTransform._(1000, ConcentrationUnit.millimolar, 'mM');

  static const ConcentrationTransform micromolar =
      ConcentrationTransform._(1000000, ConcentrationUnit.micromolar, 'µM');

  /// Model (M) → view (mM or µM).
  double modelToView(double modelConcentration) =>
      modelConcentration * scale;

  /// View (mM or µM) → model (M).
  double viewToModel(double viewConcentration) =>
      viewConcentration / scale;
}
