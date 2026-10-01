import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/interaction/layout_bump.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  const toolbox = Rect.fromLTWH(4, 336, 120, 160);

  test('drop inside the toolbox does not place', () {
    expect(droppedOutsideToolbox(const Offset(20, 400), toolbox), isFalse);
  });

  test('drop outside the toolbox places one instance', () {
    expect(droppedOutsideToolbox(const Offset(300, 200), toolbox), isTrue);
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    );
    final meter = model.intensityMeter;
    expect(meter.enabled, isFalse);
    final drop = const BlVec2(-1e-5, 1e-6);
    final dx = drop.x - meter.bodyPosition.x;
    final dy = drop.y - meter.bodyPosition.y;
    meter.bodyPosition = drop;
    meter.sensorPosition = meter.sensorPosition.plusXY(dx, dy);
    meter.enabled = true;
    expect(meter.enabled, isTrue);
    expect(meter.bodyPosition.x, drop.x);
  });
}
