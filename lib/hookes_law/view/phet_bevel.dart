import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Shared PhET control faces. Not a drop shadow.
///
/// Sun buttons and thumbs use a lighter top face, a darker lower edge,
/// and a hairline highlight. Disabled fills are flattened toward gray.
void paintBeveledRRect(
  Canvas canvas,
  Rect rect, {
  required Color face,
  double radius = 2,
  bool enabled = true,
}) {
  final base = enabled ? face : Color.lerp(face, const Color(0xFFE0E0E0), 0.65)!;
  final light = Color.lerp(base, const Color(0xFFFFFFFF), 0.5)!;
  final dark = Color.lerp(base, const Color(0xFF000000), 0.35)!;
  final side = RRect.fromRectAndRadius(rect.shift(const Offset(0, 1.5)), Radius.circular(radius));
  canvas.drawRRect(side, Paint()..color = dark);
  final faceRect = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height - 1.5);
  final faceR = RRect.fromRectAndRadius(faceRect, Radius.circular(radius));
  canvas.drawRRect(
    faceR,
    Paint()
      ..shader = ui.Gradient.linear(
        faceRect.topCenter,
        faceRect.bottomCenter,
        [light, base, dark],
        const [0, 0.42, 1],
      ),
  );
  canvas.drawRRect(
    faceR,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF000000),
  );
  canvas.drawLine(
    faceRect.topLeft + const Offset(2, 2),
    faceRect.topRight + const Offset(-2, 2),
    Paint()
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = 1,
  );
}

void paintBeveledBox(
  Canvas canvas,
  Rect rect, {
  required bool enabled,
  required bool checked,
}) {
  final face = enabled ? const Color(0xFFF7F7F7) : const Color(0xFFE6E6E6);
  paintBeveledRRect(canvas, rect, face: face, radius: 1, enabled: enabled);
  if (!checked) {
    return;
  }
  final path = Path()
    ..moveTo(rect.left + 3, rect.top + rect.height * 0.55)
    ..lineTo(rect.left + rect.width * 0.4, rect.bottom - 4)
    ..lineTo(rect.right - 3, rect.top + 4);
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = enabled ? const Color(0xFF000000) : const Color(0xFF888888),
  );
}

/// Aqua radio, radius 8. Selected state is a center dot, not a thick ring.
void paintAquaRadio(Canvas canvas, double radius, {required bool selected, required bool enabled}) {
  final center = Offset(radius, radius);
  final face = enabled ? const Color(0xFFF4F4F4) : const Color(0xFFE6E6E6);
  final light = Color.lerp(face, const Color(0xFFFFFFFF), 0.7)!;
  final dark = Color.lerp(face, const Color(0xFF000000), 0.25)!;
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        [light, face, dark],
        const [0, 0.5, 1],
      ),
  );
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = enabled ? const Color(0xFF000000) : const Color(0xFF888888),
  );
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius - 1.5),
    -3.4,
    2.2,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xE6FFFFFF),
  );
  if (selected) {
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()..color = enabled ? const Color(0xFF000000) : const Color(0xFF888888),
    );
  }
}
