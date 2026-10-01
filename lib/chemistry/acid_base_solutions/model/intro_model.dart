import 'abs_model.dart';
import 'solutions/aqueous_solution.dart';
import 'solutions/strong_acid.dart';
import 'solutions/strong_base.dart';
import 'solutions/water.dart';
import 'solutions/weak_acid.dart';
import 'solutions/weak_base.dart';

/// Intro screen model — PhET `IntroModel.ts`.
///
/// Five preset solutions including [Water]. Does **not** expose concentration
/// or strength UI; defaults come from each solution's range.
class IntroModel extends AbsModel {
  factory IntroModel() {
    final water = Water();
    final strongAcid = StrongAcid();
    final weakAcid = WeakAcid();
    final strongBase = StrongBase();
    final weakBase = WeakBase();
    return IntroModel._(
      water: water,
      strongAcid: strongAcid,
      weakAcid: weakAcid,
      strongBase: strongBase,
      weakBase: weakBase,
      solutions: [water, strongAcid, weakAcid, strongBase, weakBase],
    );
  }

  IntroModel._({
    required this.water,
    required this.strongAcid,
    required this.weakAcid,
    required this.strongBase,
    required this.weakBase,
    required super.solutions,
  }) : super(initialSolution: water);

  final Water water;
  final StrongAcid strongAcid;
  final WeakAcid weakAcid;
  final StrongBase strongBase;
  final WeakBase weakBase;

  /// Mutable selection (AquaRadioButtonGroup target).
  set selectedSolution(AqueousSolution value) => selectSolution(value);

  AqueousSolution get selectedSolution => solution;

  @override
  void reset() {
    for (final s in solutions) {
      s.reset();
    }
    selectSolution(water);
    super.reset();
  }
}
