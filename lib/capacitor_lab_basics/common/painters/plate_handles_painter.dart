import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../clb_constants.dart';
import '../../clb_strings.dart';
import '../render/circuit_render_data.dart';

/// Plate separation (vertical) + area (rotated arrow) drag handles —
/// `DragHandleArrowNode` + `DragHandleLineNode` + `DragHandleValueNode`.
///
/// Labels stay **horizontal** (PhET: only line/arrow rotate on Plate Area).
class PlateHandlesPainter extends CustomPainter {
  PlateHandlesPainter({required this.data});

  final CircuitRenderData data;

  static const Color _arrowFill = Color.fromRGBO(61, 179, 79, 1);
  static const double _sepLineLength = 60;
  static const double _areaLineLength = 22;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSeparationHandle(canvas);
    _paintAreaHandle(canvas);
  }

  void _paintSeparationHandle(Canvas canvas) {
    final origin = data.plateSeparationHandleAnchor;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);

    _drawDottedLine(
      canvas,
      Offset.zero,
      const Offset(0, -_sepLineLength),
    );

    final arrowStart = Offset(0, -_sepLineLength - 2);
    final arrowEnd =
        Offset(0, -_sepLineLength - 2 - ClbConstants.dragHandleArrowLength);
    _drawDoubleArrow(canvas, arrowStart, arrowEnd);

    // DragHandleValueNode — right of arrow (PhET: arrow.bounds.maxX + 5).
    // Account for double-head half-width (headW/2 = length/4), not shaft centerline.
    final mm = data.plateSeparation * 1000;
    final arrowHalfW = ClbConstants.dragHandleArrowLength / 4;
    const labelGapX = 10.0;
    final labelTop = Offset(
      arrowHalfW + labelGapX,
      math.min(arrowStart.dy, arrowEnd.dy) - 4,
    );
    _drawValueLabel(
      canvas,
      labelTop,
      ClbStrings.separation,
      ClbStrings.millimetersPattern(mm),
    );

    canvas.restore();
  }

  void _paintAreaHandle(Canvas canvas) {
    final origin = data.plateAreaHandleAnchor;
    final rot = data.plateAreaHandleRotationRad;

    // PhET: only line + arrow rotate; DragHandleValueNode stays axis-aligned.
    Offset rotPt(Offset p) {
      final c = math.cos(rot);
      final s = math.sin(rot);
      return Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c);
    }

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rot);

    _drawDottedLine(
      canvas,
      Offset.zero,
      const Offset(0, _areaLineLength),
    );

    final arrowStart = Offset(2, _areaLineLength + 2);
    final arrowEnd = Offset(
      2,
      _areaLineLength + 2 + ClbConstants.dragHandleArrowLength,
    );
    _drawDoubleArrow(canvas, arrowStart, arrowEnd);
    canvas.restore();

    // Line endpoints in parent (unrotated) space → AABB like scenery Node.bounds
    final lineA = origin;
    final lineB = origin + rotPt(const Offset(0, _areaLineLength));
    final lineMaxX = math.max(lineA.dx, lineB.dx);
    final lineMinY = math.min(lineA.dy, lineB.dy);

    // Arrow AABB in parent space (includes head half-width) so text clears the head.
    final arrowLen = ClbConstants.dragHandleArrowLength;
    final arrowHalfW = arrowLen / 4;
    final arrowA = origin + rotPt(Offset(2, _areaLineLength + 2));
    final arrowB =
        origin + rotPt(Offset(2, _areaLineLength + 2 + arrowLen));
    final geomMaxX = math.max(
          lineMaxX,
          math.max(arrowA.dx, arrowB.dx),
        ) +
        arrowHalfW;
    final geomMinY = math.min(
          lineMinY,
          math.min(arrowA.dy, arrowB.dy),
        ) -
        arrowHalfW;

    final areaMm2 = data.plateWidth * data.plateDepth * 1e6;
    final title = ClbStrings.plateArea;
    final value = ClbStrings.millimetersSquaredPattern(areaMm2.round());
    final titleTp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final valueTp = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelH = titleTp.height + 4 + valueTp.height;
    // Keep PhET-ish placement (above / right of handle) with clear gap from arrow.
    const labelGapX = 12.0;
    const labelGapY = 8.0;
    final labelTop = Offset(
      geomMaxX + labelGapX,
      geomMinY - labelH - labelGapY,
    );
    titleTp.paint(canvas, labelTop);
    valueTp.paint(canvas, labelTop + Offset(0, titleTp.height + 4));
  }

  void _drawValueLabel(
    Canvas canvas,
    Offset topLeft,
    String title,
    String value,
  ) {
    final titleTp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final valueTp = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titleTp.paint(canvas, topLeft);
    valueTp.paint(canvas, topLeft + Offset(0, titleTp.height + 4));
  }

  void _drawDottedLine(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    const dash = 4.0;
    const gap = 3.0;
    var d = 0.0;
    var draw = true;
    while (d < len) {
      final n = math.min(draw ? dash : gap, len - d);
      final x0 = a.dx + dx * d / len;
      final y0 = a.dy + dy * d / len;
      final x1 = a.dx + dx * (d + n) / len;
      final y1 = a.dy + dy * (d + n) / len;
      if (draw) {
        path.moveTo(x0, y0);
        path.lineTo(x1, y1);
      }
      d += n;
      draw = !draw;
    }
    canvas.drawPath(path, paint);
  }

  /// Double-headed arrow approximating scenery-phet `ArrowNode` (doubleHead).
  void _drawDoubleArrow(Canvas canvas, Offset start, Offset end) {
    final length = (end - start).distance;
    if (length < 1) return;
    final paint = Paint()
      ..color = _arrowFill
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dir = (end - start) / length;
    final perp = Offset(-dir.dy, dir.dx);
    final headH = length * 0.42;
    final headW = length / 2;
    final tailW = length / 5;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      // start head left
      ..lineTo(
        start.dx + dir.dx * headH + perp.dx * headW / 2,
        start.dy + dir.dy * headH + perp.dy * headW / 2,
      )
      ..lineTo(
        start.dx + dir.dx * headH + perp.dx * tailW / 2,
        start.dy + dir.dy * headH + perp.dy * tailW / 2,
      )
      // shaft to end head
      ..lineTo(
        end.dx - dir.dx * headH + perp.dx * tailW / 2,
        end.dy - dir.dy * headH + perp.dy * tailW / 2,
      )
      ..lineTo(
        end.dx - dir.dx * headH + perp.dx * headW / 2,
        end.dy - dir.dy * headH + perp.dy * headW / 2,
      )
      ..lineTo(end.dx, end.dy)
      ..lineTo(
        end.dx - dir.dx * headH - perp.dx * headW / 2,
        end.dy - dir.dy * headH - perp.dy * headW / 2,
      )
      ..lineTo(
        end.dx - dir.dx * headH - perp.dx * tailW / 2,
        end.dy - dir.dy * headH - perp.dy * tailW / 2,
      )
      ..lineTo(
        start.dx + dir.dx * headH - perp.dx * tailW / 2,
        start.dy + dir.dy * headH - perp.dy * tailW / 2,
      )
      ..lineTo(
        start.dx + dir.dx * headH - perp.dx * headW / 2,
        start.dy + dir.dy * headH - perp.dy * headW / 2,
      )
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant PlateHandlesPainter oldDelegate) =>
      oldDelegate.data.plateSeparationHandleAnchor !=
          data.plateSeparationHandleAnchor ||
      oldDelegate.data.plateAreaHandleAnchor != data.plateAreaHandleAnchor ||
      oldDelegate.data.plateSeparation != data.plateSeparation ||
      oldDelegate.data.plateWidth != data.plateWidth;
}
