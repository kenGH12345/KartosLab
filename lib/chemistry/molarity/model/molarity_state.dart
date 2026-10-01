import 'molarity_model.dart';
import 'solute.dart';
import 'solution.dart';

/// Scenario-bound wrapper around [MolarityModel].
///
/// Keeps inquiry / scenario metadata; physics lives in [model].
/// Legacy getters (`solutes` / `solution` / `valuesVisible`) keep existing View.
class MolarityState {
  MolarityState({
    required this.scenarioId,
    required List<Solute> solutes,
    required Solution solution,
    required this.initialSoluteIndex,
    required this.initialSoluteAmount,
    required this.initialVolume,
    required this.initialValuesVisible,
    bool? valuesVisible,
  }) : model = MolarityModel.wrap(
          solutes: solutes,
          solution: solution,
          valuesVisible: valuesVisible ?? initialValuesVisible,
        );

  /// Direct wrap of an existing [MolarityModel].
  MolarityState.fromModel({
    required this.scenarioId,
    required this.model,
    required this.initialSoluteIndex,
    required this.initialSoluteAmount,
    required this.initialVolume,
    required this.initialValuesVisible,
  });

  /// Current scenario id (checkObjectives / inquiry).
  final String scenarioId;

  final MolarityModel model;

  /// Scenario reset targets.
  final int initialSoluteIndex;
  final double initialSoluteAmount;
  final double initialVolume;
  final bool initialValuesVisible;

  List<Solute> get solutes => model.solutes;
  Solution get solution => model.solution;

  bool get valuesVisible => model.valuesVisible;
  set valuesVisible(bool v) => model.valuesVisible = v;

  bool get resetInProgress => model.resetInProgress;
  double get maxPrecipitateAmount => model.maxPrecipitateAmount;

  /// Scenario reset: restore scenario initial params + valuesVisible initial.
  void reset() {
    model.resetInProgress = true;
    final idx = initialSoluteIndex.clamp(0, solutes.length - 1);
    solution.reset(
      solute: solutes[idx],
      soluteAmount: initialSoluteAmount,
      volume: initialVolume,
    );
    valuesVisible = initialValuesVisible;
    model.resetInProgress = false;
  }

  /// PhET Reset All (Drink mix / 0.5 / 0.5 / values off).
  void resetAllPhET() => model.reset();
}
