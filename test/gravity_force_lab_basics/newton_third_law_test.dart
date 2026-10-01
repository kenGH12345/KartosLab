import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab_basics/model/gravity_model.dart';

void main() {
  test('Newton third law: equal opposite force signs', () {
    final model = GravityModel();
    expect(model.forceOnMass1Sign, 1); // toward mass2 (right)
    expect(model.forceOnMass2Sign, -1); // toward mass1 (left)
    expect(model.forceOnMass1Sign + model.forceOnMass2Sign, 0);
    expect(model.forceMagnitude, greaterThan(0));

    // Move farther apart — signs unchanged while mass1 stays left of mass2.
    model.beginDrag(1);
    model.setPositionWhileDragging(1, -4000);
    model.endDrag(1);
    model.beginDrag(2);
    model.setPositionWhileDragging(2, 4000);
    model.endDrag(2);
    expect(model.mass1.positionX < model.mass2.positionX, isTrue);
    expect(model.forceOnMass1Sign, 1);
    expect(model.forceOnMass2Sign, -1);
  });

  test('arrow tip signs are opposite', () {
    final model = GravityModel();
    expect(model.forceOnMass1Sign, -model.forceOnMass2Sign);
  });
}
