import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_constants.dart';
import 'package:kratos/gravity_force_lab_basics/model/gravity_model.dart';

void main() {
  test('reset restores defaults', () {
    final model = GravityModel();
    model.setMassValue(1, 9e9);
    model.setMassValue(2, 10e9);
    model.setConstantSize(true);
    model.setShowDistance(false);
    model.setShowForceValues(false);
    model.beginDrag(1);
    model.setPositionWhileDragging(1, -4000);
    model.endDrag(1);

    model.reset();

    expect(model.mass1.value, GflbConstants.initialMass1);
    expect(model.mass2.value, GflbConstants.initialMass2);
    expect(model.mass1.positionX, GflbConstants.initialPosition1);
    expect(model.mass2.positionX, GflbConstants.initialPosition2);
    expect(model.constantSize, GflbConstants.defaultConstantSize);
    expect(model.showDistance, GflbConstants.defaultShowDistance);
    expect(model.showForceValues, GflbConstants.defaultShowForceValues);
    expect(model.force, closeTo(33.3715, 1e-6));
  });
}
