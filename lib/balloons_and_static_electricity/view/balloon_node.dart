import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../model/balloon_model.dart';
import '../model/balloons_static_electricity_constants.dart';
import '../model/balloons_static_electricity_model.dart';
import '../model/base_vec2.dart';
import 'charge_painter.dart';
import 'package:kratos/balloons_and_static_electricity/base_strings.dart';

/// Balloon image + charges + silhouette hit-test — PhET `BalloonNode`.
class BalloonNode extends StatefulWidget {
  const BalloonNode({
    super.key,
    required this.model,
    required this.balloon,
    required this.assetPath,
    required this.onBroughtToFront,
    this.semanticLabel,
  });

  final BalloonsStaticElectricityModel model;
  final BalloonModel balloon;
  final String assetPath;
  final VoidCallback onBroughtToFront;
  final String? semanticLabel;

  @override
  State<BalloonNode> createState() => BalloonNodeState();
}

class BalloonNodeState extends State<BalloonNode> {
  bool _dragging = false;

  BalloonsStaticElectricityModel get model => widget.model;
  BalloonModel get balloon => widget.balloon;

  @override
  Widget build(BuildContext context) {
    if (!balloon.isVisible) return const SizedBox.shrink();

    final mode = model.showCharges;
    final plusCenters = <BaseVec2>[];
    final minusCenters = <BaseVec2>[];
    final plusVisible = <bool>[];
    final minusVisible = <bool>[];

    for (var i = 0; i < balloon.plusCharges.length; i++) {
      plusCenters.add(balloon.plusCharges[i].position);
      minusCenters.add(balloon.minusCharges[i].position);
      if (mode == ShowCharges.allCharges) {
        plusVisible.add(true);
        minusVisible.add(true);
      } else {
        // noCharges / chargeDifferences: hide neutral pairs
        plusVisible.add(false);
        minusVisible.add(false);
      }
    }

    final collectedStart = balloon.plusCharges.length;
    final numExtra = balloon.charge.abs();
    for (var i = collectedStart; i < balloon.minusCharges.length; i++) {
      minusCenters.add(balloon.minusCharges[i].position);
      if (mode == ShowCharges.noCharges) {
        minusVisible.add(false);
      } else {
        minusVisible.add(i - collectedStart < numExtra);
      }
    }

    return Positioned(
      left: balloon.position.x,
      top: balloon.position.y,
      width: BaseConstants.balloonWidth,
      height: BaseConstants.balloonHeight,
      child: Semantics(
        label: widget.semanticLabel ?? BaseStrings.balloon,
        button: true,
        child: _BalloonHitTarget(
          balloon: balloon,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onPanStart: (details) {
              final local = details.localPosition;
              if (!balloon.hitTestLocal(BaseVec2(local.dx, local.dy))) {
                return;
              }
              _dragging = true;
              widget.onBroughtToFront();
              // Pointer offset preserved: we never re-center on pointer.
              model.dragBalloonTo(balloon, balloon.position);
            },
            onPanUpdate: (details) {
              if (!_dragging && !balloon.userControlled) return;
              _dragging = true;
              model.dragBalloonTo(
                balloon,
                BaseVec2(
                  balloon.position.x + details.delta.dx,
                  balloon.position.y + details.delta.dy,
                ),
              );
            },
            onPanEnd: (_) {
              _dragging = false;
              model.releaseBalloon(balloon);
            },
            onPanCancel: () {
              _dragging = false;
              model.releaseBalloon(balloon);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  widget.assetPath,
                  width: BaseConstants.balloonWidth,
                  height: BaseConstants.balloonHeight,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
                if (mode != ShowCharges.noCharges)
                  CustomPaint(
                    size: const Size(
                      BaseConstants.balloonWidth,
                      BaseConstants.balloonHeight,
                    ),
                    painter: ChargesPainter(
                      plusCenters: plusCenters,
                      minusCenters: minusCenters,
                      plusVisible: plusVisible,
                      minusVisible: minusVisible,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Restricts hit testing to ellipse + knot silhouette.
class _BalloonHitTarget extends SingleChildRenderObjectWidget {
  const _BalloonHitTarget({
    required this.balloon,
    required Widget child,
  }) : super(child: child);

  final BalloonModel balloon;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBalloonHitTarget(balloon);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderBalloonHitTarget renderObject,
  ) {
    renderObject.balloon = balloon;
  }
}

class _RenderBalloonHitTarget extends RenderProxyBox {
  _RenderBalloonHitTarget(this.balloon);

  BalloonModel balloon;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!balloon.hitTestLocal(BaseVec2(position.dx, position.dy))) {
      return false;
    }
    return super.hitTest(result, position: position);
  }
}
