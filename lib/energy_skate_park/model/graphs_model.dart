import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/data_sample.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';

enum GraphIndependentVariable { position, time }

/// GraphsModel.ts — PARABOLA + DOUBLE_WELL; dense sampling.
class GraphsModel extends TrackSetModel {
  GraphsModel()
      : super(
          trackScenes: const [TrackScene.parabola, TrackScene.doubleWell],
          tracksConfigurable: true,
          defaultSaveSamples: true,
          saveSampleInterval: 0.01,
          sampleFadeDecay: 0.5,
          maxNumberOfSamples: 1000,
        );

  bool kineticVisible = true;
  bool potentialVisible = true;
  bool thermalVisible = true;
  bool totalVisible = true;
  int energyGraphZoomIndex = EspConstants.defaultEnergyGraphZoomIndex;
  GraphIndependentVariable independentVariable =
      GraphIndependentVariable.position;
  bool energyGraphExpanded = true;

  /// Index into [dataSamples] for graph cursor readout; null = latest sample.
  int? cursorSampleIndex;

  /// Resolves cursor sample from history (never recomputes energy).
  DataSample? get cursorSample {
    if (dataSamples.isEmpty) return null;
    final i = (cursorSampleIndex ?? dataSamples.length - 1)
        .clamp(0, dataSamples.length - 1);
    return dataSamples[i];
  }

  @override
  void reset() {
    super.reset();
    kineticVisible = true;
    potentialVisible = true;
    thermalVisible = true;
    totalVisible = true;
    energyGraphZoomIndex = EspConstants.defaultEnergyGraphZoomIndex;
    independentVariable = GraphIndependentVariable.position;
    energyGraphExpanded = true;
    cursorSampleIndex = null;
    clearEnergyData();
  }
}
