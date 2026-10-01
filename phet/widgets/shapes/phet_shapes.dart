/// PhET Shapes — base geometric shapes for drawing on canvas.
///
/// These are model classes that describe shape geometry; they are painted
/// via [PhetShapePainter] or used directly in [CustomPainter] subclasses.
library;

import 'package:flutter/material.dart';

/// Base class for PhET shapes.
abstract class PhetShape {
  Offset position;
  double rotation;
  double scale;
  double opacity;
  Color? fill;
  Color? stroke;
  double strokeWidth;

  PhetShape({
    this.position = Offset.zero,
    this.rotation = 0,
    this.scale = 1,
    this.opacity = 1,
    this.fill,
    this.stroke,
    this.strokeWidth = 1,
  });

  /// Draw this shape on [canvas].
  void draw(Canvas canvas);
}

class PhetCircle extends PhetShape {
  double radius;

  PhetCircle({
    required this.radius,
    super.position,
    super.rotation,
    super.scale,
    super.opacity,
    super.fill,
    super.stroke,
    super.strokeWidth,
  });

  @override
  void draw(Canvas canvas) {
    final r = radius * scale;
    if (fill != null) canvas.drawCircle(position, r, Paint()..color = fill!.withValues(alpha: opacity));
    if (stroke != null) {
      canvas.drawCircle(position, r, Paint()
        ..color = stroke!.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth);
    }
  }
}

class PhetRectangle extends PhetShape {
  double width;
  double height;

  PhetRectangle({
    required this.width,
    required this.height,
    super.position,
    super.rotation,
    super.scale,
    super.opacity,
    super.fill,
    super.stroke,
    super.strokeWidth,
  });

  @override
  void draw(Canvas canvas) {
    final w = width * scale;
    final h = height * scale;
    final rect = Rect.fromCenter(center: position, width: w, height: h);
    if (rotation != 0) canvas.save();
    if (rotation != 0) {
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);
      canvas.translate(-position.dx, -position.dy);
    }
    if (fill != null) canvas.drawRect(rect, Paint()..color = fill!.withValues(alpha: opacity));
    if (stroke != null) {
      canvas.drawRect(rect, Paint()
        ..color = stroke!.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth);
    }
    if (rotation != 0) canvas.restore();
  }
}

class PhetRoundedRectangle extends PhetRectangle {
  final double cornerRadius;

  PhetRoundedRectangle({
    required super.width,
    required super.height,
    this.cornerRadius = 8,
    super.position,
    super.rotation,
    super.scale,
    super.opacity,
    super.fill,
    super.stroke,
    super.strokeWidth,
  });

  @override
  void draw(Canvas canvas) {
    final w = width * scale;
    final h = height * scale;
    final rect = Rect.fromCenter(center: position, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!.withValues(alpha: opacity));
    if (stroke != null) {
      canvas.drawRRect(rrect, Paint()
        ..color = stroke!.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth);
    }
  }
}

class PhetLine extends PhetShape {
  Offset start;
  Offset end;

  PhetLine({
    required this.start,
    required this.end,
    super.stroke,
    super.strokeWidth = 2,
    super.opacity,
  }) : super(fill: null);

  @override
  void draw(Canvas canvas) {
    canvas.drawLine(start, end, Paint()
      ..color = stroke!.withValues(alpha: opacity)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);
  }
}

class PhetEllipse extends PhetShape {
  double radiusX;
  double radiusY;

  PhetEllipse({
    required this.radiusX,
    required this.radiusY,
    super.position,
    super.rotation,
    super.scale,
    super.opacity,
    super.fill,
    super.stroke,
    super.strokeWidth,
  });

  @override
  void draw(Canvas canvas) {
    final rx = radiusX * scale;
    final ry = radiusY * scale;
    final rect = Rect.fromCenter(center: position, width: rx * 2, height: ry * 2);
    if (fill != null) canvas.drawOval(rect, Paint()..color = fill!.withValues(alpha: opacity));
    if (stroke != null) {
      canvas.drawOval(rect, Paint()
        ..color = stroke!.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth);
    }
  }
}

class PhetArc extends PhetShape {
  double radius;
  double startAngle;
  double sweepAngle;

  PhetArc({
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
    super.position,
    super.rotation,
    super.scale,
    super.opacity,
    super.stroke,
    super.strokeWidth = 2,
  }) : super(fill: null);

  @override
  void draw(Canvas canvas) {
    final r = radius * scale;
    final rect = Rect.fromCircle(center: position, radius: r);
    canvas.drawArc(
      rect,
      startAngle + rotation,
      sweepAngle,
      false,
      Paint()
        ..color = stroke!.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }
}

class PhetPolygon extends PhetShape {
  List<Offset> points;

  PhetPolygon({
    required this.points,
    super.position,
    super.rotation,
    super.scale,
    super.opacity,
    super.fill,
    super.stroke,
    super.strokeWidth,
  });

  @override
  void draw(Canvas canvas) {
    if (points.length < 3) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    if (fill != null) canvas.drawPath(path, Paint()..color = fill!.withValues(alpha: opacity));
    if (stroke != null) {
      canvas.drawPath(path, Paint()
        ..color = stroke!.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth);
    }
  }
}

class PhetTriangle extends PhetPolygon {
  PhetTriangle({
    required Offset p1,
    required Offset p2,
    required Offset p3,
    super.fill,
    super.stroke,
    super.strokeWidth,
    super.opacity,
  }) : super(points: [p1, p2, p3]);
}

/// A painter that draws a list of [PhetShape]s.
class PhetShapePainter extends CustomPainter {
  final List<PhetShape> shapes;
  const PhetShapePainter(this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in shapes) {
      s.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(PhetShapePainter old) => true;
}
