import 'dart:math' as math;

import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/data_sample.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/full_track_set_model.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';

/// MeasureModel.ts — FullTrackSet + configurable + path samples + sensor probe.
class MeasureModel extends FullTrackSetModel {
  MeasureModel()
      : super(
          defaultSaveSamples: true,
          tracksConfigurable: true,
        );

  EspVec sensorProbePosition = const EspVec(-4, 1.5);
  EspVec sensorBodyPosition = const EspVec(0, 0);

  /// Updates skater.referenceHeight and refreshes PE/Total on all path samples
  /// (MeasureModel.ts:51-55).
  void setReferenceHeight(double h) {
    final href = h.clamp(
      EspConstants.referenceHeightMin,
      EspConstants.referenceHeightMax,
    );
    skater.referenceHeight = href;
    skater.updateEnergy();
    for (final s in dataSamples) {
      s.setNewReferenceHeight(href);
    }
  }

  /// Nearest [DataSample] within [thresholdViewPx] of [probeModel] in view space.
  /// SkaterPathSensorNode.ts — does NOT recompute energy.
  DataSample? findNearestSample(
    EspVec probeModel,
    EspMvt mvt, {
    double thresholdViewPx = EspConstants.probeThresholdViewPx,
  }) {
    final probeView = mvt.modelToView(probeModel);
    DataSample? best;
    var minD = thresholdViewPx;
    for (final s in dataSamples) {
      final sv = mvt.modelToViewXY(s.positionX, s.positionY);
      final d = math.sqrt(
        math.pow(sv.dx - probeView.dx, 2) + math.pow(sv.dy - probeView.dy, 2),
      );
      if (d < minD) {
        minD = d;
        best = s;
      }
    }
    return best;
  }

  @override
  void reset() {
    super.reset();
    sensorProbePosition = const EspVec(-4, 1.5);
    // sensorBodyPosition intentionally not reset (MeasureModel.ts:70-74).
  }
}
