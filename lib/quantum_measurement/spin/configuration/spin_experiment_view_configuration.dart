/// View configuration for one Spin experiment — derived from SpinModel, no RNG.
library;

import '../../spin/model/spin_model.dart';

class SpinExperimentViewConfiguration {
  const SpinExperimentViewConfiguration({
    required this.experiment,
    required this.sourceMode,
    required this.usingSingleApparatus,
    required this.sg0IsZ,
    required this.sg1IsZ,
    required this.sg2IsZ,
    required this.showSg0,
    required this.showSg1,
    required this.showSg2,
    required this.showMd0,
    required this.showMd1,
    required this.showMd2,
    required this.showHistograms,
    required this.blockingMode,
    required this.sg0DirectionControllable,
    required this.sg1DirectionControllable,
    required this.sg2DirectionControllable,
    required this.isCustom,
  });

  final SpinExperiment experiment;
  final SourceMode sourceMode;
  final bool usingSingleApparatus;
  final bool sg0IsZ;
  final bool sg1IsZ;
  final bool sg2IsZ;
  final bool showSg0;
  final bool showSg1;
  final bool showSg2;
  final bool showMd0;
  final bool showMd1;
  final bool showMd2;
  final bool showHistograms;
  final BlockingMode blockingMode;
  final bool sg0DirectionControllable;
  final bool sg1DirectionControllable;
  final bool sg2DirectionControllable;
  final bool isCustom;

  /// Mirrors SpinModel multilink visibility / orientation table.
  factory SpinExperimentViewConfiguration.fromModel(SpinModel model) {
    final exp = model.experiment;
    final singleParticle = model.sourceMode == SourceMode.single;
    final multi = !exp.usingSingleApparatus;
    final custom = exp == SpinExperiment.custom;
    final blocking = model.sternGerlachs[0].blockingMode;

    return SpinExperimentViewConfiguration(
      experiment: exp,
      sourceMode: model.sourceMode,
      usingSingleApparatus: exp.usingSingleApparatus,
      sg0IsZ: model.sternGerlachs[0].isZOriented,
      sg1IsZ: model.sternGerlachs[1].isZOriented,
      sg2IsZ: model.sternGerlachs[2].isZOriented,
      showSg0: true,
      showSg1: multi && blocking != BlockingMode.blockUp,
      showSg2: multi && blocking != BlockingMode.blockDown,
      showMd0: singleParticle,
      showMd1: singleParticle,
      showMd2: singleParticle && multi,
      showHistograms: !singleParticle,
      blockingMode: blocking,
      sg0DirectionControllable: custom,
      sg1DirectionControllable: custom && !singleParticle,
      sg2DirectionControllable: custom,
      isCustom: custom,
    );
  }
}
