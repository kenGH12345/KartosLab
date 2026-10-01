import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/audio/base_audio.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';
import 'package:kratos/balloons_and_static_electricity/view/balloons_static_electricity_view.dart';

/// PHASE 3 behavioral / runtime / audio regression suite (R3-01 … R3-20).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BalloonsStaticElectricityModel model;

  setUp(() {
    model = BalloonsStaticElectricityModel();
  });

  void rubOneMinus() {
    final b = model.yellowBalloon;
    // Transfer exactly one charge via Model API (spatial sweep tested elsewhere).
    final target =
        model.sweater.minusCharges.firstWhere((c) => !c.moved);
    model.sweater.moveChargeTo(target, b);
  }

  void rubOneMinusBySweep() {
    final b = model.yellowBalloon;
    final target =
        model.sweater.minusCharges.firstWhere((c) => !c.moved);
    // Tiny balloon placement: only cover this charge by aligning upper-left
    // so bounds barely includes the point and exclude neighbors when possible.
    final place = BaseVec2(
      target.position.x - 2,
      target.position.y - 2,
    );
    model.dragBalloonTo(b, place);
    b.oldPosition = b.position.copy();
    model.dragBalloonTo(b, BaseVec2(place.x + 1, place.y + 1));
    b.step(1 / 60);
  }

  group('R3 behavioral regression', () {
    test('R3-01 single balloon drag continuous', () {
      final b = model.yellowBalloon;
      final start = b.position;
      model.dragBalloonTo(b, BaseVec2(start.x + 10, start.y + 5));
      expect(b.userControlled, isTrue);
      expect(b.position.x, start.x + 10);
      model.dragBalloonTo(b, BaseVec2(start.x + 25, start.y + 12));
      expect(b.position.x, start.x + 25);
      expect(b.position.y, start.y + 12);
    });

    test('R3-02 / R3-03 rub sweater transfers charge (sweep)', () {
      expect(model.yellowBalloon.charge, 0);
      rubOneMinusBySweep();
      expect(model.yellowBalloon.charge, lessThan(0));
      expect(model.sweater.charge, greaterThan(0));
    });

    test('R3-02b single moveChargeTo transfers exactly one', () {
      rubOneMinus();
      expect(model.yellowBalloon.charge, -1);
      expect(model.sweater.charge, 1);
    });

    test('R3-04 repeat same charge does not duplicate', () {
      rubOneMinus();
      expect(model.yellowBalloon.charge, -1);
      final moved = model.sweater.minusCharges.where((m) => m.moved).single;

      // Sweater charge always equals number of moved flags.
      expect(
        model.sweater.charge,
        model.sweater.minusCharges.where((m) => m.moved).length,
      );

      // Covering the already-moved charge cannot increase sweater.charge via
      // that slot again — only unmoved slots transfer.
      final b = model.yellowBalloon;
      b.bounds; // ensure bounds exist
      // Place far from sweater so no additional transfers.
      model.dragBalloonTo(b, const BaseVec2(500, 100));
      b.oldPosition = b.position.copy();
      model.dragBalloonTo(b, const BaseVec2(502, 100));
      b.step(1 / 60);
      expect(model.yellowBalloon.charge, -1);
      expect(moved.moved, isTrue);

      // Capacity path: transfer all remaining, then no more.
      for (final m in model.sweater.minusCharges) {
        if (!m.moved) model.sweater.moveChargeTo(m, b);
      }
      expect(model.sweater.checkAndTransferCharges(b), isFalse);
      expect(model.sweater.charge, 57);
    });

    test('R3-05 charge reaches max 57', () {
      final b = model.yellowBalloon;
      for (final m in model.sweater.minusCharges) {
        model.sweater.moveChargeTo(m, b);
      }
      expect(b.charge, -57);
      expect(model.sweater.charge, 57);
      expect(model.sweater.checkAndTransferCharges(b), isFalse);
    });

    test('R3-06 wall polarization displaces minus', () {
      model.yellowBalloon.charge = -25;
      model.yellowBalloon.setPosition(const BaseVec2(520, 100));
      model.wall.updateChargePositions();
      final maxD = model.wall.minusCharges
          .map((c) => c.getDisplacement())
          .fold<double>(0, (a, b) => a > b ? a : b);
      expect(maxD, greaterThan(0.01));
      // Wall itself stays fixed.
      expect(model.wall.x, 688);
    });

    test('R3-07 wall special attraction when charge < -5 and near', () {
      final b = model.yellowBalloon;
      b.charge = -20;
      b.setPosition(const BaseVec2(530, 120));
      model.releaseBalloon(b);
      final f = b.getTotalForce();
      expect(f.x, greaterThan(0));
      expect(f.y, 0);
      b.charge = -5;
      final fEdge = b.getTotalForce();
      // charge < -5 required; -5 does not take special branch.
      expect(fEdge.x == 0 || fEdge.magnitude <= BaseConstants.maxForceMagnitude,
          isTrue);
    });

    test('R3-08 wall release / contact touchingWall', () {
      final b = model.yellowBalloon;
      b.charge = -30;
      // Place so center X == AT_WALL (621) → upperLeft.x = 621 - 67 = 554.
      b.setPosition(const BaseVec2(554, 100));
      expect(b.getCenterX(), BaseConstants.atWallCenterX);
      expect(b.computeTouchingWall(), isTrue);
      model.removeWall();
      expect(b.computeTouchingWall(), isFalse);
    });

    test('R3-09 two balloon switching preserves yellow charge', () {
      model.yellowBalloon.charge = -9;
      model.setTwoBalloons(true);
      expect(model.greenBalloon.isVisible, isTrue);
      expect(model.yellowBalloon.charge, -9);
      model.setTwoBalloons(false);
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.yellowBalloon.charge, -9);
    });

    test('R3-10 two balloon repulsion', () {
      model.setTwoBalloons(true);
      model.yellowBalloon.charge = -20;
      model.greenBalloon.charge = -20;
      model.yellowBalloon.setPosition(const BaseVec2(400, 100));
      model.greenBalloon.setPosition(const BaseVec2(430, 100));
      model.releaseBalloon(model.yellowBalloon);
      model.releaseBalloon(model.greenBalloon);
      final d0 = model.yellowBalloon
          .getCenter()
          .distance(model.greenBalloon.getCenter());
      for (var i = 0; i < 90; i++) {
        model.step(1 / 60);
      }
      final d1 = model.yellowBalloon
          .getCenter()
          .distance(model.greenBalloon.getCenter());
      expect(d1, greaterThan(d0));
    });

    test('R3-11 charge display switching does not alter physics', () {
      model.yellowBalloon.charge = -11;
      final pos = model.yellowBalloon.position;
      model.setShowCharges(ShowCharges.noCharges);
      model.setShowCharges(ShowCharges.chargeDifferences);
      model.setShowCharges(ShowCharges.allCharges);
      expect(model.yellowBalloon.charge, -11);
      expect(model.yellowBalloon.position, pos);
    });

    test('R3-12 Reset Balloon(s) preserves visibility / showCharges / wall',
        () {
      model.setTwoBalloons(true);
      model.setShowCharges(ShowCharges.chargeDifferences);
      model.removeWall();
      model.yellowBalloon.charge = -4;
      model.resetBalloons();
      expect(model.greenBalloon.isVisible, isTrue);
      expect(model.showCharges, ShowCharges.chargeDifferences);
      expect(model.wall.isVisible, isFalse);
      expect(model.yellowBalloon.charge, 0);
    });

    test('R3-13 Reset All restores initial product state', () {
      model.setTwoBalloons(true);
      model.setShowCharges(ShowCharges.noCharges);
      model.removeWall();
      model.yellowBalloon.charge = -12;
      model.greenBalloon.charge = -8;
      model.reset();
      expect(model.showCharges, ShowCharges.allCharges);
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.wall.isVisible, isTrue);
      expect(model.yellowBalloon.charge, 0);
      expect(model.sweater.charge, 0);
      for (final m in model.wall.minusCharges) {
        expect(m.position, m.initialPosition);
      }
    });

    test('R3-14 reset during drag clears userControlled', () {
      model.dragBalloonTo(model.yellowBalloon, const BaseVec2(200, 80));
      expect(model.yellowBalloon.userControlled, isTrue);
      model.reset();
      expect(model.yellowBalloon.userControlled, isFalse);
      expect(
        model.yellowBalloon.position,
        BaseConstants.yellowInitialPosition,
      );
    });

    test('R3-15 reset after wall interaction', () {
      model.yellowBalloon.charge = -30;
      model.yellowBalloon.setPosition(const BaseVec2(520, 100));
      model.wall.updateChargePositions();
      model.reset();
      expect(model.wall.isVisible, isTrue);
      expect(
        model.wall.minusCharges.every((c) => c.getDisplacement() < 1e-9),
        isTrue,
      );
    });

    test('R3-16 rapid repeated interaction stays finite', () {
      final b = model.yellowBalloon;
      for (var i = 0; i < 40; i++) {
        model.dragBalloonTo(b, BaseVec2(100.0 + i, 80.0 + (i % 5)));
        b.step(1 / 60);
      }
      model.releaseBalloon(b);
      for (var i = 0; i < 60; i++) {
        model.step(1 / 60);
      }
      expect(b.position.x.isFinite, isTrue);
      expect(b.velocity.x.isFinite, isTrue);
    });

    test('R3-17 / R3-18 Ticker dt stability large gap', () {
      // Model clamps dt_ms > 500 internally when stepping with seconds*1000.
      model.yellowBalloon.charge = -10;
      model.releaseBalloon(model.yellowBalloon);
      model.step(2.0); // huge gap → internal clamp path
      expect(model.yellowBalloon.position.x.isFinite, isTrue);
      expect(model.yellowBalloon.velocity.magnitude.isFinite, isTrue);
      model.step(1 / 60);
      expect(model.yellowBalloon.position.x.isNaN, isFalse);
    });

    test('R3-19 audio lifecycle hooks (enabled=false counters)', () {
      final audio = BaseAudio(model, enabled: false);
      expect(audio.grabCount, 0);
      model.dragBalloonTo(model.yellowBalloon, const BaseVec2(210, 90));
      expect(audio.grabCount, 1);
      model.releaseBalloon(model.yellowBalloon);
      expect(audio.releaseCount, 1);

      final beforePop = audio.chargePopCount;
      rubOneMinusBySweep();
      expect(audio.chargePopCount, greaterThan(beforePop));

      audio.onReset();
      expect(audio.resetStopCount, 1);
      audio.dispose();
    });

    testWidgets('R3-20 accessibility semantics + lifecycle pause/resume',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BalloonsStaticElectricityPlayArea(
                model: model,
                autoStartClock: true,
                enableAudio: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('Yellow Balloon'), findsWidgets);
      expect(find.bySemanticsLabel('Sweater'), findsWidgets);
      expect(find.bySemanticsLabel('Wall'), findsWidgets);

      final state = tester.state<BalloonsStaticElectricityPlayAreaState>(
        find.byType(BalloonsStaticElectricityPlayArea),
      );
      expect(state.tickerActive, isTrue);
      state.pauseClock();
      expect(state.tickerActive, isFalse);
      state.resumeClock();
      expect(state.tickerActive, isTrue);
      expect(state.audio, isNotNull);

      // Dispose path: pump new tree.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('Friction edge cases (product UX)', () {
    test('Case A: drag without sweeping charge → no transfer', () {
      model.dragBalloonTo(model.yellowBalloon, const BaseVec2(500, 100));
      model.yellowBalloon.oldPosition =
          model.yellowBalloon.position.copy();
      model.dragBalloonTo(
        model.yellowBalloon,
        const BaseVec2(505, 105),
      );
      model.yellowBalloon.step(1 / 60);
      expect(model.yellowBalloon.charge, 0);
    });

    test('Case D: stationary overlap does not charge', () {
      final target = model.sweater.minusCharges.first;
      final place = BaseVec2(target.position.x - 20, target.position.y - 20);
      model.dragBalloonTo(model.yellowBalloon, place);
      // speed == 0 path: step without moving oldPosition sync after drag sets
      // oldPosition equal at end of previous step — call step with no move.
      model.yellowBalloon.oldPosition =
          model.yellowBalloon.position.copy();
      model.yellowBalloon.step(1 / 60);
      expect(model.yellowBalloon.charge, 0);
    });

    test('Case E: overlap alone without motion does not charge', () {
      final target = model.sweater.minusCharges.first;
      // Place covering charge but never call step with motion.
      model.dragBalloonTo(
        model.yellowBalloon,
        BaseVec2(target.position.x - 10, target.position.y - 10),
      );
      expect(model.yellowBalloon.charge, 0);
    });
  });

  group('Pointer offset / product drag', () {
    test('drag delta does not snap upper-left to pointer-as-center', () {
      final start = model.yellowBalloon.position;
      model.dragBalloonTo(
        model.yellowBalloon,
        BaseVec2(start.x + 15, start.y + 8),
      );
      // Center moved by same delta — offset preserved relative to grab.
      expect(
        model.yellowBalloon.getCenter().x - (start.x + 67),
        closeTo(15, 0.01),
      );
    });
  });
}
