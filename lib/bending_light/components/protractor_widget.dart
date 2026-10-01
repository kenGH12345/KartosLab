import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../interaction/protractor_rotation.dart';
import '../model/bl_vec2.dart';
import '../model/light_ray.dart';
import '../screens/stage_scale.dart';
import '../transform/bl_mvt.dart';

/// View-local protractor pose (PhET Intro `showProtractorProperty` is view state).
class ProtractorTool {
  bool enabled = false;
  BlVec2 center = BlVec2.zero;

  /// Radians. Ticks are painted in local space and the node rotates by this.
  double angle = 0;

  void reset() {
    enabled = false;
    center = BlVec2.zero;
    angle = 0;
  }
}

/// Angle of a ray from the upward normal, degrees, from model geometry.
double? rayAngleFromNormalDeg(LightRay ray) {
  // Model +y is up. Ray angle is atan2(dy, dx). Normal is +π/2.
  final fromNormal = ray.getAngle() - math.pi / 2;
  if (!fromNormal.isFinite) return null;
  return fromNormal * 180 / math.pi;
}

/// Angle from the upward normal for the ray whose tail is closest to [center].
double? protractorReadingNear(Iterable<LightRay> rays, BlVec2 center) {
  LightRay? best;
  var bestD = double.infinity;
  for (final ray in rays) {
    final d = ray.tail.distance(center);
    if (d < bestD) {
      bestD = d;
      best = ray;
    }
  }
  if (best == null) return null;
  return rayAngleFromNormalDeg(best)?.abs();
}

class ProtractorWidget extends StatefulWidget {
  const ProtractorWidget({
    super.key,
    required this.mvt,
    required this.tool,
    required this.onDragDelta,
    this.onDragEnd,
    required this.onAngle,
    this.scale = 0.8,
  });

  final BlMvt mvt;
  final ProtractorTool tool;
  final void Function(Offset viewDelta) onDragDelta;
  final VoidCallback? onDragEnd;
  final void Function(double delta) onAngle;

  /// Intro / More Tools use 0.8. Prisms uses 0.46 (`PrismsScreenView`).
  final double scale;

  @override
  State<ProtractorWidget> createState() => _ProtractorWidgetState();
}

class _ProtractorWidgetState extends State<ProtractorWidget> {
  Offset? _start;
  bool _ring = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.mvt.worldToScreen(widget.tool.center);
    const imageSide = 302.0;
    final side = imageSide * widget.scale * StageScale.of(context);
    final r = side / 2;
    return Positioned(
      left: p.dx - r,
      top: p.dy - r,
      width: r * 2,
      height: r * 2,
      child: GestureDetector(
        onPanStart: (d) {
          _start = d.localPosition;
          _ring = protractorOuterRing(
            Offset(r, r),
            d.localPosition,
            r,
          );
        },
        onPanUpdate: (d) {
          final start = _start;
          if (start == null) return;
          if (_ring) {
            widget.onAngle(protractorAngleDelta(
              center: Offset(r, r),
              start: start,
              end: d.localPosition,
            ));
            _start = d.localPosition;
          } else {
            widget.onDragDelta(d.delta);
          }
        },
        onPanEnd: (_) {
          if (!_ring) widget.onDragEnd?.call();
        },
        child: Transform.rotate(
          angle: widget.tool.angle,
          child: Image.asset(
            'assets/simulations/bending_light/protractor.png',
            width: side,
            height: side,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

