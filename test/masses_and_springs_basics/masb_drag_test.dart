import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/masb_constants.dart';
import 'package:kratos/masses_and_springs_basics/model/masb_model.dart';

void main() {
  group('Mass drag', () {
    MasbModel attached() {
      final model = MasbModel(damping: 0);
      final mass = model.masses.firstWhere((e) => e.massKg == 0.100);
      model.attachMassToSpring(mass, model.firstSpring);
      return model;
    }

    test('grab → pull down → displacement updates → release resumes oscillation',
        () {
      final model = attached();
      final mass = model.firstSpring.massAttached!;
      final grabY = mass.positionY - mass.cylinderHeight / 2;
      expect(model.beginDrag(mass.positionX, grabY), isTrue);
      expect(mass.userControlled, isTrue);

      final pullY = mass.positionY - 0.2;
      model.updateDrag(model.spring.positionX, pullY);
      expect(model.spring.displacement, lessThan(-0.1));

      model.endDrag();
      expect(mass.userControlled, isFalse);
      expect(mass.spring, isNotNull);

      final xRelease = model.spring.displacement;
      model.step(1 / 60);
      expect(model.spring.displacement, isNot(xRelease));
      expect(mass.verticalVelocity.abs(), greaterThan(0));
    });

    test('horizontal drag beyond release distance detaches mass', () {
      final model = attached();
      final mass = model.firstSpring.massAttached!;
      final y = mass.positionY - mass.cylinderHeight / 2;
      model.beginDrag(mass.positionX, y);
      model.updateDrag(
        model.spring.positionX + MasbConstants.releaseDistance + 0.05,
        y,
      );
      expect(mass.spring, isNull);
      expect(model.spring.massAttached, isNull);
      model.endDrag();
    });

    test('drag near spring bottom re-attaches free mass', () {
      final model = MasbModel(damping: 0);
      final mass = model.masses.firstWhere((e) => e.massKg == 0.100);
      mass.positionX = model.spring.positionX + 0.05;
      mass.positionY = model.spring.bottom;
      mass.onShelf = false;
      model.beginDrag(mass.positionX, mass.positionY);
      model.updateDrag(model.spring.positionX, model.spring.bottom);
      expect(mass.spring, same(model.spring));
      model.endDrag();
    });

    test('drag clamps above floor', () {
      final model = attached();
      final mass = model.firstSpring.massAttached!;
      model.beginDrag(mass.positionX, mass.positionY);
      model.updateDrag(model.spring.positionX, -1);
      expect(mass.positionY, greaterThanOrEqualTo(mass.height));
      model.endDrag();
    });
  });
}
