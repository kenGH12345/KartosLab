import 'dart:math' as math;
import 'dart:ui';

import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/model/save_sample_model.dart';
import 'package:kratos/energy_skate_park/model/skater_image_set.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';
import 'package:kratos/energy_skate_park/render/esp_render_data.dart';

class EspRenderBuilder {
  EspRenderBuilder._();

  static EspRenderData build(EspController controller, {Size? size}) {
    final model = controller.model;
    final view = controller.view;
    final canvasSize = size ?? const Size(1024, 618);
    final mvt = EspMvt.forPlayArea(canvasSize);

    final polylines = <EspTrackPolyline>[];
    for (final track in model.tracks) {
      if (!track.physical && model.tracks.length > 1) {
        // Track-set: only draw physical scene track.
        continue;
      }
      if (!track.physical && model.tracks.length == 1) continue;
      final pts = <Offset>[];
      final n = math.max(40, 20 * (track.controlPoints.length - 1));
      final u0 = track.minPoint;
      final u1 = track.maxPoint;
      for (var i = 0; i <= n; i++) {
        final u = u0 + (u1 - u0) * (i / n);
        pts.add(mvt.modelToViewXY(track.getX(u), track.getY(u)));
      }
      if (pts.length >= 2) {
        polylines.add(EspTrackPolyline(points: pts, physical: track.physical));
      }
    }

    // Playground: draw all tracks even if flagged.
    if (model.tracks.isNotEmpty && polylines.isEmpty) {
      for (final track in model.tracks) {
        final pts = <Offset>[];
        final n = math.max(40, 20 * (track.controlPoints.length - 1));
        for (var i = 0; i <= n; i++) {
          final u = track.minPoint +
              (track.maxPoint - track.minPoint) * (i / n);
          pts.add(mvt.modelToViewXY(track.getX(u), track.getY(u)));
        }
        if (pts.length >= 2) {
          polylines
              .add(EspTrackPolyline(points: pts, physical: track.physical));
        }
      }
    }

    final skater = model.skater;
    final skaterCenter =
        mvt.modelToViewXY(skater.positionX, skater.positionY);

    final pathDots = <Offset>[];
    if (model is SaveSampleModel && model.pathVisible) {
      for (final s in model.dataSamples) {
        pathDots.add(mvt.modelToViewXY(s.positionX, s.positionY));
      }
    }

    final cpViews = <Offset>[];
    for (final track in model.tracks) {
      if (!track.configurable) continue;
      for (final cp in track.controlPoints) {
        if (!cp.visible) continue;
        cpViews.add(mvt.modelToViewXY(cp.x, cp.y));
      }
    }

    return EspRenderData(
      size: canvasSize,
      trackPolylines: polylines,
      skaterCenter: skaterCenter,
      skaterAngle: skater.angle,
      skaterDirectionLeft: skater.direction == 'left',
      kineticEnergy: skater.kineticEnergy,
      potentialEnergy: skater.potentialEnergy,
      thermalEnergy: skater.thermalEnergy,
      totalEnergy: skater.totalEnergy,
      speed: math.sqrt(
        skater.velocityX * skater.velocityX +
            skater.velocityY * skater.velocityY,
      ),
      pieChartVisible: view.pieChartVisible,
      barGraphVisible: view.barGraphVisible,
      speedVisible: view.speedVisible,
      gridVisible: view.gridVisible,
      pathDots: pathDots,
      controlPointViews: cpViews,
      referenceHeight: skater.referenceHeight,
      referenceHeightVisible: view.referenceHeightVisible,
      skaterMassScale: SkaterImageSet.massToImageScale(skater.mass),
      selectedSkaterIndex: view.selectedSkaterIndex,
    );
  }
}
