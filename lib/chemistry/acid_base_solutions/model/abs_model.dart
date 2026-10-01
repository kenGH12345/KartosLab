import 'abs_beaker.dart';
import 'abs_conductivity_tester.dart';
import 'abs_ph_meter.dart';
import 'abs_ph_paper.dart';
import 'solutions/aqueous_solution.dart';

/// Base model — PhET `ABSModel.ts`.
abstract class AbsModel {
  AbsModel({
    required this.solutions,
    required AqueousSolution initialSolution,
  }) : _solution = initialSolution {
    beaker = AbsBeaker();
    pHMeter = AbsPhMeter(
      beaker: beaker,
      pHOfSolution: () => pH,
    );
    pHPaper = AbsPhPaper(
      beaker: beaker,
      pHOfSolution: () => pH,
      solution: () => solution,
    );
    conductivityTester = AbsConductivityTester(
      beaker: beaker,
      pHOfSolution: () => pH,
    );
  }

  final List<AqueousSolution> solutions;

  late final AbsBeaker beaker;
  late final AbsPhMeter pHMeter;
  late final AbsPhPaper pHPaper;
  late final AbsConductivityTester conductivityTester;

  AqueousSolution _solution;

  AqueousSolution get solution => _solution;

  /// Subclasses call this when selection changes.
  void selectSolution(AqueousSolution value) {
    if (!solutions.contains(value)) {
      throw ArgumentError('Solution not in this screen model');
    }
    if (identical(_solution, value)) return;
    _solution = value;
    pHPaper.onSolutionOrPhChanged();
  }

  /// pH of the selected solution.
  double get pH => _solution.pH;

  /// Tool resets shared by both screens. Subclasses extend for solution state.
  void reset() {
    pHMeter.reset();
    pHPaper.reset();
    conductivityTester.reset();
  }
}
