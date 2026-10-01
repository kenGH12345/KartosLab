import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/john_travoltage/audio/john_travoltage_audio.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_constants.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/model/jt_vec2.dart';
import 'package:kratos/john_travoltage/view/jt_view_geometry.dart';
import 'package:kratos/john_travoltage/view/jt_view_layout.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JohnTravoltage Phase 4 — Discharge / Spark / Audio', () {
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

    void addElectronsAboveThreshold(JohnTravoltageModel m) {
      final dist = m.fingerPosition.distance(m.doorknobPosition);
      final needed =
          (JohnTravoltageConstants.dischargeThreshold * dist).floor() + 1;
      for (var i = 0; i < needed; i++) {
        m.debugAddElectronAt(
          JtVec2(400 + (i % 5).toDouble(), 280 + (i % 3).toDouble()),
        );
      }
    }

    double query(JohnTravoltageModel m) =>
        m.electronCount / m.fingerPosition.distance(m.doorknobPosition);

    test('A. no charge near knob → no discharge', () {
      final m = seeded();
      pointFingerNearKnob(m);
      expect(m.electronCount, 0);
      m.step(1 / 60);
      expect(m.electrons.every((e) => !e.exiting), isTrue);
      expect(m.sparkVisible, isFalse);
    });

    test('B–D. threshold uses strict > 10/15', () {
      final m = seeded();
      pointFingerNearKnob(m);
      final dist = m.fingerPosition.distance(m.doorknobPosition);
      final threshold = JohnTravoltageConstants.dischargeThreshold;

      // Below: count such that query == threshold exactly is impossible with int;
      // use count so query <= threshold
      final atOrBelow = (threshold * dist).floor();
      for (var i = 0; i < atOrBelow; i++) {
        m.debugAddElectronAt(const JtVec2(400, 280));
      }
      expect(query(m), lessThanOrEqualTo(threshold));
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isFalse);

      // Above
      m.debugAddElectronAt(const JtVec2(401, 281));
      expect(query(m), greaterThan(threshold));
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
    });

    test('C. high charge near knob → discharge', () {
      final m = seeded(3);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);
      var started = 0;
      var ended = 0;
      m.addDischargeStartedListener(() => started++);
      m.addDischargeEndedListener(() => ended++);

      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (ended > 0 && m.electronCount == 0) break;
      }
      expect(started, greaterThanOrEqualTo(1));
      expect(ended, greaterThanOrEqualTo(1));
      expect(m.sparkVisible, isFalse);
      expect(m.numberOfElectronsDischarged, greaterThan(0));
    });

    test('E. continuous discharge while threshold holds', () {
      final m = seeded(5);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
      m.debugAddElectronAt(const JtVec2(402, 282));
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
    });

    test('F–G. spark lifecycle finger→knob', () {
      final m = seeded(7);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);

      var sawSpark = false;
      List<JtVec2> points = const [];
      for (var i = 0; i < 200; i++) {
        m.step(1 / 60);
        if (m.sparkVisible) {
          sawSpark = true;
          points = SparkPathBuilder.build(
            finger: m.fingerPosition,
            knob: m.doorknobPosition,
            random: math.Random(1),
            numSegments: JtViewLayout.sparkSegmentCount,
          );
          expect(points.first.x, closeTo(m.fingerPosition.x, 1e-9));
          expect(points.last.x, closeTo(m.doorknobPosition.x, 1e-9));
          expect(points.length, JtViewLayout.sparkSegmentCount + 1);
          break;
        }
      }
      expect(sawSpark, isTrue);

      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (!m.sparkVisible && m.electronCount == 0) break;
      }
      expect(m.sparkVisible, isFalse);
    });

    test('H. electron exit along force lines then remove', () {
      final m = seeded(8);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);
      m.step(1 / 60);
      expect(m.electrons.any((e) => e.exiting), isTrue);
      expect(m.forceLines, hasLength(12));
      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (m.electronCount == 0) break;
      }
      expect(m.electronCount, 0);
      expect(m.sparkVisible, isFalse);
    });

    test('I. repeated discharge 3 cycles', () {
      final m = seeded(11);
      for (var c = 0; c < 3; c++) {
        // Charge via foot
        m.setLegAngle(1.2);
        m.setLegAngle(2.2);
        m.setLegAngle(1.3);
        m.setLegAngle(2.1);
        expect(m.electronCount, greaterThan(0), reason: 'cycle $c charge');

        pointFingerNearKnob(m);
        // Ensure threshold
        while (query(m) <= JohnTravoltageConstants.dischargeThreshold) {
          m.debugAddElectronAt(const JtVec2(405, 285));
        }
        for (var i = 0; i < 1200; i++) {
          m.step(1 / 60);
          if (m.electronCount == 0) break;
        }
        expect(m.electronCount, 0, reason: 'cycle $c cleared');
        expect(m.sparkVisible, isFalse);
      }
    });

    test('J. reset during spark cancels discharge state', () {
      final m = seeded(13);
      final audio = JohnTravoltageAudio(m, enabled: false);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);

      for (var i = 0; i < 80; i++) {
        m.step(1 / 60);
        if (m.sparkVisible) break;
      }
      expect(m.sparkVisible, isTrue);
      expect(audio.electricDischargeStartCount, greaterThanOrEqualTo(1));
      expect(audio.hasPendingOuch || audio.ouchScheduledCount > 0 ||
          audio.gazouchScheduledCount > 0 ||
          m.electronCount <= 30, isTrue);

      m.reset();
      expect(m.sparkVisible, isFalse);
      expect(m.electronCount, 0);
      expect(audio.hasPendingOuch, isFalse);

      // Can discharge again
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);
      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (m.electronCount == 0) break;
      }
      expect(m.electronCount, 0);
      audio.dispose();
    });

    test('K. reset after discharge restores idle', () {
      final m = seeded(15);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);
      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (m.electronCount == 0) break;
      }
      m.reset();
      expect(m.arm.angle, JohnTravoltageConstants.armInitialAngle);
      expect(m.leg.angle, JohnTravoltageConstants.legInitialAngle);
      expect(m.numberOfElectronsDischarged, 0);
      expect(m.sparkCreationDistToKnob, isNull);
    });

    test('L–M. audio start/stop on discharge lifecycle', () {
      final m = seeded(17);
      final audio = JohnTravoltageAudio(m, enabled: false);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);

      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (audio.electricDischargeStopCount > 0) break;
      }
      expect(audio.electricDischargeStartCount, greaterThanOrEqualTo(1));
      expect(audio.electricDischargeStopCount, greaterThanOrEqualTo(1));
      audio.dispose();
    });

    test('N. delayed ouch cancelled on reset', () {
      final m = seeded(19);
      final audio = JohnTravoltageAudio(m, enabled: false);
      pointFingerNearKnob(m);
      // Need >30 electrons for ouch
      for (var i = 0; i < 40; i++) {
        m.debugAddElectronAt(JtVec2(400.0 + i * 0.1, 280));
      }
      // Force spark start by stepping with threshold
      while (query(m) <= JohnTravoltageConstants.dischargeThreshold) {
        m.debugAddElectronAt(const JtVec2(410, 290));
      }
      for (var i = 0; i < 100; i++) {
        m.step(1 / 60);
        if (m.sparkVisible) break;
      }
      expect(audio.ouchScheduledCount, greaterThanOrEqualTo(1));
      expect(audio.hasPendingOuch, isTrue);
      m.reset();
      expect(audio.hasPendingOuch, isFalse);
      expect(audio.ouchCancelledCount, greaterThanOrEqualTo(1));
      audio.dispose();
    });

    test('O. re-entry audio lifecycle (dispose / recreate)', () {
      final m = seeded(21);
      final a1 = JohnTravoltageAudio(m, enabled: false);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);
      m.step(1 / 60);
      a1.dispose();

      final a2 = JohnTravoltageAudio(m, enabled: false);
      expect(a2.electricDischargeStartCount, 0);
      // Continue discharge
      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (m.electronCount == 0) break;
      }
      // New controller only sees events after attach; ending may or may not fire
      a2.dispose();
    });

    test('chargesInBody counters track electron count', () {
      final m = seeded(23);
      final audio = JohnTravoltageAudio(m, enabled: false);
      m.setLegAngle(1.2);
      m.setLegAngle(2.2);
      expect(m.electronCount, greaterThan(0));
      // notify already fired; give audio a sync
      expect(audio.chargesStartCount, greaterThanOrEqualTo(1));
      m.reset();
      expect(audio.chargesStopCount, greaterThanOrEqualTo(1));
      audio.dispose();
    });

    test('arm position bin crossings increment click counter', () {
      final m = seeded(25);
      final audio = JohnTravoltageAudio(m, enabled: false);
      // Move across multiple bins (~2π/32 each)
      const bin = 2 * math.pi / JtAudioConstants.armSoundPositions;
      m.setArmAngle(m.arm.angle + bin * 3.5);
      expect(audio.armClickCount, greaterThan(0));
      audio.dispose();
    });

    test('spark hysteresis: cancel exiting when finger moves away', () {
      final m = seeded(27);
      pointFingerNearKnob(m);
      addElectronsAboveThreshold(m);
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
      final sparkDist = m.sparkCreationDistToKnob!;

      // Move finger far from knob (arm angle away)
      m.setArmAngle(JohnTravoltageConstants.armInitialAngle);
      final dist = m.fingerPosition.distance(m.doorknobPosition);
      expect(dist, greaterThan(sparkDist + 10));

      // Electrons far from knob should leave exiting
      for (var i = 0; i < 5; i++) {
        m.step(1 / 60);
      }
      final far = m.electrons.where(
        (e) =>
            e.position.distance(m.doorknobPosition) >
            JohnTravoltageConstants.sparkCancelElectronKnobDistance,
      );
      expect(far.any((e) => !e.exiting), isTrue);
    });

    testWidgets('play area spark points track model while discharging',
        (tester) async {
      final model = seeded(29);
      await tester.pumpWidget(
        MaterialApp(
          home: JohnTravoltagePlayArea(
            model: model,
            autoStartClock: false,
            enableAudio: false,
          ),
        ),
      );
      await tester.pump();

      pointFingerNearKnob(model);
      addElectronsAboveThreshold(model);

      final state = tester.state<JohnTravoltagePlayAreaState>(
        find.byType(JohnTravoltagePlayArea),
      );

      var saw = false;
      for (var i = 0; i < 200; i++) {
        model.step(1 / 60);
        await tester.pump();
        if (model.sparkVisible && state.sparkPoints.isNotEmpty) {
          saw = true;
          expect(state.sparkPoints.first.x,
              closeTo(model.fingerPosition.x, 1e-6));
          expect(state.sparkPoints.last.x,
              closeTo(model.doorknobPosition.x, 1e-6));
          break;
        }
      }
      expect(saw, isTrue);
    });
  });
}
