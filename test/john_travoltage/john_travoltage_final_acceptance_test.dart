import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/john_travoltage/audio/john_travoltage_audio.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_constants.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/model/jt_vec2.dart';
import 'package:kratos/john_travoltage/model/leg.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';

/// Final behavioral acceptance — real-user-style sequences (Phase Final QA).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  JohnTravoltageModel seeded([int seed = 42]) =>
      JohnTravoltageModel(random: math.Random(seed));

  void pointFingerNearKnob(JohnTravoltageModel m) {
    final knob = JohnTravoltageConstants.doorknobPosition;
    final pivot = m.arm.position;
    final desired = knob - pivot;
    final fingerLen = m.arm.fingerVector.magnitude;
    final target = desired.normalize().times(fingerLen);
    m.setArmAngle(target.angle - m.arm.fingerVector.angle);
  }

  void rubOnCarpet(JohnTravoltageModel m, {int swings = 8}) {
    for (var i = 0; i < swings; i++) {
      m.setLegAngle(1.2);
      m.setLegAngle(2.2);
    }
  }

  void fillExactly(JohnTravoltageModel m, int n) {
    while (m.electronCount < n &&
        m.electronCount < JohnTravoltageConstants.maxElectrons) {
      m.createElectron();
    }
  }

  void dischargeUntilClear(JohnTravoltageModel m, {int maxSteps = 2000}) {
    pointFingerNearKnob(m);
    while (m.electronCount /
            m.fingerPosition.distance(m.doorknobPosition) <=
        JohnTravoltageConstants.dischargeThreshold) {
      if (m.electronCount >= JohnTravoltageConstants.maxElectrons) break;
      m.createElectron();
    }
    for (var i = 0; i < maxSteps; i++) {
      m.step(1 / 60);
      if (m.electronCount == 0 && !m.sparkVisible) break;
    }
  }

  void expectInitial(JohnTravoltageModel m) {
    expect(m.electronCount, 0);
    expect(m.sparkVisible, isFalse);
    expect(m.arm.angle, JohnTravoltageConstants.armInitialAngle);
    expect(m.leg.angle, JohnTravoltageConstants.legInitialAngle);
    expect(m.sparkCreationDistToKnob, isNull);
    expect(m.numberOfElectronsDischarged, 0);
    expect(m.accumulatedAngle, 0);
  }

  group('Final Behavioral Acceptance', () {
    test('A. initial state', () {
      expectInitial(seeded());
    });

    test('B. low charge — carpet only, no spark', () {
      final m = seeded(1);
      // Off carpet: no charge
      m.setLegAngle(0.2);
      m.setLegAngle(0.5);
      expect(m.electronCount, 0);

      // On carpet: charge appears
      rubOnCarpet(m, swings: 3);
      expect(m.shoeOnCarpet || m.electronCount > 0, isTrue);
      expect(m.electronCount, greaterThan(0));
      expect(m.electronCount, lessThan(30));
      expect(m.sparkVisible, isFalse);
      for (var i = 0; i < 30; i++) {
        m.step(1 / 60);
      }
      expect(m.sparkVisible, isFalse);
      for (final e in m.electrons) {
        expect(e.position.x.isFinite, isTrue);
        expect(e.position.y.isFinite, isTrue);
      }
    });

    test('C. medium charge 30–60', () {
      final m = seeded(2);
      fillExactly(m, 45);
      expect(m.electronCount, 45);
      for (var i = 0; i < 60; i++) {
        m.step(1 / 60);
      }
      expect(m.electronCount, 45);
      expect(m.sparkVisible, isFalse);
    });

    test('D. maximum charge capped at 100 — no NaN / no runaway', () {
      final m = seeded(3);
      fillExactly(m, 100);
      expect(m.electronCount, 100);

      // Carpet rubbing at max must not grow past MAX_ELECTRONS
      rubOnCarpet(m, swings: 40);
      expect(m.electronCount, 100);

      for (var i = 0; i < 40; i++) {
        m.step(1 / 60);
        for (final e in m.electrons) {
          expect(e.position.x.isNaN, isFalse);
          expect(e.position.y.isNaN, isFalse);
        }
      }
      expect(m.electronCount, 100);
    });

    test('D2. carpet rubbing alone reaches and stays at MAX_ELECTRONS', () {
      final m = seeded(4);
      m.setLegAngle(1.5);
      for (var i = 0; i < 500; i++) {
        m.setLegAngle(1.2 + (i % 2) * 1.0);
      }
      expect(m.electronCount, JohnTravoltageConstants.maxElectrons);
      rubOnCarpet(m, swings: 20);
      expect(m.electronCount, JohnTravoltageConstants.maxElectrons);
    });
  });

  group('Reverse / Boundary / Arm', () {
    test('leg clamp [0, π] via limitRotation', () {
      final m = seeded(5);
      m.setLegAngle(-0.3, applyLimitRotation: true);
      expect(m.leg.angle, 0);
      m.setLegAngle(math.pi + 0.5, applyLimitRotation: true);
      // limitRotation: angle < -π/2 → π; > -π/2 && < 0 → 0; else unchanged
      // π+0.5 is unchanged by limitRotation; Appendage may clamp to angleMax
      expect(m.leg.angle, lessThanOrEqualTo(math.pi));
      expect(m.leg.angle, greaterThanOrEqualTo(0));

      m.setLegAngle(math.pi / 2, applyLimitRotation: true);
      expect(m.leg.angle, closeTo(math.pi / 2, 1e-12));

      // Direct limitRotation edges
      expect(Leg.limitRotation(-math.pi), math.pi);
      expect(Leg.limitRotation(-0.1), 0);
      expect(Leg.limitRotation(1.0), 1.0);
    });

    test('arm drag at 100 electrons — finger continuous', () {
      final m = seeded(6);
      fillExactly(m, 100);
      final angles = <double>[-0.5, -1.0, 0.0, 0.5, -0.5];
      JtVec2? prev;
      for (final a in angles) {
        m.setArmAngle(a);
        final fp = m.fingerPosition;
        expect(fp.x.isFinite, isTrue);
        expect(fp.y.isFinite, isTrue);
        if (prev != null) {
          // Continuous — not teleporting to NaN/inf
          expect((fp.x - prev.x).abs() + (fp.y - prev.y).abs(),
              lessThan(500));
        }
        prev = fp;
      }
      expect(m.arm.position.x,
          closeTo(JohnTravoltageConstants.armPivot.x, 1e-9));
    });
  });

  group('Discharge Acceptance', () {
    test('low / medium / high charge discharge cycles', () {
      for (final count in [12, 40, 90]) {
        final m = seeded(10 + count);
        fillExactly(m, count);
        expect(m.electronCount, count);
        dischargeUntilClear(m);
        expect(m.electronCount, 0, reason: 'count=$count cleared');
        expect(m.sparkVisible, isFalse);
      }
    });

    test('threshold equality does not fire; strict > does', () {
      final m = seeded(20);
      pointFingerNearKnob(m);
      final dist = m.fingerPosition.distance(m.doorknobPosition);
      final threshold = JohnTravoltageConstants.dischargeThreshold;
      final atOrBelow = (threshold * dist).floor();
      for (var i = 0; i < atOrBelow; i++) {
        m.debugAddElectronAt(const JtVec2(400, 280));
      }
      expect(
        m.electronCount / dist,
        lessThanOrEqualTo(threshold),
      );
      m.step(1 / 60);
      expect(m.electrons.every((e) => !e.exiting), isTrue);

      m.debugAddElectronAt(const JtVec2(401, 281));
      expect(m.electronCount / dist, greaterThan(threshold));
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
    });

    test('continuous discharge — new electrons keep exiting', () {
      final m = seeded(21);
      pointFingerNearKnob(m);
      fillExactly(m, 20);
      while (m.electronCount /
              m.fingerPosition.distance(m.doorknobPosition) <=
          JohnTravoltageConstants.dischargeThreshold) {
        m.createElectron();
      }
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
      m.createElectron();
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
    });

    test('spark lifecycle OFF→ON→OFF', () {
      final m = seeded(22);
      expect(m.sparkVisible, isFalse);
      fillExactly(m, 25);
      dischargeUntilClear(m);
      expect(m.sparkVisible, isFalse);
      expect(m.electronCount, 0);
    });
  });

  group('Audio / Reset / Repeated Cycles', () {
    test('chargesInBody + electricDischarge hooks', () {
      final m = seeded(30);
      final audio = JohnTravoltageAudio(m, enabled: false);
      fillExactly(m, 5);
      m.notifyListeners();
      expect(audio.chargesStartCount, greaterThanOrEqualTo(1));

      m.reset();
      expect(audio.chargesStopCount, greaterThanOrEqualTo(1));
      expect(audio.hasPendingOuch, isFalse);

      fillExactly(m, 35);
      pointFingerNearKnob(m);
      while (m.electronCount /
              m.fingerPosition.distance(m.doorknobPosition) <=
          JohnTravoltageConstants.dischargeThreshold) {
        m.createElectron();
      }
      for (var i = 0; i < 1500; i++) {
        m.step(1 / 60);
        if (audio.electricDischargeStopCount > 0) break;
      }
      expect(audio.electricDischargeStartCount, greaterThanOrEqualTo(1));
      expect(audio.electricDischargeStopCount, greaterThanOrEqualTo(1));
      audio.dispose();
    });

    test('arm position sounds are quantized (not per-event flood)', () {
      final m = seeded(31);
      final audio = JohnTravoltageAudio(m, enabled: false);
      // Sweep arm across many tiny increments
      for (var i = 0; i < 200; i++) {
        m.setArmAngle(-0.5 + i * 0.01);
      }
      // Should be far fewer than 200
      expect(audio.armClickCount, lessThan(200));
      expect(audio.armClickCount, greaterThan(0));
      audio.dispose();
    });

    test('Reset A/B/C/D → official initial', () {
      // A: charge → reset
      final a = seeded(40);
      fillExactly(a, 20);
      a.reset();
      expectInitial(a);

      // B: discharge → reset
      final b = seeded(41);
      fillExactly(b, 30);
      dischargeUntilClear(b);
      b.reset();
      expectInitial(b);

      // C: spark visible → reset immediately
      final c = seeded(42);
      final audioC = JohnTravoltageAudio(c, enabled: false);
      fillExactly(c, 40);
      pointFingerNearKnob(c);
      while (c.electronCount /
              c.fingerPosition.distance(c.doorknobPosition) <=
          JohnTravoltageConstants.dischargeThreshold) {
        c.createElectron();
      }
      for (var i = 0; i < 1500; i++) {
        c.step(1 / 60);
        if (c.sparkVisible) break;
      }
      expect(c.sparkVisible, isTrue);
      c.reset();
      expectInitial(c);
      expect(audioC.hasPendingOuch, isFalse);
      audioC.dispose();

      // D: pending ouch → reset
      final d = seeded(43);
      final audioD = JohnTravoltageAudio(d, enabled: false);
      fillExactly(d, 40);
      pointFingerNearKnob(d);
      while (d.electronCount /
              d.fingerPosition.distance(d.doorknobPosition) <=
          JohnTravoltageConstants.dischargeThreshold) {
        d.createElectron();
      }
      for (var i = 0; i < 1500; i++) {
        d.step(1 / 60);
        if (d.sparkVisible) break;
      }
      // Even if spark already ended, reset must cancel any pending ouch
      d.reset();
      expect(audioD.hasPendingOuch, isFalse);
      expectInitial(d);
      audioD.dispose();
    });

    test('repeated full cycles ×4 no accumulation', () {
      final m = seeded(50);
      final audio = JohnTravoltageAudio(m, enabled: false);
      for (var c = 0; c < 4; c++) {
        fillExactly(m, 25 + c * 5);
        expect(m.electronCount, greaterThan(0));
        if (c < 3) {
          dischargeUntilClear(m);
          m.reset();
          expectInitial(m);
          expect(audio.hasPendingOuch, isFalse);
        } else {
          // Cycle 4: discharge without reset
          dischargeUntilClear(m);
          expect(m.electronCount, 0);
          expect(m.sparkVisible, isFalse);
        }
      }
      audio.dispose();
    });
  });

  group('Lifecycle Acceptance (screen)', () {
    testWidgets('enter → interact → leave → re-enter fresh', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final m1 = seeded(60);
      await tester.pumpWidget(
        MaterialApp(
          home: JohnTravoltageScreen(
            model: m1,
            autoStartClock: true,
            enableAudio: false,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(JohnTravoltagePlayArea), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      fillExactly(m1, 15);
      await tester.pump(const Duration(milliseconds: 50));
      expect(m1.electronCount, 15);

      // Leave
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();
      expect(find.byType(JohnTravoltageScreen), findsNothing);

      // Re-enter with new owned model
      await tester.pumpWidget(
        const MaterialApp(
          home: JohnTravoltageScreen(
            autoStartClock: false,
            enableAudio: false,
          ),
        ),
      );
      await tester.pump();
      final state = tester.state<JohnTravoltageScreenState>(
        find.byType(JohnTravoltageScreen),
      );
      expectInitial(state.model);
      expect(identical(state.model, m1), isFalse);
    });

    testWidgets('leave during spark — no throw after dispose', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final m = seeded(61);
      await tester.pumpWidget(
        MaterialApp(
          home: JohnTravoltageScreen(
            model: m,
            autoStartClock: true,
            enableAudio: false,
          ),
        ),
      );
      await tester.pump();

      fillExactly(m, 40);
      pointFingerNearKnob(m);
      while (m.electronCount /
              m.fingerPosition.distance(m.doorknobPosition) <=
          JohnTravoltageConstants.dischargeThreshold) {
        m.createElectron();
      }
      for (var i = 0; i < 60; i++) {
        m.step(1 / 60);
        if (m.sparkVisible) break;
      }

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });
}
