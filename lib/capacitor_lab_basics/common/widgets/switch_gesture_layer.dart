import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../model/circuit_state.dart';
import '../model/clb_model.dart';
import '../model/parallel_circuit.dart';
import '../render/circuit_render_data.dart';
import '../transform/circuit_geometry.dart';
import '../transform/yaw_pitch_mvt.dart';

/// Hit-test for switch blade drag + connection-point taps —
/// `SwitchNode.js` / `ConnectionNode.js` / `CircuitSwitchDragHandler.js`.
///
/// One detector per blade so tap (ConnectionNode) and pan (drag handler)
/// share the arena: a press on a dashed contact can still drag if it moves.
class SwitchGestureLayer extends StatefulWidget {
  const SwitchGestureLayer({
    super.key,
    required this.model,
    required this.data,
    this.mvt,
  });

  final ClbModel model;
  final CircuitRenderData data;
  final YawPitchMvt? mvt;

  /// Blade AABB pad (view px).
  static const double hitRadius = 28;

  /// Touch target around each dashed connection circle (`ConnectionNode`).
  static const double contactHitRadius = 26;

  /// Yellow flash duration after tap (hover highlight analogue for touch).
  static const Duration contactFlashDuration = Duration(milliseconds: 220);

  @override
  State<SwitchGestureLayer> createState() => _SwitchGestureLayerState();
}

class _SwitchGestureLayerState extends State<SwitchGestureLayer> {
  CircuitState? _beforeDrag;
  Offset? _flashContact;
  Timer? _flashTimer;

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  void _flash(Offset center) {
    _flashTimer?.cancel();
    setState(() => _flashContact = center);
    _flashTimer = Timer(SwitchGestureLayer.contactFlashDuration, () {
      if (mounted) setState(() => _flashContact = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = ClbConstants.connectionPointRadius;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _switchHit(blade: widget.data.topSwitch, isTop: true),
        _switchHit(blade: widget.data.bottomSwitch, isTop: false),
        if (_flashContact != null)
          Positioned(
            left: _flashContact!.dx - r,
            top: _flashContact!.dy - r,
            width: r * 2,
            height: r * 2,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _YellowContactFlashPainter(radius: r),
              ),
            ),
          ),
      ],
    );
  }

  Widget _switchHit({
    required SwitchBladeView blade,
    required bool isTop,
  }) {
    final circuit = widget.model.circuit;
    final rect = switchPointerBounds(blade);
    return Positioned(
      key: ValueKey(isTop ? 'clb_switch_top' : 'clb_switch_bottom'),
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) {
          final canvas = Offset(
            rect.left + d.localPosition.dx,
            rect.top + d.localPosition.dy,
          );
          final hit = connectionAt(
            blade: blade,
            canvas: canvas,
            allowed: circuit.allowedConnections,
          );
          if (hit != null) _flash(hit.center);
        },
        onTapUp: (d) {
          final canvas = Offset(
            rect.left + d.localPosition.dx,
            rect.top + d.localPosition.dy,
          );
          final hit = connectionAt(
            blade: blade,
            canvas: canvas,
            allowed: circuit.allowedConnections,
          );
          if (hit == null) return;
          trySelectSwitchConnection(
            circuit: circuit,
            shared: widget.model.shared,
            target: hit.state,
          );
        },
        onPanStart: (_) {
          _beforeDrag =
              circuit.circuitConnection == CircuitState.switchInTransit
                  ? CircuitState.batteryConnected
                  : circuit.circuitConnection;
          circuit.setSwitchAngleInTransit(
            isTop: isTop,
            angle: isTop ? circuit.topSwitchAngle : circuit.bottomSwitchAngle,
          );
        },
        onPanUpdate: (d) {
          _updateDragAngle(
            circuit: circuit,
            isTop: isTop,
            canvas: Offset(
              rect.left + d.localPosition.dx,
              rect.top + d.localPosition.dy,
            ),
          );
        },
        onPanEnd: (_) => _snap(circuit, isTop),
        onPanCancel: () => _snap(circuit, isTop),
      ),
    );
  }

  void _updateDragAngle({
    required ParallelCircuit circuit,
    required bool isTop,
    required Offset canvas,
  }) {
    final transform = widget.mvt ?? YawPitchMvt();
    final modelPt = transform.viewToModelXY(canvas.dx, canvas.dy);
    final hinge = CircuitGeometry.switchHingePoint(
      isTop: isTop,
      config: circuit.config,
    );
    var angle = math.atan2(modelPt.y - hinge.y, modelPt.x - hinge.x);
    final leftLim = CircuitGeometry.leftLimitAngle(isTop: isTop);
    final rightLim = CircuitGeometry.rightLimitAngle(
      isTop: isTop,
      hasLightBulb: circuit.config.hasLightBulb,
    );
    if (angle * leftLim < 0) {
      angle = -angle;
    }
    final minA = math.min(leftLim, rightLim);
    final maxA = math.max(leftLim, rightLim);
    final mid = (minA + maxA) / 2;
    angle = _moduloBetweenDown(angle, mid - math.pi, mid + math.pi);
    angle = angle.clamp(minA, maxA);
    circuit.setSwitchAngleInTransit(isTop: isTop, angle: angle);
  }

  void _snap(ParallelCircuit circuit, bool isTop) {
    final angle =
        isTop ? circuit.topSwitchAngle : circuit.bottomSwitchAngle;
    var next = CircuitGeometry.snapConnectionFromAbsAngle(
      angle.abs(),
      threeState: circuit.config.hasLightBulb,
    );
    if (!circuit.allowedConnections.contains(next)) {
      next = CircuitState.openCircuit;
    }
    circuit.setCircuitConnection(next);
    final before = _beforeDrag;
    if (before != null &&
        next != before &&
        next != CircuitState.switchInTransit) {
      widget.model.shared.markSwitchUsed();
    }
    _beforeDrag = null;
  }

  static double _moduloBetweenDown(double value, double min, double max) {
    final period = max - min;
    if (period == 0) return min;
    var v = value;
    while (v < min) {
      v += period;
    }
    while (v >= max) {
      v -= period;
    }
    return v;
  }
}

