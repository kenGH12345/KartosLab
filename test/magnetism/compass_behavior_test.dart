import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/magnetism/magnet_and_compass/magnet_and_compass_constants.dart';
import 'package:kratos/magnetism/magnet_and_compass/model/magnetic_field.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/bar_magnet_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/earth_glow_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/field_needle_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/vertical_magnet_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/widgets/mini_compass_preview_painter.dart';

void main() {
  group('CompassPainter API', () {
    test('constructs with needleAngle; shouldRepaint tracks angle', () {
      const a = CompassPainter(needleAngle: 0);
      const b = CompassPainter(needleAngle: 0.4);
      expect(a.needleAngle, 0);
      expect(b.needleAngle, 0.4);
      expect(a.shouldRepaint(a), isFalse);
      expect(a.shouldRepaint(const CompassPainter(needleAngle: 0)), isFalse);
      expect(a.shouldRepaint(b), isTrue);
    });

    testWidgets('paints at 0, π/2, π without throwing', (tester) async {
      for (final angle in [0.0, pi / 2, pi]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                size: const Size(152, 152),
                painter: CompassPainter(needleAngle: angle),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Compass angle vs field', () {
    test('needle target equals fieldAngle; flip reverses by π', () {
      const magnetPos = Offset(0, 0);
      const compassPos = Offset(400, 80);
      final n = MagneticField.compute(
        compassPos,
        magnetPos,
        0,
        kMagnetWidth / 2,
        0.75,
        false,
        false,
      );
      final f = MagneticField.compute(
        compassPos,
        magnetPos,
        0,
        kMagnetWidth / 2,
        0.75,
        true,
        false,
      );
      final aN = MagneticField.fieldAngle(n);
      final aF = MagneticField.fieldAngle(f);
      // Opposite vectors: Δθ ≡ π (mod 2π) → cos(Δθ) = -1.
      expect(cos(aF - aN), closeTo(-1.0, 1e-9));
    });
  });

  group('Other painters render', () {
    testWidgets('BarMagnet / FieldNeedle / Vertical / EarthGlow / MiniCompass paint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: CustomPaint(
                    painter: const BarMagnetPainter(seeInside: true, flipped: false),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 120,
                  child: CustomPaint(
                    painter: const FieldNeedlePainter(
                      magnetPos: Offset(100, 60),
                      magnetAngle: 0,
                      strength: 0.75,
                      flipped: false,
                      earthField: false,
                      magnetW: kMagnetWidth,
                      magnetH: kMagnetHeight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  height: 80,
                  child: CustomPaint(
                    painter: const VerticalMagnetPainter(flipped: false),
                  ),
                ),
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(painter: EarthGlowPainter()),
                ),
                SizedBox(
                  width: 60,
                  height: 22,
                  child: CustomPaint(painter: MiniCompassPreviewPainter()),
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
