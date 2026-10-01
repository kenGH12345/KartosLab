import 'parallel_system.dart';
import 'series_system.dart';

/// Systems screen. Series and parallel both exist. `js/systems/model/SystemsModel.ts`.
///
/// Which one is on screen is a view property. [reset] restores both, including
/// the one the view is not showing.
class SystemsModel {
  SystemsModel()
      : seriesSystem = SeriesSystem(),
        parallelSystem = ParallelSystem();

  final SeriesSystem seriesSystem;
  final ParallelSystem parallelSystem;

  void reset() {
    seriesSystem.reset();
    parallelSystem.reset();
  }
}
