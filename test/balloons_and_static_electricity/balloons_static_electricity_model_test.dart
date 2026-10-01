import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';

/// Helper: rub balloon across all sweater minus charges with motion.
void rubAcrossSweater(BalloonsStaticElectricityModel model,
    {required bool yellow}) {
  final balloon = yellow ? model.yellowBalloon : model.greenBalloon;
  model.dragBalloonTo(balloon, balloon.position);
  for (final minus in model.sweater.minusCharges) {
    if (minus.moved) continue;
    final place = BaseVec2(minus.position.x - 40, minus.position.y - 40);
    balloon.oldPosition = balloon.position.copy();
    model.dragBalloonTo(balloon, place);
    // Move slightly to create speed > 0 while covering the charge.
    balloon.oldPosition = balloon.position.copy();
    model.dragBalloonTo(
      balloon,
      BaseVec2(place.x + 3, place.y + 3),
    );
    balloon.step(1 / 60);
  }
  model.releaseBalloon(balloon);
}

void main() {
  group('BASEModel integration', () {
    late BalloonsStaticElectricityModel model;

    setUp(() {
      model = BalloonsStaticElectricityModel();
    });

    test('showCharges modes do not alter physical charge', () {
      model.yellowBalloon.charge = -12;
      model.setShowCharges(ShowCharges.noCharges);
      expect(model.yellowBalloon.charge, -12);
      model.setShowCharges(ShowCharges.chargeDifferences);
      expect(model.yellowBalloon.charge, -12);
      model.setShowCharges(ShowCharges.allCharges);
      expect(model.showCharges, ShowCharges.allCharges);
    });

    test('one / two balloon selection toggles green visibility', () {
      expect(model.greenBalloon.isVisible, isFalse);
      model.setTwoBalloons(true);
      expect(model.greenBalloon.isVisible, isTrue);
      model.setTwoBalloons(false);
      expect(model.greenBalloon.isVisible, isFalse);
      // Object still exists.
      expect(model.greenBalloon.charge, 0);
    });

    test('Reset Balloon(s) preserves visibility, showCharges, wall', () {
      model.setTwoBalloons(true);
      model.setShowCharges(ShowCharges.chargeDifferences);
      model.removeWall();
      model.yellowBalloon.charge = -10;
      model.greenBalloon.charge = -8;
      model.dragBalloonTo(model.yellowBalloon, const BaseVec2(200, 50));
      model.releaseBalloon(model.yellowBalloon);

      model.resetBalloons();

      expect(model.greenBalloon.isVisible, isTrue);
      expect(model.showCharges, ShowCharges.chargeDifferences);
      expect(model.wall.isVisible, isFalse);
      expect(model.yellowBalloon.charge, 0);
      expect(model.greenBalloon.charge, 0);
      expect(
        model.yellowBalloon.position,
        BaseConstants.yellowInitialPosition,
      );
      expect(
        model.greenBalloon.position,
        BaseConstants.greenInitialPosition,
      );
      expect(model.sweater.charge, 0);
    });

    test('Reset All restores green, showCharges, wall, charges', () {
      model.setTwoBalloons(true);
      model.setShowCharges(ShowCharges.chargeDifferences);
      model.removeWall();
      model.yellowBalloon.charge = -10;
      model.greenBalloon.charge = -8;

      model.reset();

      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.showCharges, ShowCharges.allCharges);
      expect(model.wall.isVisible, isTrue);
      expect(model.yellowBalloon.charge, 0);
      expect(model.greenBalloon.charge, 0);
      expect(model.sweater.charge, 0);
      expect(model.playAreaMaxX, 688);
    });

    test('Flow A: rub → charge → release → wall attraction path', () {
      rubAcrossSweater(model, yellow: true);
      expect(model.yellowBalloon.charge, lessThan(-5));

      // Place near wall and release so special attraction can act.
      final b = model.yellowBalloon;
      model.dragBalloonTo(b, const BaseVec2(540, 100));
      model.releaseBalloon(b);
      final xBefore = b.position.x;
      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      // Should move toward wall (increasing x) or settle at wall.
      expect(b.position.x >= xBefore - 1e-6, isTrue);
      expect(b.position.x.isFinite, isTrue);
      expect(b.velocity.x.isFinite, isTrue);
    });

    test('Flow B: two charged balloons repel', () {
      model.setTwoBalloons(true);
      // Give both negative charge without exhausting sweater for both equally.
      model.yellowBalloon.charge = -20;
      model.greenBalloon.charge = -20;
      model.yellowBalloon.setPosition(const BaseVec2(400, 100));
      model.greenBalloon.setPosition(const BaseVec2(430, 100));
      model.releaseBalloon(model.yellowBalloon);
      model.releaseBalloon(model.greenBalloon);

      final dist0 =
          model.yellowBalloon.getCenter().distance(model.greenBalloon.getCenter());
      for (var i = 0; i < 90; i++) {
        model.step(1 / 60);
      }
      final dist1 =
          model.yellowBalloon.getCenter().distance(model.greenBalloon.getCenter());
      expect(dist1, greaterThan(dist0));
    });

    test('Flow C: remove wall then add wall', () {
      model.yellowBalloon.charge = -15;
      model.removeWall();
      model.dragBalloonTo(model.yellowBalloon, const BaseVec2(600, 100));
      expect(model.yellowBalloon.position.x, lessThanOrEqualTo(634));
      model.releaseBalloon(model.yellowBalloon);
      model.addWall();
      expect(model.wall.isVisible, isTrue);
      expect(model.yellowBalloon.position.x, lessThanOrEqualTo(554));
    });

    test('dragged balloon suppresses other-balloon force', () {
      model.setTwoBalloons(true);
      model.yellowBalloon.charge = -25;
      model.greenBalloon.charge = -25;
      model.yellowBalloon.setPosition(const BaseVec2(400, 100));
      model.greenBalloon.setPosition(const BaseVec2(450, 100));
      model.yellowBalloon.beginDrag();
      final force = model.greenBalloon.getOtherBalloonForce();
      // Yellow is userControlled → green sees zero other force? 
      // Source: getOtherBalloonForce on THIS balloon returns 0 if THIS is userControlled
      // or other invisible. Green is not userControlled, yellow is — but check is:
      // if (this.userControlled || !this.visible || !other.visible) return 0
      // So green's getOtherBalloonForce: this=green not controlled, other=yellow visible → force NOT zero.
      // Yellow's getOtherBalloonForce: this=yellow userControlled → 0.
      expect(model.yellowBalloon.getOtherBalloonForce(), BaseVec2.zero);
      expect(force.magnitude, greaterThan(0));
    });

    test('wall special attraction when charge < -5 and near', () {
      final b = model.yellowBalloon;
      b.charge = -20;
      // relDist = (688 - x) - 134 <= 40 + charge/8 = 40 - 2.5 = 37.5
      // 688 - x - 134 <= 37.5 → 554 - x <= 37.5 → x >= 516.5
      b.setPosition(const BaseVec2(530, 120));
      model.releaseBalloon(b);
      final force = b.getTotalForce();
      expect(force.y, 0);
      expect(force.x, greaterThan(0)); // toward +x (wall)
    });

    test('numerical stability near extremes', () {
      model.setTwoBalloons(true);
      model.yellowBalloon.charge = -57;
      model.greenBalloon.charge = -57;
      model.yellowBalloon.setPosition(const BaseVec2(540, 100));
      model.greenBalloon.setPosition(const BaseVec2(520, 150));
      model.releaseBalloon(model.yellowBalloon);
      model.releaseBalloon(model.greenBalloon);
      for (var i = 0; i < 300; i++) {
        model.step(1 / 60);
      }
      for (final b in model.balloons) {
        expect(b.position.x.isFinite, isTrue);
        expect(b.position.y.isFinite, isTrue);
        expect(b.velocity.x.isFinite, isTrue);
        expect(b.velocity.y.isFinite, isTrue);
        expect(b.velocity.magnitude, lessThan(1000));
      }
      for (final m in model.wall.minusCharges) {
        expect(m.position.x.isFinite, isTrue);
        expect(m.position.y.isFinite, isTrue);
      }
    });

    test('hidden green does not step / polarize', () {
      model.greenBalloon.charge = -40;
      model.greenBalloon.setPosition(const BaseVec2(500, 100));
      expect(model.greenBalloon.isVisible, isFalse);
      final before = model.wall.minusCharges.first.position;
      model.step(1 / 60);
      // Yellow neutral at start → wall unchanged by green (hidden).
      expect(model.wall.minusCharges.first.position, before);
    });

    test('layout constants', () {
      expect(BaseConstants.width, 768);
      expect(BaseConstants.height, 504);
      expect(BaseConstants.forceConstant, 0.05);
      expect(BaseConstants.wallAttractionFright, 0.003);
      expect(BaseConstants.maxForceMagnitude, 1e-2);
      expect(BaseConstants.coulombsLawConstant, 10000);
    });
  });

  group('Normal User Logic', () {
    test('continuous path: understand → rub → charge → wall → reset', () {
      final model = BalloonsStaticElectricityModel();

      // Cold start readable state.
      expect(model.yellowBalloon.isVisible, isTrue);
      expect(model.sweater.charge, 0);
      expect(model.wall.isVisible, isTrue);

      // Rub to charge.
      rubAcrossSweater(model, yellow: true);
      expect(model.yellowBalloon.charge, lessThan(0));
      expect(model.sweater.charge, greaterThan(0));

      // Approach wall.
      final b = model.yellowBalloon;
      model.dragBalloonTo(b, const BaseVec2(535, 110));
      model.releaseBalloon(b);
      var movedTowardWall = false;
      var prevX = b.position.x;
      for (var i = 0; i < 180; i++) {
        model.step(1 / 60);
        if (b.position.x > prevX + 1e-6) {
          movedTowardWall = true;
        }
        prevX = math.max(prevX, b.position.x);
      }
      expect(movedTowardWall || b.position.x >= 550, isTrue);

      // Second balloon explore.
      model.setTwoBalloons(true);
      expect(model.greenBalloon.isVisible, isTrue);

      model.reset();
      expect(model.yellowBalloon.charge, 0);
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.showCharges, ShowCharges.allCharges);
      expect(model.wall.isVisible, isTrue);
    });
  });
}
