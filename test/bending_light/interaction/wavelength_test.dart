import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';

void main() {
  test('wavelength slider writes the model, not a view color', () {
    final model = MoreToolsModel()..setLaserOn(true);
    final before = model.rays.first.wavelengthInVacuum;
    final beforeColor = model.rays.first.colorArgb;
    model.setWavelength(450e-9);
    expect(model.wavelength, 450e-9);
    expect(model.laser.getWavelength(), 450e-9);
    expect(model.rays.first.wavelengthInVacuum, isNot(before));
    expect(model.rays.first.colorArgb, isNot(beforeColor));
  });

  test('default wavelength is red and stays inside the slider range', () {
    final model = MoreToolsModel();
    expect(model.wavelength, BendingLightConstants.wavelengthRed);
    final nm = model.wavelength * 1e9;
    expect(nm, inInclusiveRange(BendingLightConstants.laserMinWavelengthNm, BendingLightConstants.laserMaxWavelengthNm));
  });
}
