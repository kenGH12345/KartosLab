import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/concentration_constants.dart';
import '../model/concentration_meter.dart';
import '../model/concentration_model.dart';
import '../model/probe_region.dart';
import '../audio/concentration_audio.dart';
import 'concentration_layout.dart';

/// Meter body + wire + probe — `ConcentrationMeterNode.ts`.
class ConcentrationMeterNode extends StatelessWidget {
  const ConcentrationMeterNode({
    super.key,
    required this.model,
    this.audio,
  });

  final ConcentrationModel model;
  final ConcentrationAudio? audio;

  static const double bodyMinW = 170;
  static const double bodyMinH = 100;

  @override
  Widget build(BuildContext context) {
    final meter = model.meter;
    final bodyPos = meter.bodyPosition;
    final probePos = meter.probePosition;

    return Positioned.fill(
      child: Stack(
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: ConcentrationLayout.layoutBounds,
              painter: _WirePainter(bodyPos: bodyPos, probePos: probePos),
            ),
          ),
          Positioned(
            left: bodyPos.dx,
            top: bodyPos.dy,
            child: _MeterBody(meter: meter),
          ),
          ConcentrationProbeNode(model: model, audio: audio),
        ],
      ),
    );
  }
}

class _MeterBody extends StatelessWidget {
  const _MeterBody({required this.meter});

  final ConcentrationMeterModel meter;

  @override
  Widget build(BuildContext context) {
    final valueText = _formatValue(meter);
    return Container(
      width: ConcentrationMeterNode.bodyMinW,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(ConcentrationLayout.meterBodyColor, Colors.white, 0.25)!,
            ConcentrationLayout.meterBodyColor,
            Color.lerp(ConcentrationLayout.meterBodyColor, Colors.black, 0.2)!,
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Concentration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 140,
            height: 35,
            alignment: meter.value == null
                ? Alignment.center
                : Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Text(
              valueText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatValue(ConcentrationMeterModel meter) {
    final v = meter.value;
    if (v == null) return '\u2014'; // em dash
    if (meter.units == ConcentrationMeterUnits.molesPerLiter) {
      return '${v.toStringAsFixed(ConcentrationConstants.decimalPlacesConcentrationMolesPerLiter)} mol/L';
    }
    return '${v.toStringAsFixed(ConcentrationConstants.decimalPlacesConcentrationPercent)}%';
  }
}

class _WirePainter extends CustomPainter {
  _WirePainter({required this.bodyPos, required this.probePos});

  final Offset bodyPos;
  final Offset probePos;

  @override
  void paint(Canvas canvas, Size size) {
    // Body top-left; connection at bottom-center of body (~100 tall, 170 wide)
    final bodyConnection = Offset(
      bodyPos.dx + ConcentrationMeterNode.bodyMinW / 2,
      bodyPos.dy + ConcentrationMeterNode.bodyMinH - 10,
    );
    // Probe tip at probePos; connection at right-center of probe head
    const probeRadius = 34.0;
    final probeConnection = Offset(probePos.dx + probeRadius, probePos.dy);

    final c1 = Offset(
      bodyConnection.dx,
      bodyConnection.dy +
          ui.lerpDouble(0, 200, ((bodyPos.dx - probePos.dx).abs() / 800).clamp(0, 1))!,
    );
    final c2 = Offset(probeConnection.dx + 50, probeConnection.dy);

    final path = Path()
      ..moveTo(bodyConnection.dx, bodyConnection.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, probeConnection.dx, probeConnection.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) =>
      oldDelegate.bodyPos != bodyPos || oldDelegate.probePos != probePos;
}

/// Draggable probe — scenery-phet `ProbeNode` + `SoundDragListener`.
class ConcentrationProbeNode extends StatelessWidget {
  const ConcentrationProbeNode({
    super.key,
    required this.model,
    this.audio,
  });

  final ConcentrationModel model;
  final ConcentrationAudio? audio;

  static const double radius = 34;
  static const double innerRadius = 26;
  static const double handleWidth = 30;
  static const double handleHeight = 25;

  @override
  Widget build(BuildContext context) {
    final pos = model.meter.probePosition;
    // Rotated -π/2 so handle points left; tip/sensor at model position
    const size = 100.0;
    return Positioned(
      left: pos.dx - size / 2,
      top: pos.dy - size / 2,
      width: size,
      height: size,
      child: GestureDetector(
        onPanStart: (_) => audio?.onDragStart(),
        onPanUpdate: (d) {
          model.setProbePosition(model.meter.probePosition + d.delta);
        },
        onPanEnd: (_) => audio?.onDragEnd(),
        onPanCancel: () => audio?.onDragEnd(interrupted: true),
        child: Transform.rotate(
          angle: -math.pi / 2,
          child: CustomPaint(
            size: const Size(size, size),
            painter: const _ProbePainter(),
          ),
        ),
      ),
    );
  }
}

class _ProbePainter extends CustomPainter {
  const _ProbePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const r = ConcentrationProbeNode.radius;
    const ir = ConcentrationProbeNode.innerRadius;
    const hw = ConcentrationProbeNode.handleWidth;
    const hh = ConcentrationProbeNode.handleHeight;
    final color = ConcentrationLayout.meterBodyColor;

    final body = Path()
      ..moveTo(-hw / 2 + 4, r + hh - 4)
      ..arcToPoint(Offset(-hw / 2, r + hh - 12), radius: const Radius.circular(8))
      ..lineTo(-hw / 2, r + 6)
      ..quadraticBezierTo(-hw / 2, r, -r * 0.6, r * 0.75)
      ..arcToPoint(
        Offset(r * 0.6, r * 0.75),
        radius: const Radius.circular(r),
        largeArc: true,
      )
      ..quadraticBezierTo(hw / 2, r, hw / 2, r + 6)
      ..lineTo(hw / 2, r + hh - 12)
      ..arcToPoint(Offset(hw / 2 - 4, r + hh - 4), radius: const Radius.circular(8))
      ..close();

    canvas.save();
    canvas.translate(c.dx, c.dy);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(-r * 0.2, -r * 0.2),
        r,
        [
          Color.lerp(color, Colors.white, 0.35)!,
          color,
          Color.lerp(color, Colors.black, 0.25)!,
        ],
        const [0.0, 0.45, 1.0],
      );
    canvas.drawPath(body, paint);
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner ring + crosshairs
    canvas.drawCircle(
      Offset.zero,
      ir,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    const gap = 6.0;
    final cross = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(-ir, 0), const Offset(-gap, 0), cross);
    canvas.drawLine(const Offset(gap, 0), const Offset(ir, 0), cross);
    canvas.drawLine(const Offset(0, -ir), const Offset(0, -gap), cross);
    canvas.drawLine(const Offset(0, gap), const Offset(0, ir), cross);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Keyboard shortcut `J` for probe jump — Phase 2 scaffold.
class ProbeJumpShortcuts extends StatelessWidget {
  const ProbeJumpShortcuts({
    super.key,
    required this.model,
    required this.child,
  });

  final ConcentrationModel model;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyJ): () {
          model.jumpProbeToNext();
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
