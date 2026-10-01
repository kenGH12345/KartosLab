import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';
import 'package:kratos/balloons_and_static_electricity/model/charge_positions.dart';

void main() {
  group('SweaterModel', () {
    late BalloonsStaticElectricityModel model;

    setUp(() {
      model = BalloonsStaticElectricityModel();
    });

    test('initial geometry and charge', () {
      final s = model.sweater;
      expect(s.x, 25);
      expect(s.y, 20);
      expect(s.width, 305);
      expect(s.height, 385);
      expect(s.charge, 0);
      expect(s.plusCharges, hasLength(57));
      expect(s.minusCharges, hasLength(57));
      expect(ChargePositions.sweaterChargePairPositions, hasLength(57));
    });

    test('chargedArea is not sweater bounds', () {
      final s = model.sweater;
      expect(s.chargedAreaVertices, hasLength(9));
      expect(
        s.chargedAreaContainsPoint(const BaseVec2(0, 0)),
        isFalse,
      );
      expect(s.chargedAreaContainsPoint(s.center), isTrue);
    });

    test('overlap sweater alone does not transfer charge', () {
      final b = model.yellowBalloon;
      model.dragBalloonTo(b, const BaseVec2(40, 40));
      expect(b.charge, 0);
      expect(model.sweater.charge, 0);
    });

    test('spatial sweep transfers and marks moved once', () {
      final b = model.yellowBalloon;
      final target = model.sweater.minusCharges.first;

      final place = BaseVec2(
        target.position.x - 20,
        target.position.y - 20,
      );
      model.dragBalloonTo(b, place);
      b.oldPosition = b.position.copy();
      model.dragBalloonTo(
        b,
        BaseVec2(place.x + 2, place.y + 2),
      );
      b.step(1 / 60);

      expect(target.moved, isTrue);
      expect(b.charge, lessThan(0));
      expect(model.sweater.charge, greaterThan(0));

      final chargeAfterFirst = b.charge;
      final sweaterAfterFirst = model.sweater.charge;

      b.oldPosition = b.position.copy();
      model.dragBalloonTo(
        b,
        BaseVec2(b.position.x + 1, b.position.y + 1),
      );
      b.step(1 / 60);
      expect(b.charge, chargeAfterFirst);
      expect(model.sweater.charge, sweaterAfterFirst);
    });

    test('charge capacity capped at 57', () {
      final b = model.yellowBalloon;
      for (final minus in model.sweater.minusCharges) {
        model.sweater.moveChargeTo(minus, b);
      }
      expect(model.sweater.charge, 57);
      expect(b.charge, -57);
      expect(b.charge >= -BaseConstants.maxBalloonCharge, isTrue);

      final movedAgain = model.sweater.checkAndTransferCharges(b);
      expect(movedAgain, isFalse);
      expect(model.sweater.charge, 57);
      expect(b.charge, -57);
    });

    test('centerInSweaterChargedArea freezes free motion', () {
      final b = model.yellowBalloon;
      b.setCenter(model.sweater.center);
      model.releaseBalloon(b);
      b.velocity = const BaseVec2(5, 5);
      b.applyForce(16);
      expect(b.velocity, BaseVec2.zero);
    });
  });
}
