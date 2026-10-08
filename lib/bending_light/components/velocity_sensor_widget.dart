import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/bl_vec2.dart';
import '../transform/bl_mvt.dart';
import 'velocity_arrow.dart';
import '../phet_font.dart';
import '../screens/stage_scale.dart';
import 'toolbox_icons.dart';
import 'package:kratos/bending_light/bl_strings.dart';

/// `VelocitySensorNode`: triangle hot-spot, readout, blue arrow from model velocity.
class VelocitySensorView extends StatelessWidget {
  const VelocitySensorView({
    super.key,
    required this.mvt,
    required this.position,
    required this.velocity,
    required this.onDelta,
    this.onEnd,
  });

  final BlMvt mvt;
  final BlVec2 position;
  final BlVec2 velocity;
  final void Function(Offset delta) onDelta;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final p = mvt.worldToScreen(position);
    const bodyScale = VelocitySensorGraphic.bodyScale;
    const nodeScale = VelocitySensorGraphic.placedNodeScale;
    final arrow = velocityArrowViewDelta(mvt, velocity);
    final visualArrow = arrow * (bodyScale * nodeScale);
    final width = 62 * bodyScale * nodeScale * view + visualArrow.dx.abs() + 16 * view;
    final height =
        math.max(37 * bodyScale * nodeScale * view, visualArrow.dy.abs()) + 8 * view;
    return Positioned(
      left: p.dx,
      top: p.dy - height / 2,
      width: width,
      height: height,
      child: GestureDetector(
        onPanUpdate: (d) => onDelta(d.delta),
        onPanEnd: (_) => onEnd?.call(),
        child: CustomPaint(
          painter: _VelocityPainter(
            velocity: velocity,
            arrow: arrow / view,
            viewScale: view,
            bodyScale: bodyScale,
            nodeScale: nodeScale,
          ),
        ),
      ),
    );
  }
}

class _VelocityPainter extends CustomPainter {
  _VelocityPainter({
    required this.velocity,
    required this.arrow,
    required this.viewScale,
    required this.bodyScale,
    required this.nodeScale,
  });

  final BlVec2 velocity;
  final Offset arrow;
  final double viewScale;
  final double bodyScale;
  final double nodeScale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, size.height / 2);
    canvas.scale(viewScale);
    canvas.scale(nodeScale);
    canvas.scale(bodyScale);
    final triangle = Path()
      ..moveTo(0, 0)
      ..lineTo(8, -7.5)
      ..lineTo(8, 7.5)
      ..close();
    canvas.drawPath(triangle, Paint()..color = const Color(0xFFCF8702));
    canvas.drawPath(
      triangle,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF844702),
    );
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, -18.5, 54, 37),
      const Radius.circular(7.5),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFCF8702));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF844702),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, -15.5, 39, 14.5),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white,
    );
    final label = velocityReadout(velocity);
    final tp = TextPainter(
      text: TextSpan(text: label, style: PhetFont.of(10, color: Colors.black)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 36);
    tp.paint(canvas, Offset(33 - tp.width / 2, -15));
    final title = TextPainter(
      text: TextSpan(text: BlStrings.speed, style: PhetFont.of(10, color: Colors.black)),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset(33 - title.width / 2, 4));
    if (velocity.magnitude > 0 && arrow.distance > 0.5) {
      _arrow(canvas, arrow);
    }
    canvas.restore();
  }

  void _arrow(Canvas canvas, Offset tip) {
    final len = tip.distance;
    final dir = tip / len;
    final n = Offset(-dir.dy, dir.dx);
    const tail = 3.0;
    const headW = 6.0;
    const headH = 6.0;
    final base = tip - dir * math.min(headH, len);
    final path = Path()
      ..moveTo(n.dx * tail, n.dy * tail)
      ..lineTo(base.dx + n.dx * tail, base.dy + n.dy * tail)
      ..lineTo(base.dx + n.dx * headW, base.dy + n.dy * headW)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(base.dx - n.dx * headW, base.dy - n.dy * headW)
      ..lineTo(base.dx - n.dx * tail, base.dy - n.dy * tail)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0x990000FF));
  }

  @override
  bool shouldRepaint(covariant _VelocityPainter oldDelegate) =>
      oldDelegate.velocity.x != velocity.x ||
      oldDelegate.velocity.y != velocity.y ||
      oldDelegate.nodeScale != nodeScale ||
      oldDelegate.viewScale != viewScale;
}
