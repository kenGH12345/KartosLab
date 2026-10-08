import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/bl_strings.dart';

void main() {
  test('Intro reset restores laser, media, time and sensor', () {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    );
    model.setLaserOn(true);
    model.setTopSubstance(Substance.glass);
    model.setBottomSubstance(Substance.glass);
    model.setLaserView(LaserViewEnum.wave);
    model.setWavelength(500e-9);
    model.intensityMeter.enabled = true;
    model.step();
    model.togglePlaying();

    model.reset();

    expect(model.laser.on, isFalse);
    expect(model.laserView, LaserViewEnum.ray);
    expect(model.topMedium.substance.name, BlStrings.air);
    expect(model.bottomMedium.substance.name, BlStrings.water);
    expect(model.wavelength, BendingLightConstants.wavelengthRed);
    expect(model.time, 0);
    expect(model.isPlaying, isTrue);
    expect(model.intensityMeter.enabled, isFalse);
    expect(model.showNormal, isTrue);
  });

  test('More Tools reset restores glass, wavelength, sensors and time', () {
    final model = MoreToolsModel();
    model.setLaserOn(true);
    model.setWavelength(420e-9);
    model.setShowAngles(true);
    model.velocitySensor.enabled = true;
    model.waveSensor.enabled = true;
    model.step();
    model.reset();

    expect(model.bottomMedium.substance.name, BlStrings.glass);
    expect(model.wavelength, BendingLightConstants.wavelengthRed);
    expect(model.showAngles, isFalse);
    expect(model.velocitySensor.enabled, isFalse);
    expect(model.waveSensor.enabled, isFalse);
    expect(model.time, 0);
    expect(model.laser.on, isFalse);
  });

  test('Prisms reset clears prisms and tools', () {
    final model = PrismsModel();
    final proto = model.getPrismPrototypes().first;
    model.addPrism(Prism(proto.$1, proto.$2).copy());
    model.setShowReflections(true);
    model.setShowProtractor(true);
    model.setLightType(LightType.white);
    model.setLaserOn(true);
    model.reset();

    expect(model.prisms, isEmpty);
    expect(model.showReflections, isFalse);
    expect(model.showProtractor, isFalse);
    expect(model.laser.colorMode, ColorModeEnum.singleColor);
    expect(model.manyRays, 1);
    expect(model.laser.on, isFalse);
  });
}
