import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';
import 'package:kratos/balloons_and_static_electricity/model/point_charge_model.dart';

void main() {
  group('WallModel', () {
    late BalloonsStaticElectricityModel model;

    setUp(() {
      model = BalloonsStaticElectricityModel();
    });

    test('initial geometry and grid', () {
      final w = model.wall;
      expect(w.x, 688);
      expect(w.width, 80);
      expect(w.height, 504);
      expect(w.isVisible, isTrue);
      expect(w.numX, 3);
      expect(w.numY, 18);
      expect(w.plusCharges, hasLength(54));
      expect(w.minusCharges, hasLength(54));
      expect(BaseConstants.wallChargePairCount, 54);
    });

    test('plus fixed, minus movable; net neutral count', () {
      final w = model.wall;
      final initialMinus = w.minusCharges.map((c) => c.position).toList();
      w.updateChargePositions();
      for (var i = 0; i < w.minusCharges.length; i++) {
        expect(w.minusCharges[i].position, initialMinus[i]);
        expect(w.plusCharges[i].position, w.plusCharges[i].initialPosition);
      }
    });

    test('charged visible balloon displaces wall minus charges', () {
      final b = model.yellowBalloon;
      b.charge = -30;
      b.setPosition(const BaseVec2(500, 100));
      model.wall.updateChargePositions();

      var anyDisplaced = false;
      for (final m in model.wall.minusCharges) {
        if (m.getDisplacement() > 0.01) {
          anyDisplaced = true;
          break;
        }
      }
      expect(anyDisplaced, isTrue);
    });

    test('hidden balloon does not contribute polarization', () {
      model.setTwoBalloons(true);
      model.yellowBalloon.charge = -40;
      model.greenBalloon.charge = -40;
      model.yellowBalloon.setPosition(const BaseVec2(500, 80));
      model.greenBalloon.setPosition(const BaseVec2(500, 200));
      model.wall.updateChargePositions();
      final withBoth = model.wall.minusCharges
          .map((c) => c.getDisplacement())
          .fold<double>(0, (a, b) => a + b);

      model.greenBalloon.isVisible = false;
      model.wall.updateChargePositions();
      final withYellowOnly = model.wall.minusCharges
          .map((c) => c.getDisplacement())
          .fold<double>(0, (a, b) => a + b);

      expect(withBoth, greaterThan(withYellowOnly));
    });

    test('inducingCharge when force magnitude > 2', () {
      final b = model.yellowBalloon;
      b.charge = -40;
      b.setPosition(const BaseVec2(520, 100));
      model.wall.updateChargePositions();
      b.closestChargeInWall = model.wall.getClosestChargeToBalloon(b);
      b.inducingCharge = b.inducingChargeForWall(true);
      expect(b.inducingCharge, isTrue);

      b.charge = 0;
      b.inducingCharge = b.inducingChargeForWall(true);
      expect(b.inducingCharge, isFalse);
    });

    test('remove / add wall updates playAreaMaxX', () {
      expect(model.playAreaMaxX, 688);
      model.removeWall();
      expect(model.wall.isVisible, isFalse);
      expect(model.playAreaMaxX, 768);
      model.addWall();
      expect(model.wall.isVisible, isTrue);
      expect(model.playAreaMaxX, 688);
    });

    test('reset restores visibility and minus positions', () {
      model.removeWall();
      model.yellowBalloon.charge = -20;
      model.yellowBalloon.setPosition(const BaseVec2(500, 100));
      model.wall.updateChargePositions();
      model.wall.reset();
      expect(model.wall.isVisible, isTrue);
      for (final m in model.wall.minusCharges) {
        expect(m.position, m.initialPosition);
      }
      expect(PointChargeModel.radius, 8);
      expect(PointChargeModel.charge, -1.754);
    });
  });
}
