import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';

void main() {
  test('wavelength writes the model and dispersion, not only a color', () {
    final model = MoreToolsModel()..setLaserOn(true);
    final nBefore = model.bottomMedium.getIndexOfRefraction(model.wavelength);
    model.setWavelength(450e-9);
    expect(model.wavelength, 450e-9);
    expect(model.laser.getWavelength(), 450e-9);
    expect(
      model.bottomMedium.getIndexOfRefraction(model.wavelength),
      isNot(closeTo(nBefore, 1e-8)),
    );
    expect(model.rays.first.wavelengthInVacuum, closeTo(450, 1e-6));
  });

  test('default is red inside 380 to 700 nm', () {
    final model = MoreToolsModel();
    expect(model.wavelength, BendingLightConstants.wavelengthRed);
    final nm = model.wavelength * 1e9;
    expect(nm, inInclusiveRange(
      BendingLightConstants.laserMinWavelengthNm,
      BendingLightConstants.laserMaxWavelengthNm,
    ));
  });
}
