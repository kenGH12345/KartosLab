import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';

/// Source: `BackgroundNode.js` — sky gradient / black + brown ground.
class UpBackgroundPainter extends CustomPainter {
  UpBackgroundPainter({
    required this.mvt,
    required this.isAtmosphere,
  });

  final UpMvt mvt;
  final bool isAtmosphere;

  static const Color skyTop = Color(0xFF01ACE4);
  static const Color groundColor = Color(0xFF93774C);

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = mvt.modelToView(0, 0).dy;

    if (isAtmosphere) {
      final skyPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, groundY),
          const [skyTop, Color(0xFFE8F7FC)],
        );
      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, groundY), skyPaint);
    } else {
      canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, groundY),
        Paint()..color = Colors.black,
      );
    }

    canvas.drawRect(
      Rect.fromLTRB(0, groundY, size.width, size.height),
      Paint()..color = groundColor,
    );
  }

  @override
  bool shouldRepaint(covariant UpBackgroundPainter old) =>
      old.isAtmosphere != isAtmosphere || old.mvt.scale != mvt.scale;
}

class UpBackgroundLayer extends StatelessWidget {
  const UpBackgroundLayer({super.key, required this.controller});

  final UnderPressureController controller;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: UpBackgroundPainter(
        mvt: controller.mvt,
        isAtmosphere: controller.model.isAtmosphere,
      ),
      child: const SizedBox.expand(),
    );
  }
}
