import 'beaker_solution.dart';
import 'ph_model.dart';
import 'solution_derived_properties.dart';

/// Micro screen model — PhET `MicroModel.ts` + `MicroSolution`.
class MicroModel extends PhModel {
  MicroModel({super.autoFillEnabled = true}) {
    derived = SolutionDerivedProperties(
      pH: solution.pH,
      totalVolume: solution.totalVolume,
    );
    solution.addListener(_syncDerived);
  }

  late final SolutionDerivedProperties derived;

  void _syncDerived() {
    derived.update(pH: solution.pH, totalVolume: solution.totalVolume);
  }

  @override
  void dispose() {
    solution.removeListener(_syncDerived);
    super.dispose();
  }
}

/// Convenience: Micro solution is the same [BeakerSolution] with derived props
/// owned by [MicroModel].
typedef MicroSolution = BeakerSolution;
