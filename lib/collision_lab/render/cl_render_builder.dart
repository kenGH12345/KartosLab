import 'dart:ui';

import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';
import '../controller/collision_lab_controller.dart';
import '../model/play_area.dart';
import 'cl_mvt.dart';
import 'cl_render_data.dart';

class ClRenderBuilder {
  ClRenderBuilder._();

  static ClRenderData build(CollisionLabController controller) {
    final model = controller.model;
    final view = controller.view;
    final playArea = model.playArea;
    final mvt = ClMvt.forPlayArea(playArea);
    final playRect = mvt.modelToViewBounds(playArea.bounds);
    final balls = model.ballSystem.balls;
    final colors = CollisionLabColors.ballColors;

    final ballRenders = <ClBallRender>[];
    final velocityVectors = <ClVectorRender>[];
    final momentumVectors = <ClVectorRender>[];
    final changeInMomentumVectors = <ClVectorRender>[];

    for (var i = 0; i < balls.length; i++) {
      final ball = balls[i];
      final color = colors[(ball.index - 1) % colors.length];
      final center = mvt.modelToView(ball.position);
      final radius = mvt.modelToViewDeltaX(ball.radius);
      String? valueLabel;
      if (view.valuesVisible) {
        valueLabel =
            'm=${ball.mass.toStringAsFixed(CollisionLabConstants.displayDecimalPlaces)}';
      }
      ballRenders.add(ClBallRender(
        center: center,
        radius: radius,
        color: color,
        label: '${ball.index}',
        rotation: ball.rotation,
        valueLabel: valueLabel,
      ));

      if (view.velocityVectorVisible) {
        velocityVectors.add(ClVectorRender(
          tail: center,
          tip: center + mvt.modelToViewDelta(ball.velocity),
          color: CollisionLabColors.velocityVectorFill,
        ));
      }
      if (view.momentumVectorVisible && ball.momentum.magnitude > 1e-8) {
        momentumVectors.add(ClVectorRender(
          tail: center,
          tip: center + mvt.modelToViewDelta(ball.momentum),
          color: CollisionLabColors.momentumVectorFill,
        ));
      }

      if (model.ballSystem.supportsChangeInMomentum &&
          model.ballSystem.changeInMomentumVisible) {
        final dp = model.ballSystem.changeInMomentum[ball];
        if (dp != null && dp.magnitude > 1e-8) {
          changeInMomentumVectors.add(ClVectorRender(
            tail: center,
            tip: center + mvt.modelToViewDelta(dp),
            color: CollisionLabColors.changeInMomentumDashed,
          ));
        }
      }
    }

    Offset? com;
    if (model.ballSystem.centerOfMassVisible && balls.isNotEmpty) {
      com = mvt.modelToView(model.ballSystem.centerOfMass.position);
    }

    final pathTrails = <ClPathTrailRender>[];
    if (model.ballSystem.pathsVisible) {
      for (final ball in balls) {
        final pts = ball.path.dataPoints
            .map((p) => mvt.modelToView(p.position))
            .toList();
        if (pts.length >= 2) {
          pathTrails.add(ClPathTrailRender(
            points: pts,
            color: colors[(ball.index - 1) % colors.length]
                .withValues(alpha: 0.55),
          ));
        }
      }
      if (model.ballSystem.centerOfMassVisible) {
        final pts = model.ballSystem.centerOfMass.path.dataPoints
            .map((p) => mvt.modelToView(p.position))
            .toList();
        if (pts.length >= 2) {
          pathTrails.add(ClPathTrailRender(
            points: pts,
            color: CollisionLabColors.centerOfMassFill.withValues(alpha: 0.55),
          ));
        }
      }
    }

    final md = model.momentaDiagram;
    if (md.expanded) md.updateVectors();
    final mdBounds = md.bounds;
    final momentaVectors = <ClVectorRender>[];
    ClVectorRender? totalMomenta;
    if (md.expanded) {
      for (final ball in balls) {
        final v = md.ballToMomentaVector[ball]!;
        momentaVectors.add(ClVectorRender(
          tail: Offset(v.tailPosition.x, v.tailPosition.y),
          tip: Offset(v.tipPosition.x, v.tipPosition.y),
          color: colors[(ball.index - 1) % colors.length],
          label: '${ball.index}',
        ));
      }
      final t = md.totalMomentumVector;
      totalMomenta = ClVectorRender(
        tail: Offset(t.tailPosition.x, t.tailPosition.y),
        tip: Offset(t.tipPosition.x, t.tipPosition.y),
        color: CollisionLabColors.totalMomentumVectorFill,
        label: 'Σ',
      );
    }

    return ClRenderData(
      playAreaRect: playRect,
      reflectingBorder: playArea.reflectingBorder,
      gridVisible: playArea.gridVisible,
      is1d: playArea.dimension == PlayAreaDimension.one,
      balls: ballRenders,
      pathTrails: pathTrails,
      velocityVectors: velocityVectors,
      momentumVectors: momentumVectors,
      changeInMomentumVectors: changeInMomentumVectors,
      changeInMomentumOpacity: model.ballSystem.changeInMomentumOpacity,
      comPosition: com,
      comVisible: model.ballSystem.centerOfMassVisible,
      kineticEnergy: model.ballSystem.totalKineticEnergy,
      kineticEnergyVisible: view.kineticEnergyVisible,
      valuesVisible: view.valuesVisible,
      showReturnBalls: model.ballSystem.ballsNotInsidePlayArea,
      elapsedTime: model.elapsedTime,
      momentaExpanded: md.expanded,
      momentaVectors: momentaVectors,
      totalMomenta: totalMomenta,
      momentaBounds: Rect.fromLTRB(
        mdBounds.minX,
        mdBounds.minY,
        mdBounds.maxX,
        mdBounds.maxY,
      ),
      momentaZoom: md.zoom,
    );
  }
}
