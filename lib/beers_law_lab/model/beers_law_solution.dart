import 'dart:ui';

import 'beers_law_constants.dart';
import 'color_range.dart';
import 'concentration_transform.dart';
import 'molar_absorptivity_data.dart';

/// Definition + mutable concentration — PhET `BeersLawSolution`.
///
/// Each [BeersLawModel] owns its own instances (not shared mutables).
class BeersLawSolution {
  BeersLawSolution({
    required this.id,
    required this.name,
    required this.formula,
    required this.molarAbsorptivityData,
    required this.concentrationMin,
    required this.concentrationMax,
    required this.concentrationDefault,
    required this.concentrationTransform,
    required this.colorRange,
    Color? saturatedColor,
  })  : saturatedColor = saturatedColor ?? colorRange.max,
        _concentration = concentrationDefault;

  final String id;
  final String name;
  final String? formula;
  final MolarAbsorptivityData molarAbsorptivityData;
  final double concentrationMin;
  final double concentrationMax;
  final double concentrationDefault;
  final ConcentrationTransform concentrationTransform;
  final ColorRange colorRange;
  final Color saturatedColor;

  double _concentration;

  double get concentration => _concentration;
  double get lambdaMax => molarAbsorptivityData.lambdaMax;

  double get displayConcentration =>
      concentrationTransform.modelToView(_concentration);

  double get displayConcentrationMin =>
      concentrationTransform.modelToView(concentrationMin);

  double get displayConcentrationMax =>
      concentrationTransform.modelToView(concentrationMax);

  Color get fluidColor {
    if (_concentration <= 0) return BeersLawConstants.waterColor;
    final distance = (_concentration - concentrationMin) /
        (concentrationMax - concentrationMin);
    return colorRange.interpolateLinear(distance.clamp(0.0, 1.0));
  }

  void setConcentration(double molesPerLiter) {
    _concentration = molesPerLiter.clamp(concentrationMin, concentrationMax);
  }

  void setDisplayConcentration(double viewValue) {
    setConcentration(concentrationTransform.viewToModel(viewValue));
  }

  void reset() {
    _concentration = concentrationDefault;
  }

  BeersLawSolution copyFresh() => BeersLawSolution(
        id: id,
        name: name,
        formula: formula,
        molarAbsorptivityData: molarAbsorptivityData,
        concentrationMin: concentrationMin,
        concentrationMax: concentrationMax,
        concentrationDefault: concentrationDefault,
        concentrationTransform: concentrationTransform,
        colorRange: colorRange,
        saturatedColor: saturatedColor,
      );

  /// Template catalog (ROYGBIV). NaCl absent. Use [createAll] for model-owned copies.
  static final List<BeersLawSolution> catalog = [
    BeersLawSolution(
      id: 'drinkMix',
      name: 'Drink mix',
      formula: null,
      molarAbsorptivityData: MolarAbsorptivityData.drinkMix,
      concentrationMin: 0,
      concentrationMax: 0.400,
      concentrationDefault: 0.100,
      concentrationTransform: ConcentrationTransform.millimolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 255, 225, 225),
        Color.fromARGB(255, 255, 0, 0),
      ),
    ),
    BeersLawSolution(
      id: 'cobaltIINitrate',
      name: 'Cobalt(II) nitrate',
      formula: 'Co(NO₃)₂',
      molarAbsorptivityData: MolarAbsorptivityData.cobaltIINitrate,
      concentrationMin: 0,
      concentrationMax: 0.400,
      concentrationDefault: 0.100,
      concentrationTransform: ConcentrationTransform.millimolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 255, 225, 225),
        Color.fromARGB(255, 255, 0, 0),
      ),
    ),
    BeersLawSolution(
      id: 'cobaltChloride',
      name: 'Cobalt(II) chloride',
      formula: 'CoCl₂',
      molarAbsorptivityData: MolarAbsorptivityData.cobaltChloride,
      concentrationMin: 0,
      concentrationMax: 0.250,
      concentrationDefault: 0.100,
      concentrationTransform: ConcentrationTransform.millimolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 255, 242, 242),
        Color.fromARGB(255, 255, 106, 106),
      ),
    ),
    BeersLawSolution(
      id: 'potassiumDichromate',
      name: 'Potassium dichromate',
      formula: 'K₂Cr₂O₇',
      molarAbsorptivityData: MolarAbsorptivityData.potassiumDichromate,
      concentrationMin: 0,
      concentrationMax: 0.000500,
      concentrationDefault: 0.000100,
      concentrationTransform: ConcentrationTransform.micromolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 255, 232, 210),
        Color.fromARGB(255, 255, 127, 0),
      ),
    ),
    BeersLawSolution(
      id: 'potassiumChromate',
      name: 'Potassium chromate',
      formula: 'K₂CrO₄',
      molarAbsorptivityData: MolarAbsorptivityData.potassiumChromate,
      concentrationMin: 0,
      concentrationMax: 0.000400,
      concentrationDefault: 0.000100,
      concentrationTransform: ConcentrationTransform.micromolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 255, 255, 199),
        Color.fromARGB(255, 255, 255, 0),
      ),
    ),
    BeersLawSolution(
      id: 'nickelIIChloride',
      name: 'Nickel(II) chloride',
      formula: 'NiCl₂',
      molarAbsorptivityData: MolarAbsorptivityData.nickelIIChloride,
      concentrationMin: 0,
      concentrationMax: 0.350,
      concentrationDefault: 0.100,
      concentrationTransform: ConcentrationTransform.millimolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 234, 244, 234),
        Color.fromARGB(255, 0, 128, 0),
      ),
    ),
    BeersLawSolution(
      id: 'copperSulfate',
      name: 'Copper(II) sulfate',
      formula: 'CuSO₄',
      molarAbsorptivityData: MolarAbsorptivityData.copperSulfate,
      concentrationMin: 0,
      concentrationMax: 0.200,
      concentrationDefault: 0.100,
      concentrationTransform: ConcentrationTransform.millimolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 222, 238, 255),
        Color.fromARGB(255, 30, 144, 255),
      ),
    ),
    BeersLawSolution(
      id: 'potassiumPermanganate',
      name: 'Potassium permanganate',
      formula: 'KMnO₄',
      molarAbsorptivityData: MolarAbsorptivityData.potassiumPermanganate,
      concentrationMin: 0,
      concentrationMax: 0.000800,
      concentrationDefault: 0.000100,
      concentrationTransform: ConcentrationTransform.micromolar,
      colorRange: const ColorRange(
        Color.fromARGB(255, 255, 235, 255),
        Color.fromARGB(255, 255, 0, 255),
      ),
      saturatedColor: const Color.fromARGB(255, 80, 0, 120),
    ),
  ];

  static List<BeersLawSolution> createAll() =>
      catalog.map((s) => s.copyFresh()).toList();
}
