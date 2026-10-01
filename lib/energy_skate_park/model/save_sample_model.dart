import 'package:kratos/energy_skate_park/model/data_sample.dart';
import 'package:kratos/energy_skate_park/model/esp_model.dart';
import 'package:kratos/energy_skate_park/model/skater_state.dart';

/// EnergySkateParkSaveSampleModel.ts — samples on fixed physics steps.
class SaveSampleModel extends EspModel {
  SaveSampleModel({
    super.skater,
    super.tracks,
    super.friction,
    super.isStickingToTrack,
    this.saveSampleInterval = 0.1,
    this.sampleFadeDecay = 0.95,
    this.maxNumberOfSamples = 50,
    this.defaultSaveSamples = true,
  }) : pathVisible = defaultSaveSamples;

  final double saveSampleInterval;
  final double sampleFadeDecay;
  final int maxNumberOfSamples;
  final bool defaultSaveSamples;

  final List<DataSample> dataSamples = [];
  bool pathVisible;
  bool preventSampleSave = false;
  bool limitNumberOfSamples = true;

  double timeSinceSampleSave = 0;
  double sampleTime = 0;

  @override
  void onAfterPhysicsStep(double dt, SkaterState updated) {
    if (!pathVisible) return;
    timeSinceSampleSave += dt;

    if (!preventSampleSave && timeSinceSampleSave > saveSampleInterval) {
      dataSamples.add(DataSample(
        skaterState: updated.copy(),
        friction: friction,
        time: sampleTime,
        stickingToTrack: isStickingToTrack,
        fadeDecay: sampleFadeDecay,
      ));
      timeSinceSampleSave = 0;
      sampleTime += dt;
    }

    if (limitNumberOfSamples && dataSamples.length > maxNumberOfSamples) {
      final n = dataSamples.length - maxNumberOfSamples;
      for (var i = 0; i < n; i++) {
        dataSamples[i].initiateRemove();
      }
    }

    final toRemove = <DataSample>[];
    for (final s in dataSamples) {
      if (s.step(dt)) toRemove.add(s);
    }
    if (toRemove.isNotEmpty) {
      dataSamples.removeWhere(toRemove.contains);
    }
  }

  void clearEnergyData() {
    dataSamples.clear();
    sampleTime = 0;
    timeSinceSampleSave = 0;
  }

  @override
  void reset() {
    super.reset();
    clearEnergyData();
    pathVisible = defaultSaveSamples;
    preventSampleSave = false;
  }
}
