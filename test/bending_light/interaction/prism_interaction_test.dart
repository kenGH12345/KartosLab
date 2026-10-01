import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/interaction/laser_interaction.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';

void main() {
  test('rotating a prism changes the ray path', () {
    final model = _aimed();
    final before = _signature(model);
    model.prisms.first.rotate(0.35);
    model.updateModel();
    expect(_signature(model), isNot(before));
  });

  test('dragging a prism changes the ray path', () {
    final model = _aimed();
    final before = _signature(model);
    model.prisms.first.translate(2e-6, 1e-6);
    model.updateModel();
    expect(_signature(model), isNot(before));
  });

  test('knob rotation is not quadrant-clamped', () {
    final model = PrismsModel();
    applyKnobRotationDrag(
      laser: model.laser,
      worldPoint: const BlVec2(1, -1),
    );
    final angle = model.laser.getAngle();
    // getAngle is direction.angle + pi, so a Q4 grab is outside [pi/2, pi].
    final inQuadrant2 = angle >= 1.5707963267948966 && angle <= 3.141592653589793;
    expect(inQuadrant2, isFalse);
  });

  test('white light disables the single-wavelength mode', () {
    final model = PrismsModel()..setLaserOn(true);
    model.setLightType(LightType.white);
    expect(model.laser.colorMode, ColorModeEnum.white);
    expect(model.manyRays, 1);
  });

  test('5x sets manyRays', () {
    final model = PrismsModel();
    model.setLightType(LightType.singleColor5x);
    expect(model.manyRays, 5);
    expect(model.laser.colorMode, ColorModeEnum.singleColor);
  });

  test('dropping a prism center into the toolbox removes it', () {
    final model = _aimed();
    expect(model.prisms, isNotEmpty);
    model.removePrism(model.prisms.first);
    expect(model.prisms, isEmpty);
  });
}

PrismsModel _aimed() {
  final model = PrismsModel()..setLaserOn(true);
  final proto = model.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
  model.addPrism(Prism(proto.$1, proto.$2).copy());
  model.laser.pivot = BlVec2.zero;
  model.laser.emissionPoint = const BlVec2(-2.5e-5, 0);
  model.laser.setAngle(3.141592653589793);
  model.updateModel();
  return model;
}

String _signature(PrismsModel model) {
  return model.rays
      .map((r) => '${r.tip.x.toStringAsExponential(4)},${r.tip.y.toStringAsExponential(4)}')
      .join('|');
}
