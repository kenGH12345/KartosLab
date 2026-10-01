import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';
import '../collision_lab_strings.dart';
import '../controller/collision_lab_controller.dart';
import '../model/play_area.dart';
import '../painters/ball_painter.dart';
import '../painters/play_area_border_painter.dart';
import '../painters/play_area_painter.dart';
import '../painters/vector_painter.dart';
import '../render/cl_mvt.dart';
import '../render/cl_render_builder.dart';
import '../render/cl_render_data.dart';
import 'scale_bar.dart';

class PlayAreaWidget extends StatefulWidget {
  const PlayAreaWidget({super.key, required this.controller});

  final CollisionLabController controller;

  @override
  State<PlayAreaWidget> createState() => _PlayAreaWidgetState();
}

enum _DragKind { none, ball, velocityTip }

class _PlayAreaWidgetState extends State<PlayAreaWidget> {
  int? _dragIndex;
  _DragKind _dragKind = _DragKind.none;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final data = ClRenderBuilder.build(controller);
    final mvt = ClMvt.forPlayArea(controller.model.playArea);
    final is1d =
        controller.model.playArea.dimension == PlayAreaDimension.one;

    return Stack(
      children: [
        // Layer 0: play-area bg + grid/ticks + border (not a gesture target alone)
        Positioned.fill(
          child: CustomPaint(
            painter: PlayAreaPainter(data: data, mvt: mvt),
            child: const SizedBox.expand(),
          ),
        ),
        // Layer 1: balls (clipped) + vectors + pan gestures.
        // Must sit above grid paint and below IgnorePointer overlays.
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) =>
                _onPanStart(e.localPosition, mvt, data),
            onPointerMove: (e) {
              if (_dragKind != _DragKind.none) {
                _onPanUpdate(e.localPosition, mvt);
              }
            },
            onPointerUp: (_) => _onPanEnd(),
            onPointerCancel: (_) => _onPanEnd(),
            child: CustomPaint(
              painter: BallPainter(data: data),
              foregroundPainter: VectorPainter(
                data: data,
                showVelocityTips: controller.velocityTipsInteractive,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        // Border above clipped balls; IgnorePointer so it never blocks drag.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: PlayAreaBorderPainter(data: data),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        // Overlays must not steal hits over the play area / balls.
        if (is1d)
          Positioned(
            left: data.playAreaRect.left,
            top: data.playAreaRect.top - 28,
            child: IgnorePointer(
              child: ScaleBar(
                lengthMeters: CollisionLabConstants.scaleBarLengthMeters,
                orientation: Axis.horizontal,
                viewLength: mvt.modelToViewDeltaX(
                  CollisionLabConstants.scaleBarLengthMeters,
                ),
              ),
            ),
          )
        else
          Positioned(
            left: data.playAreaRect.left - 36,
            top: data.playAreaRect.top,
            child: IgnorePointer(
              child: ScaleBar(
                lengthMeters: CollisionLabConstants.scaleBarLengthMeters,
                orientation: Axis.vertical,
                viewLength: mvt.modelToViewDeltaX(
                  CollisionLabConstants.scaleBarLengthMeters,
                ),
              ),
            ),
          ),
        if (data.kineticEnergyVisible)
          Positioned(
            left: data.playAreaRect.left + 6,
            top: data.playAreaRect.bottom - 22,
            child: IgnorePointer(
              child: Text(
                'KE = ${data.kineticEnergy.toStringAsFixed(2)} J',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        Positioned(
          left: data.playAreaRect.left,
          top: data.playAreaRect.bottom + 8,
          child: IgnorePointer(
            child: Text(
              't = ${data.elapsedTime.toStringAsFixed(2)} s',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (data.showReturnBalls)
          Positioned(
            left: data.playAreaRect.center.dx - 60,
            top: data.playAreaRect.center.dy - 18,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CollisionLabColors.returnBallsButton,
                foregroundColor: Colors.black87,
              ),
              onPressed: controller.returnBalls,
              child: const Text(CollisionLabStrings.returnBalls),
            ),
          ),
      ],
    );
  }

  void _onPanStart(Offset local, ClMvt mvt, ClRenderData data) {
    final controller = widget.controller;

    // Tip hit in view space (paused + velocity visible).
    if (controller.velocityTipsInteractive) {
      final tipR = CollisionLabConstants.velocityTipCircleRadius;
      int? bestTip;
      var bestTipDist = tipR;
      for (var i = 0; i < data.velocityVectors.length; i++) {
        final tip = data.velocityVectors[i].tip;
        final d = (tip - local).distance;
        if (d <= tipR && d < bestTipDist) {
          bestTipDist = d;
          bestTip = i;
        }
      }
      if (bestTip != null &&
          bestTip < controller.model.ballSystem.balls.length) {
        _dragKind = _DragKind.velocityTip;
        _dragIndex = bestTip;
        controller.beginVelocityTipDrag(bestTip);
        _applyVelocityTip(local, mvt, bestTip);
        return;
      }
    }

    // Ball hit-test in VIEW space so grid lines / MVT cannot block start.
    // Matches BallNode circle pick — not grid painter.
    int? best;
    var bestDist = double.infinity;
    for (var i = 0; i < data.balls.length; i++) {
      final b = data.balls[i];
      final d = (b.center - local).distance;
      // Slightly larger than painted radius for easier grab (PhET circle pick).
      if (d <= b.radius * 1.35 && d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    _dragIndex = best;
    if (best != null) {
      _dragKind = _DragKind.ball;
      // Pass attempted position in model units; snap happens in Ball.dragToPosition.
      controller.dragBall(best, mvt.viewToModel(local));
    } else {
      _dragKind = _DragKind.none;
    }
  }

  void _onPanUpdate(Offset local, ClMvt mvt) {
    final index = _dragIndex;
    if (index == null) return;
    if (_dragKind == _DragKind.velocityTip) {
      _applyVelocityTip(local, mvt, index);
    } else if (_dragKind == _DragKind.ball) {
      widget.controller.dragBall(index, mvt.viewToModel(local));
    }
  }

  void _applyVelocityTip(Offset local, ClMvt mvt, int index) {
    final balls = widget.controller.model.ballSystem.balls;
    if (index < 0 || index >= balls.length) return;
    final ballCenterView = mvt.modelToView(balls[index].position);
    final velocity = mvt.viewToModelDelta(local - ballCenterView);
    widget.controller.dragVelocityTip(index, velocity);
  }

  void _onPanEnd() {
    if (_dragKind == _DragKind.velocityTip) {
      widget.controller.endVelocityTipDrag();
    } else if (_dragKind == _DragKind.ball) {
      widget.controller.endDrag();
    }
    _dragIndex = null;
    _dragKind = _DragKind.none;
  }
}
