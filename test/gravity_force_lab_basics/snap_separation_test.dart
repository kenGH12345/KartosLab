import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_constants.dart';
import 'package:kratos/gravity_force_lab_basics/model/gravity_model.dart';
import 'package:kratos/gravity_force_lab_basics/solver/force_solver.dart';

void main() {
  test('snap rounds to 100 m', () {
    expect(ForceSolver.snapToGrid(2050), 2100);
    expect(ForceSolver.snapToGrid(2049), 2000);
    expect(ForceSolver.snapToGrid(-2050), -2100);
  });

  test('drag respects minSeparation surface gap 200 m', () {
    final model = GravityModel();
    // Move mass1 toward mass2 as far as enabled range allows.
    model.beginDrag(1);
    model.setPositionWhileDragging(1, 5000);
    model.endDrag(1);
    final minCenters =
        model.mass1.radius + model.mass2.radius + GflbConstants.minDistanceBetweenMasses;
    expect(model.separation + 1e-6, greaterThanOrEqualTo(ForceSolver.snapToGrid(minCenters)));
  });

  test('positions stay within ±5000', () {
    final model = GravityModel();
    model.beginDrag(1);
    model.setPositionWhileDragging(1, -99999);
    model.endDrag(1);
    expect(model.mass1.positionX, greaterThanOrEqualTo(-GflbConstants.pullPositionMax));

    model.beginDrag(2);
    model.setPositionWhileDragging(2, 99999);
    model.endDrag(2);
    expect(model.mass2.positionX, lessThanOrEqualTo(GflbConstants.pullPositionMax));
  });
}
