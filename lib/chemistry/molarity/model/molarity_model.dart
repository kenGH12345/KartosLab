import 'dart:math' as math;

import 'molarity_constants.dart';
import 'molarity_solute_catalog.dart';
import 'solute.dart';
import 'solution.dart';
import 'solvent.dart';

/// Model container — source: `js/molarity/model/MolarityModel.js`.
///
/// ```
/// MolarityModel
/// ├── solutes[9]
/// ├── solution (Solution)
/// ├── resetInProgressProperty   // mute audio during reset — not physics
/// └── maxPrecipitateAmount      // view particle pool sizing
/// ```
///
/// Pure reactive: **no** `step(dt)`. Presentation [valuesVisible] is not physics.
///
/// Isolation: this is **not** Beer's Law Lab Concentration — no Shaker /
/// Dropper / Probe / Faucet / Drain / Evaporation.
class MolarityModel {
  MolarityModel({
    List<Solute>? solutes,
    Solution? solution,
    Solute? initialSolute,
    double soluteAmount = MolarityConstants.soluteAmountDefault,
    double volume = MolarityConstants.volumeDefault,
    this.valuesVisible = false,
    Solvent solvent = const Solvent(),
  }) : solutes = List<Solute>.unmodifiable(
          solutes ?? MolaritySoluteCatalog.createCanonical(),
        ) {
    assert(this.solutes.isNotEmpty);
    this.solution = solution ??
        Solution(
          solvent: solvent,
          solute: initialSolute ?? this.solutes.first,
          soluteAmount: soluteAmount,
          volume: volume,
        );
    maxPrecipitateAmount = computeMaxPrecipitateAmount(this.solutes);
  }

  /// Cold-start defaults matching PhET.
  factory MolarityModel.defaults() => MolarityModel();

  /// Wrap an existing [Solution] (scenario / View identity preserved).
  factory MolarityModel.wrap({
    required List<Solute> solutes,
    required Solution solution,
    bool valuesVisible = false,
  }) =>
      MolarityModel(
        solutes: solutes,
        solution: solution,
        valuesVisible: valuesVisible,
      );

  final List<Solute> solutes;
  late final Solution solution;

  /// Presentation: Solution Values checkbox (source `valuesVisibleProperty`).
  /// Default `false`. Does **not** affect concentration / precipitate / color.
  bool valuesVisible;

  /// Source `resetInProgressProperty` — mute audio during reset.
  bool resetInProgress = false;

  /// Source `maxPrecipitateAmount` — size precipitate particle pool.
  late final double maxPrecipitateAmount;

  int get selectedSoluteIndex {
    final i = solutes.indexOf(solution.solute);
    return i < 0 ? 0 : i;
  }

  void selectSolute(int index) {
    if (index < 0 || index >= solutes.length) return;
    solution.setSolute(solutes[index]);
  }

  void setSoluteAmount(double v) => solution.setSoluteAmount(v);

  void setVolume(double v) => solution.setVolume(v);

  void setValuesVisible(bool v) {
    valuesVisible = v;
  }

  /// Source Reset All:
  /// 1) valuesVisible → false
  /// 2) solution.reset → Drink mix (solutes[0]), n=0.5, V=0.5
  ///
  /// Changing solute alone does **not** reset n/V.
  void reset() {
    resetInProgress = true;
    valuesVisible = false;
    solution.reset(
      solute: solutes.first,
      soluteAmount: MolarityConstants.soluteAmountDefault,
      volume: MolarityConstants.volumeDefault,
    );
    resetInProgress = false;
  }

  /// Source: min C_sat among solutes with Vmin / nMax.
  static double computeMaxPrecipitateAmount(List<Solute> solutes) {
    assert(solutes.isNotEmpty);
    final minSat =
        solutes.map((s) => s.saturatedConcentration).reduce(math.min);
    return Solution.computePrecipitateAmount(
      MolarityConstants.volumeMin,
      MolarityConstants.soluteAmountMax,
      minSat,
    );
  }
}