/// Bounding box of blade + ConnectionNode circles (view pixels).
Rect switchPointerBounds(SwitchBladeView blade) {
  final pad = math.max(
    SwitchGestureLayer.hitRadius,
    SwitchGestureLayer.contactHitRadius,
  );
  final pts = <Offset>[
    blade.hinge,
    blade.tip,
    blade.batteryContact,
    blade.openContact,
    if (blade.lightBulbContact != null) blade.lightBulbContact!,
  ];
  var minX = pts.first.dx;
  var minY = pts.first.dy;
  var maxX = pts.first.dx;
  var maxY = pts.first.dy;
  for (final p in pts) {
    minX = math.min(minX, p.dx);
    minY = math.min(minY, p.dy);
    maxX = math.max(maxX, p.dx);
    maxY = math.max(maxY, p.dy);
  }
  return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
}

/// Nearest allowed ConnectionNode under [canvas], or null.
({Offset center, CircuitState state})? connectionAt({
  required SwitchBladeView blade,
  required Offset canvas,
  required Iterable<CircuitState> allowed,
  double radius = SwitchGestureLayer.contactHitRadius,
}) {
  final targets = <({Offset center, CircuitState state})>[
    (center: blade.batteryContact, state: CircuitState.batteryConnected),
    (center: blade.openContact, state: CircuitState.openCircuit),
    if (blade.lightBulbContact != null)
      (
        center: blade.lightBulbContact!,
        state: CircuitState.lightBulbConnected,
      ),
  ];
  ({Offset center, CircuitState state})? best;
  var bestD = radius;
  for (final t in targets) {
    if (!allowed.contains(t.state)) continue;
    final d = (t.center - canvas).distance;
    if (d <= bestD) {
      bestD = d;
      best = t;
    }
  }
  return best;
}

/// `ConnectionNode.js` press — set connection when tapping a different port.
bool trySelectSwitchConnection({
  required ParallelCircuit circuit,
  required ClbSharedState shared,
  required CircuitState target,
}) {
  if (target == CircuitState.switchInTransit) return false;
  if (!circuit.allowedConnections.contains(target)) return false;
  if (circuit.circuitConnection == target) return false;
  circuit.setCircuitConnection(target);
  shared.markSwitchUsed();
  return true;
}

/// Yellow fill + black dashed stroke — `CONNECTION_POINT_HIGHLIGHTED`.
class _YellowContactFlashPainter extends CustomPainter {
  _YellowContactFlashPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, radius, Paint()..color = ClbColors.connectionHighlighted);
    const dash = 3.0;
    const gap = 3.0;
    final path = Path();
    var angle = 0.0;
    final circ = 2 * math.pi * radius;
    while (angle * radius < circ) {
      final a0 = angle;
      final sweep = dash / radius;
      path.addArc(Rect.fromCircle(center: c, radius: radius), a0, sweep);
      angle = a0 + sweep + gap / radius;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _YellowContactFlashPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
