import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloon_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';
import 'package:kratos/balloons_and_static_electricity/view/base_view_layout.dart';
import 'package:kratos/balloons_and_static_electricity/view/balloons_static_electricity_view.dart';

/// PHASE 4 — Visual QA golden matrix (V4-01 … V4-14).
///
/// Canonical 768×504, DPR 1, textScale 1.
/// Clock off (`autoStartClock: false`) for determinism; state set via Model APIs.
/// Goldens live under `goldens/` next to this file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const layout = Size(
    BaseViewLayout.layoutWidth,
    BaseViewLayout.layoutHeight,
  );

  Future<void> pumpPlayArea(
    WidgetTester tester,
    BalloonsStaticElectricityModel model,
  ) async {
    await tester.binding.setSurfaceSize(layout);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: layout.width,
            height: layout.height,
            child: MediaQuery(
              data: const MediaQueryData(
                size: layout,
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(1),
              ),
              child: BalloonsStaticElectricityPlayArea(
                model: model,
                autoStartClock: false,
                enableAudio: false,
              ),
            ),
          ),
        ),
      ),
    );
    // Allow Image.asset decode to settle.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> expectGolden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(BalloonsStaticElectricityPlayArea),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  /// Transfer exactly [n] sweater − into [balloon] (deterministic).
  void transferN(
    BalloonsStaticElectricityModel model,
    BalloonModel balloon,
    int n,
  ) {
    var count = 0;
    for (final m in model.sweater.minusCharges) {
      if (!m.moved && count < n) {
        model.sweater.moveChargeTo(m, balloon);
        count++;
      }
    }
  }

  /// Sync wall + notify view without free-flight physics.
  void sync(
    BalloonsStaticElectricityModel model, {
    BalloonModel? balloon,
    BaseVec2? position,
    bool keepDragging = false,
  }) {
    final b = balloon ?? model.yellowBalloon;
    final pos = position ?? b.position;
    model.dragBalloonTo(b, pos);
    model.wall.updateChargePositions();
    if (!keepDragging) {
      model.releaseBalloon(b);
    }
  }

  group('V4 golden matrix', () {
    late BalloonsStaticElectricityModel model;

    setUp(() {
      model = BalloonsStaticElectricityModel();
    });

    testWidgets('V4-01 balloons_initial', (tester) async {
      // Initial: yellow visible, green hidden, wall on, allCharges, q=0.
      await pumpPlayArea(tester, model);
      expect(model.yellowBalloon.isVisible, isTrue);
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.wall.isVisible, isTrue);
      expect(model.showCharges, ShowCharges.allCharges);
      expect(model.yellowBalloon.charge, 0);
      expect(model.sweater.charge, 0);
      await expectGolden(tester, 'balloons_initial');
    });

    testWidgets('V4-02 balloons_over_sweater', (tester) async {
      // Drag yellow onto sweater; leave userControlled (active drag).
      await pumpPlayArea(tester, model);
      sync(
        model,
        position: const BaseVec2(90, 80),
        keepDragging: true,
      );
      await tester.pump();
      expect(model.yellowBalloon.userControlled, isTrue);
      expect(model.yellowBalloon.onSweater, isTrue);
      await expectGolden(tester, 'balloons_over_sweater');
    });

    testWidgets('V4-03 balloons_charged', (tester) async {
      // Deterministic charge ≈ −8 via moveChargeTo (sweater + balloon visuals).
      transferN(model, model.yellowBalloon, 8);
      sync(model, position: const BaseVec2(280, 90));
      await pumpPlayArea(tester, model);
      expect(model.yellowBalloon.charge, -8);
      expect(model.sweater.charge, 8);
      await expectGolden(tester, 'balloons_charged');
    });

    testWidgets('V4-04 balloons_wall_polarization', (tester) async {
      transferN(model, model.yellowBalloon, 25);
      sync(model, position: const BaseVec2(520, 100));
      await pumpPlayArea(tester, model);
      final maxD = model.wall.minusCharges
          .map((c) => c.getDisplacement())
          .fold<double>(0, (a, b) => a > b ? a : b);
      expect(maxD, greaterThan(0.01));
      expect(model.wall.x, BaseConstants.wallX);
      await expectGolden(tester, 'balloons_wall_polarization');
    });

    testWidgets('V4-05 balloons_wall_contact', (tester) async {
      // Center X == AT_WALL → upperLeft.x = 554.
      transferN(model, model.yellowBalloon, 30);
      sync(model, position: const BaseVec2(554, 100));
      await pumpPlayArea(tester, model);
      expect(model.yellowBalloon.getCenterX(), BaseConstants.atWallCenterX);
      expect(model.yellowBalloon.computeTouchingWall(), isTrue);
      await expectGolden(tester, 'balloons_wall_contact');
    });

    testWidgets('V4-06 balloons_two_balloon', (tester) async {
      model.setTwoBalloons(true);
      sync(model);
      await pumpPlayArea(tester, model);
      expect(model.greenBalloon.isVisible, isTrue);
      await expectGolden(tester, 'balloons_two_balloon');
    });

    testWidgets('V4-07 balloons_no_charges', (tester) async {
      transferN(model, model.yellowBalloon, 12);
      sync(model, position: const BaseVec2(300, 100));
      model.setShowCharges(ShowCharges.noCharges);
      await pumpPlayArea(tester, model);
      expect(model.yellowBalloon.charge, -12);
      expect(model.showCharges, ShowCharges.noCharges);
      await expectGolden(tester, 'balloons_no_charges');
    });

    testWidgets('V4-08 balloons_charge_differences', (tester) async {
      transferN(model, model.yellowBalloon, 15);
      sync(model, position: const BaseVec2(300, 100));
      model.setShowCharges(ShowCharges.chargeDifferences);
      await pumpPlayArea(tester, model);
      expect(model.showCharges, ShowCharges.chargeDifferences);
      await expectGolden(tester, 'balloons_charge_differences');
    });

    testWidgets('V4-09 balloons_wall_removed', (tester) async {
      model.removeWall();
      sync(model);
      await pumpPlayArea(tester, model);
      expect(model.wall.isVisible, isFalse);
      expect(model.playAreaMaxX, BaseConstants.width);
      await expectGolden(tester, 'balloons_wall_removed');
    });

    testWidgets('V4-10 balloons_reset_all', (tester) async {
      // Complex state then Reset All → canonical initial.
      model.setTwoBalloons(true);
      transferN(model, model.yellowBalloon, 20);
      transferN(model, model.greenBalloon, 10);
      sync(model, position: const BaseVec2(500, 80));
      sync(
        model,
        balloon: model.greenBalloon,
        position: const BaseVec2(200, 140),
      );
      model.setShowCharges(ShowCharges.chargeDifferences);
      model.removeWall();
      model.reset();
      await pumpPlayArea(tester, model);
      expect(model.showCharges, ShowCharges.allCharges);
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.wall.isVisible, isTrue);
      expect(model.yellowBalloon.charge, 0);
      expect(model.sweater.charge, 0);
      expect(
        model.yellowBalloon.position,
        BaseConstants.yellowInitialPosition,
      );
      await expectGolden(tester, 'balloons_reset_all');
    });

    testWidgets('V4-11 balloons_charged_sweater', (tester) async {
      // Emphasize sweater leftover + after substantial rub.
      transferN(model, model.yellowBalloon, 20);
      sync(model, position: const BaseVec2(260, 90));
      await pumpPlayArea(tester, model);
      expect(model.sweater.charge, 20);
      await expectGolden(tester, 'balloons_charged_sweater');
    });

    testWidgets('V4-12 balloons_two_charged_repelling', (tester) async {
      model.setTwoBalloons(true);
      transferN(model, model.yellowBalloon, 20);
      transferN(model, model.greenBalloon, 20);
      // Place near each other, released (repulsion state, no free step).
      sync(model, position: const BaseVec2(420, 90));
      sync(
        model,
        balloon: model.greenBalloon,
        position: const BaseVec2(360, 120),
      );
      await pumpPlayArea(tester, model);
      expect(model.yellowBalloon.charge, -20);
      expect(model.greenBalloon.charge, -20);
      await expectGolden(tester, 'balloons_two_charged_repelling');
    });

    testWidgets('V4-13 balloons_yellow_green_different', (tester) async {
      model.setTwoBalloons(true);
      transferN(model, model.yellowBalloon, 12);
      // Green stays neutral; yellow near wall → polarization from yellow only.
      sync(model, position: const BaseVec2(510, 80));
      sync(
        model,
        balloon: model.greenBalloon,
        position: const BaseVec2(200, 150),
      );
      await pumpPlayArea(tester, model);
      expect(model.yellowBalloon.charge, -12);
      expect(model.greenBalloon.charge, 0);
      await expectGolden(tester, 'balloons_yellow_green_different');
    });

    testWidgets('V4-14 balloons_reset_balloon', (tester) async {
      // Reset Balloon(s) with green visible + showCharges preserved.
      model.setTwoBalloons(true);
      model.setShowCharges(ShowCharges.chargeDifferences);
      transferN(model, model.yellowBalloon, 10);
      transferN(model, model.greenBalloon, 6);
      sync(model, position: const BaseVec2(480, 70));
      sync(
        model,
        balloon: model.greenBalloon,
        position: const BaseVec2(220, 160),
      );
      model.resetBalloons();
      await pumpPlayArea(tester, model);
      expect(model.greenBalloon.isVisible, isTrue);
      expect(model.showCharges, ShowCharges.chargeDifferences);
      expect(model.wall.isVisible, isTrue);
      expect(model.yellowBalloon.charge, 0);
      expect(model.greenBalloon.charge, 0);
      expect(model.sweater.charge, 0);
      expect(
        model.yellowBalloon.position,
        BaseConstants.yellowInitialPosition,
      );
      expect(
        model.greenBalloon.position,
        BaseConstants.greenInitialPosition,
      );
      await expectGolden(tester, 'balloons_reset_balloon');
    });
  });
}
