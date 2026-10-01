import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';
import 'package:kratos/bending_light/physics/visible_color.dart';
import 'package:kratos/bending_light/physics/white_light.dart';

void main() {
  test('visible color matches the piecewise table at red, green, and blue', () {
    final red = argbChannels(visibleColorArgb(650)!);
    final green = argbChannels(visibleColorArgb(550)!);
    final blue = argbChannels(visibleColorArgb(450)!);
    expect(red.$1, greaterThan(red.$2));
    expect(red.$3, 0);
    expect(green.$2, greaterThan(green.$1));
    expect(blue.$3, greaterThan(blue.$1));
    expect(visibleColorArgb(300), isNull);
    expect(visibleColorArgb(800), isNull);
    expect(visibleColorArgb(0), 0xFFFFFFFF);
  });

  test('white-light samples are 400 to 690 nm step 10', () {
    final samples = BendingLightConstants.whiteLightWavelengthsNm;
    expect(samples.first, 400);
    expect(samples.last, 690);
    expect(samples.length, 30);
    expect(samples[1] - samples[0], 10);
  });

  test('white-light stroke uses D65 and VisibleColor, not a rainbow lerp', () {
    final red = whiteLightStrokeRgb(wavelengthNm: 650, powerFraction: 1);
    final blue = whiteLightStrokeRgb(wavelengthNm: 450, powerFraction: 1);
    expect(red, isNotNull);
    expect(blue, isNotNull);
    expect(red!.$1, greaterThan(red.$3));
    expect(blue!.$3, greaterThan(blue.$1));
    expect(whiteLightStrokeRgb(wavelengthNm: 200, powerFraction: 1), isNull);
    expect(whiteLightStrokeRgb(wavelengthNm: 650, powerFraction: 0), isNull);
  });

  test('XYZ times D65 times the source matrix differs for red and blue', () {
    final red = XyzToRgb.linearRgb(650)!;
    final blue = XyzToRgb.linearRgb(450)!;
    expect(red.$1, isNot(closeTo(blue.$1, 1)));
    expect(XyzToRgb.linearRgb(123), isNull);
  });

  test('white light traces one family per sample wavelength', () {
    final model = PrismsModel()..setLaserOn(true);
    final square = model.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
    model.addPrism(Prism(square.$1, square.$2).copy());
    model.setLightType(LightType.white);
    final wavelengths = model.rays.map((r) => r.wavelengthInVacuum.round()).toSet();
    expect(wavelengths, contains(400));
    expect(wavelengths, contains(690));
    expect(wavelengths.length, greaterThan(2));
    expect(model.rays.length, lessThan(BendingLightConstants.maxLightRaySteps * 30));
  });
}
