import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../model/circuit_state.dart';
import '../render/circuit_render_data.dart';

/// Switch tip spheres + ConnectionNode contact circles — `SwitchNode.js`.
class SwitchTipPainter extends CustomPainter {
  SwitchTipPainter({required this.data});

  final CircuitRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBlade(canvas, data.topSwitch);
    _paintBlade(canvas, data.bottomSwitch);
  }

  void _paintBlade(Canvas canvas, SwitchBladeView blade) {
    final r = ClbConstants.connectionPointRadius;

    // ConnectionNode circles at each snap target
    for (final contact in [
      blade.batteryContact,
      blade.openContact,
      if (blade.lightBulbContact != null) blade.lightBulbContact!,
    ]) {
      _paintConnectionContact(canvas, contact, r);
    }

    // Solid pin at tip when connected to a terminal
    final connected =
        data.circuitConnection == CircuitState.batteryConnected ||
            data.circuitConnection == CircuitState.lightBulbConnected;
    if (connected) {
      canvas.drawCircle(blade.tip, r, Paint()..color = ClbColors.pin);
      canvas.drawCircle(
        blade.tip,
        r,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    if (data.switchTipHighlighted) {
      canvas.drawCircle(
        blade.tip,
        r,
        Paint()
          ..color = ClbColors.connectionHighlighted.withValues(alpha: 0.85),
      );
      _drawDashedCircle(
        canvas,
        blade.tip,
        r,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.drawCircle(blade.hinge, r * 0.55, Paint()..color = ClbColors.pin);
    canvas.drawCircle(
      blade.hinge,
      r * 0.55,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintConnectionContact(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r, Paint()..color = ClbColors.disconnectedPoint);
    _drawDashedCircle(
      canvas,
      c,
      r,
      Paint()
        ..color = ClbColors.disconnectedPointStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const dash = 3.0;
    const gap = 3.0;
    final path = Path();
    var angle = 0.0;
    final circ = 2 * math.pi * r;
    while (angle * r < circ) {
      final a0 = angle;
      final sweep = dash / r;
      path.addArc(Rect.fromCircle(center: c, radius: r), a0, sweep);
      angle = a0 + sweep + gap / r;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SwitchTipPainter oldDelegate) =>
      oldDelegate.data.topSwitch.tip != data.topSwitch.tip ||
      oldDelegate.data.bottomSwitch.tip != data.bottomSwitch.tip ||
      oldDelegate.data.topSwitch.batteryContact !=
          data.topSwitch.batteryContact ||
      oldDelegate.data.switchTipHighlighted != data.switchTipHighlighted ||
      oldDelegate.data.circuitConnection != data.circuitConnection;
}
