import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';
import 'package:kratos/balloons_and_static_electricity/model/charge_positions.dart';
import 'package:kratos/balloons_and_static_electricity/model/force_utils.dart';

void main() {
  group('BalloonModel initial / geometry', () {
    late BalloonsStaticElectricityModel model;

    setUp(() {
      model = BalloonsStaticElectricityModel();
    });

    test('yellow and green initial state', () {
      expect(model.yellowBalloon.position, BaseConstants.yellowInitialPosition);
      expect(model.yellowBalloon.isVisible, isTrue);
      expect(model.yellowBalloon.charge, 0);
      expect(model.yellowBalloon.velocity, BaseVec2.zero);

      expect(model.greenBalloon.position, BaseConstants.greenInitialPosition);
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.greenBalloon.charge, 0);
    });

    test('size and charge slots', () {
      expect(BaseConstants.balloonWidth, 134);
      expect(BaseConstants.balloonHeight, 222);
      expect(ChargePositions.balloonStartChargePositions, hasLength(4));
      expect(
        ChargePositions.balloonCollectedMinusChargePositions,
        hasLength(58),
      );
      expect(BaseConstants.maxBalloonCharge, 57);
      expect(model.yellowBalloon.plusCharges, hasLength(4));
      expect(
        model.yellowBalloon.minusCharges,
        hasLength(4 + 58),
      );
    });

    test('drag bounds with and without wall', () {
      expect(model.yellowBalloon.dragBounds.right, 554);
      expect(model.yellowBalloon.dragBounds.bottom, 282);
      model.removeWall();
      expect(model.yellowBalloon.dragBounds.right, 634);
      expect(model.yellowBalloon.dragBounds.bottom, 282);
    });

    test('hit geometry is ellipse+nub not full rect', () {
      final b = model.yellowBalloon;
      expect(b.hitTestLocal(const BaseVec2(67, 100)), isTrue);
      expect(b.hitTestLocal(const BaseVec2(1, 1)), isFalse);
      expect(b.hitTestLocal(const BaseVec2(67, 210)), isTrue);
    });

    test('position drag is continuous and clamped', () {
      final b = model.yellowBalloon;
      model.dragBalloonTo(b, const BaseVec2(100, 50));
      expect(b.position, const BaseVec2(100, 50));
      expect(b.userControlled, isTrue);
      model.dragBalloonTo(b, const BaseVec2(9999, 9999));
      expect(b.position.x, 554);
      expect(b.position.y, 282);
    });

    test('release clears userControlled and zeros velocity', () {
      final b = model.yellowBalloon;
      model.dragBalloonTo(b, const BaseVec2(200, 80));
      model.releaseBalloon(b);
      expect(b.userControlled, isFalse);
      expect(b.velocity, BaseVec2.zero);
    });
  });

  group('ForceUtils', () {
    test('zero distance returns zero force', () {
      final f = ForceUtils.getForce(
        const BaseVec2(1, 1),
        const BaseVec2(1, 1),
        10,
      );
      expect(f, BaseVec2.zero);
    });

    test('force capped at 1e-2', () {
      final huge = ForceUtils.capMagnitude(const BaseVec2(1, 0), 1e-2);
      expect(huge.magnitude, closeTo(1e-2, 1e-12));
    });

    test('same-sign charges produce repulsion direction', () {
      final f = ForceUtils.getForce(
        const BaseVec2(10, 0),
        const BaseVec2(0, 0),
        BaseConstants.forceConstant * (-10) * (-10),
      );
      expect(f.x, greaterThan(0));
    });
  });
}
