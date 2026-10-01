import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/interaction/laser_interaction.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  test('laser drag changes incident, reflected and refracted rays', () {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    );
    model.setLaserOn(true);
    final beforeAngle = model.laser.getAngle();
    final beforeReflected = _tip(model, 'reflected');
    final beforeTransmitted = _tip(model, 'transmitted');

    applyQuadrantRotationDrag(
      laser: model.laser,
      worldPoint: const BlVec2(-1e-5, 1e-6),
    );
    model.updateModel();

    expect(model.laser.getAngle(), isNot(closeTo(beforeAngle, 0.01)));
    expect(model.rays.any((r) => r.rayType == 'incident'), isTrue);
    expect(_tip(model, 'reflected'), isNot(closeTo(beforeReflected, 1e-12)));
    expect(_tip(model, 'transmitted'), isNot(closeTo(beforeTransmitted, 1e-12)));
  });

  test('quadrant clamp keeps the laser in the second quadrant', () {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    );
    applyQuadrantRotationDrag(
      laser: model.laser,
      worldPoint: const BlVec2(-1, -1),
    );
    final angle = model.laser.getAngle();
    expect(angle, greaterThan(math.pi / 2 - 1e-6));
    expect(angle, lessThan(math.pi + 1e-6));
  });

  test('non-finite drag does not move the laser', () {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    );
    final before = model.laser.pivot;
    applyLaserTranslationDrag(
      laser: model.laser,
      delta: const BlVec2(double.nan, 0),
      limit: model.modelWidth,
    );
    expect(model.laser.pivot.x, before.x);
    expect(model.laser.pivot.y, before.y);
  });
}

double _tip(IntroModel model, String type) {
  final ray = model.rays.firstWhere((r) => r.rayType == type);
  return ray.tip.x + ray.tip.y;
}
