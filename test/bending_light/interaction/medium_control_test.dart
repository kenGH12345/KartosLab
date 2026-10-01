import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  test('Air to Water changes n and refracted angle', () {
    final model = _on();
    model.setBottomSubstance(Substance.water);
    final water = model.computeSnell().theta2;
    expect(model.indexOfRefractionOfBottomMedium, closeTo(1.333, 0.02));
    expect(water, isNot(closeTo(model.computeSnell().theta1, 1e-6)));
  });

  test('Water to Air can differ from Air to Water', () {
    final down = _on();
    down.setTopSubstance(Substance.air);
    down.setBottomSubstance(Substance.water);
    final up = _on();
    up.setTopSubstance(Substance.water);
    up.setBottomSubstance(Substance.air);
    expect(down.indexOfRefractionOfBottomMedium, isNot(up.indexOfRefractionOfBottomMedium));
    expect(down.computeSnell().theta2.isNaN, isFalse);
  });

  test('Air to Glass bends more than Air to Water', () {
    final water = _on()..setBottomSubstance(Substance.water);
    final glass = _on()..setBottomSubstance(Substance.glass);
    final dw = (water.computeSnell().theta1 - water.computeSnell().theta2).abs();
    final dg = (glass.computeSnell().theta1 - glass.computeSnell().theta2).abs();
    expect(dg, greaterThan(dw));
  });

  test('Glass to Air is the reverse stack', () {
    final model = _on();
    model.setTopSubstance(Substance.glass);
    model.setBottomSubstance(Substance.air);
    expect(model.indexOfRefractionOfTopMedium, greaterThan(model.indexOfRefractionOfBottomMedium));
  });

  test('equal indices keep theta2 near theta1', () {
    final model = _on();
    model.setTopSubstance(Substance.air);
    model.setBottomSubstance(Substance.air);
    final snell = model.computeSnell();
    expect((snell.theta2 - snell.theta1).abs(), lessThan(1e-3));
  });

  test('water over air at a steep angle is TIR', () {
    final model = _on();
    model.setTopSubstance(Substance.water);
    model.setBottomSubstance(Substance.air);
    model.laser.setAngle(math.pi);
    model.updateModel();
    expect(model.rays.any((r) => r.rayType == 'transmitted'), isFalse);
    expect(model.rays.any((r) => r.rayType == 'reflected'), isTrue);
  });
}

IntroModel _on() {
  final model = IntroModel(
    bottomSubstance: Substance.water,
    horizontalPlayAreaOffset: true,
  );
  model.setLaserOn(true);
  return model;
}
