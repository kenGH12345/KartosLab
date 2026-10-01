import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_constants.dart';
import 'package:kratos/gravity_force_lab_basics/model/gravity_model.dart';
import 'package:kratos/gravity_force_lab_basics/model/mass_model.dart';

void main() {
  test('CONSTANT_RADIUS matches density formula at 1e9', () {
    final r = MassModel.calculateRadius(1e9, 1.5);
    expect(r, closeTo(GflbConstants.constantRadius, 1e-9));
    expect(r, closeTo(541.9261846, 1e-3));
  });

  test('constant size ON: both radii fixed', () {
    final model = GravityModel();
    model.setConstantSize(true);
    model.setMassValue(1, 10e9);
    model.setMassValue(2, 1e9);
    expect(model.mass1.radius, closeTo(GflbConstants.constantRadius, 1e-9));
    expect(model.mass2.radius, closeTo(GflbConstants.constantRadius, 1e-9));
  });

  test('constant size OFF: radius grows with mass', () {
    final model = GravityModel();
    expect(model.constantSize, isFalse);
    final rSmall = model.mass1.radius;
    model.setMassValue(1, 8e9);
    expect(model.mass1.radius, greaterThan(rSmall));
  });
}
