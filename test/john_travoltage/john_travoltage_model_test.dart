import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/john_travoltage/model/arm.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_constants.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/model/jt_vec2.dart';
import 'package:kratos/john_travoltage/model/leg.dart';

void main() {
  group('JohnTravoltageModel — Phase 1', () {
    JohnTravoltageModel modelWithSeed([int seed = 42]) =>
        JohnTravoltageModel(random: math.Random(seed));

    test('A. initial state', () {
      final m = modelWithSeed();
      expect(m.arm.angle, JohnTravoltageConstants.armInitialAngle);
      expect(m.leg.angle, JohnTravoltageConstants.legInitialAngle);
      expect(m.electronCount, 0);
      expect(m.accumulatedAngle, 0);
      expect(m.sparkVisible, isFalse);
      expect(m.numberOfElectronsDischarged, 0);
      expect(m.shoeOnCarpet, isTrue); // 1.31754 ∈ (1, 2.4)
    });

    test('B. arm fingerPosition = fingerVector.rotated(angle) + pivot', () {
      final arm = Arm();
      expect(arm.position, JohnTravoltageConstants.armPivot);
      expect(arm.fingerVector,
          JohnTravoltageConstants.armFingerSample - JohnTravoltageConstants.armPivot);

      final expected = arm.fingerVector
          .rotated(arm.angle)
          .plus(arm.position);
      final actual = arm.getFingerPosition();
      expect(actual.x, closeTo(expected.x, 1e-9));
      expect(actual.y, closeTo(expected.y, 1e-9));

      // At angle 0, finger tip equals sampled finger.
      arm.setAngle(0);
      final atZero = arm.getFingerPosition();
      expect(atZero.x, closeTo(JohnTravoltageConstants.armFingerSample.x, 1e-6));
      expect(atZero.y, closeTo(JohnTravoltageConstants.armFingerSample.y, 1e-6));
    });

    test('C. leg pivot, range, limitRotation', () {
      final leg = Leg();
      expect(leg.position, JohnTravoltageConstants.legPivot);
      expect(leg.angleMin, 0);
      expect(leg.angleMax, math.pi);

      expect(Leg.limitRotation(-2), math.pi); // < -π/2 → π
      expect(Leg.limitRotation(-0.5), 0); // (-π/2, 0) → 0
      expect(Leg.limitRotation(1.2), 1.2); // bottom semicircle unchanged
    });

    test('D. carpet range shoeOnCarpet', () {
      final m = modelWithSeed();
      m.setLegAngle(0.9);
      expect(m.shoeOnCarpet, isFalse);
      m.setLegAngle(1.0);
      expect(m.shoeOnCarpet, isFalse); // exclusive min
      m.setLegAngle(1.0001);
      expect(m.shoeOnCarpet, isTrue);
      m.setLegAngle(2.0);
      expect(m.shoeOnCarpet, isTrue);
      m.setLegAngle(2.4);
      expect(m.shoeOnCarpet, isFalse); // exclusive max
      m.setLegAngle(2.5);
      expect(m.shoeOnCarpet, isFalse);
    });

    test('E. charge threshold π/16', () {
      final m = modelWithSeed();
      final start = m.leg.angle;
      // Move less than π/16 on carpet → no electron
      m.setLegAngle(start + JohnTravoltageConstants.accumulatedAngleThreshold * 0.5);
      expect(m.electronCount, 0);

      // Cross one threshold
      m.setLegAngle(start + JohnTravoltageConstants.accumulatedAngleThreshold * 1.01);
      expect(m.electronCount, 1);
    });

    test('F. multiple thresholds in one move', () {
      final m = modelWithSeed();
      final start = m.leg.angle; // ~1.32 on carpet
      // Sweep enough angle to create 3 electrons in one setLegAngle
      final delta = JohnTravoltageConstants.accumulatedAngleThreshold * 3.5;
      m.setLegAngle(start + delta);
      expect(m.electronCount, 3);
    });

    test('G. MAX_ELECTRONS = 100', () {
      final m = modelWithSeed();
      // Force-create up to max via successive carpet sweeps
      var sweeps = 0;
      while (m.electronCount < JohnTravoltageConstants.maxElectrons &&
          sweeps < 500) {
        final a = 1.1 + (sweeps % 2) * 1.2; // alternate 1.1 and 2.3
        m.setLegAngle(a);
        sweeps++;
      }
      expect(m.electronCount, JohnTravoltageConstants.maxElectrons);

      final before = m.electronCount;
      m.setLegAngle(1.1);
      m.setLegAngle(2.3);
      m.setLegAngle(1.1);
      expect(m.electronCount, before);
      expect(m.electronCount, JohnTravoltageConstants.maxElectrons);
    });

    test('H. electron motion: friction and maxSpeed', () {
      final m = modelWithSeed();
      final e = m.debugAddElectronAt(const JtVec2(400, 300));
      // Place inside body region (torso-ish) and give huge velocity
      e.velocity.setXY(10000, 0);
      m.step(1 / 60);
      expect(e.velocity.magnitude,
          lessThanOrEqualTo(JohnTravoltageConstants.maxSpeed + 1e-6));

      // Friction multiplies once per step when no huge force dominates
      final e2 = m.debugAddElectronAt(const JtVec2(395, 250));
      e2.velocity.setXY(100, 0);
      // Isolate: single electron → no repulsion partners interact meaningfully
      // with only this one's motion after clearing others would change count —
      // check friction factor on a lone electron with zero net force from peers
      // by using only e2 after removing e.
      m.electrons.remove(e);
      final vxBefore = e2.velocity.x;
      // One step with no other electrons → net force ~0, friction applies
      m.step(1 / 60);
      // vx2 = (vx + 0)*friction, then position updates
      expect(e2.velocity.x,
          closeTo(vxBefore * JohnTravoltageConstants.frictionFactor, 1e-6));
    });

    test('I. body boundary prevents free escape on bounce path', () {
      final m = modelWithSeed();
      // Spawn near a known body edge segment and push outward across it
      final e = m.debugAddElectronAt(const JtVec2(422, 450));
      e.velocity.setXY(0, 400);
      for (var i = 0; i < 30; i++) {
        m.step(1 / 60);
      }
      // After bouncing, electron should still be near body (not far outside)
      // Use bodyContains OR stay within a generous padded body AABB
      final inside = m.bodyContainsPoint(e.position);
      final nearBody = e.position.x > 250 &&
          e.position.x < 520 &&
          e.position.y > 60 &&
          e.position.y < 500;
      expect(inside || nearBody, isTrue,
          reason: 'electron escaped far outside body: ${e.position}');
    });

    test('J. discharge when count/dist > 10/15', () {
      final m = modelWithSeed();
      // Point finger near knob and add enough electrons
      _pointFingerNearKnob(m);
      final dist = m.fingerPosition.distance(m.doorknobPosition);
      final needed = (JohnTravoltageConstants.dischargeThreshold * dist).floor() + 1;
      for (var i = 0; i < needed; i++) {
        m.debugAddElectronAt(const JtVec2(400, 280));
      }
      expect(m.electronCount / dist,
          greaterThan(JohnTravoltageConstants.dischargeThreshold));

      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
    });

    test('K. no discharge when threshold not met', () {
      final m = modelWithSeed();
      // Keep arm at initial (farther) and only 1 electron
      m.debugAddElectronAt(const JtVec2(400, 280));
      final dist = m.fingerPosition.distance(m.doorknobPosition);
      expect(m.electronCount / dist,
          lessThanOrEqualTo(JohnTravoltageConstants.dischargeThreshold));
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isFalse);
      expect(m.sparkVisible, isFalse);
    });

    test('L. continuous discharge while threshold holds', () {
      final m = modelWithSeed();
      _pointFingerNearKnob(m);
      for (var i = 0; i < 20; i++) {
        m.debugAddElectronAt(const JtVec2(400, 280));
      }
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);

      // Add more while still near knob — newly added marked exiting next step
      m.debugAddElectronAt(const JtVec2(405, 285));
      m.step(1 / 60);
      expect(m.electrons.every((e) => e.exiting), isTrue);
    });

    test('M. force lines drive spark segment progression', () {
      final m = modelWithSeed(7);
      expect(m.forceLines.length, 12);

      final e = m.debugAddElectronAt(const JtVec2(400, 400));
      e.exiting = true;
      // Step until a segment is assigned
      m.step(1 / 60);
      expect(e.segment, isNotNull);
      expect(m.forceLines.contains(e.segment), isTrue);
    });

    test('N. electron removal after spark path completes', () {
      final m = modelWithSeed(1);
      _pointFingerNearKnob(m);
      _addElectronsAboveDischargeThreshold(m);
      expect(m.electrons, isNotEmpty);

      // Drive long enough for exiting electrons to finish force-line path
      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (m.electronCount == 0) break;
      }
      expect(m.electronCount, 0);
    });

    test('O. lifecycle sparkVisible / started / ended', () {
      final m = modelWithSeed(3);
      var started = 0;
      var ended = 0;
      m.addDischargeStartedListener(() => started++);
      m.addDischargeEndedListener(() => ended++);

      _pointFingerNearKnob(m);
      _addElectronsAboveDischargeThreshold(m);

      // Run until discharge completes
      for (var i = 0; i < 1200; i++) {
        m.step(1 / 60);
        if (ended > 0 && m.electronCount == 0) break;
      }

      expect(started, greaterThanOrEqualTo(1));
      expect(ended, greaterThanOrEqualTo(1));
      expect(m.sparkVisible, isFalse);
      expect(m.numberOfElectronsDischarged, greaterThan(0));
    });

    test('P. reset restores initial state', () {
      final m = modelWithSeed();
      m.setLegAngle(2.0);
      m.setLegAngle(1.2);
      m.setArmAngle(0.3);
      expect(m.electronCount, greaterThan(0));

      m.sparkVisible = true;
      m.numberOfElectronsDischarged = 7;
      m.arm.dragging = true;
      m.leg.borderVisible = false;

      m.reset();

      expect(m.electronCount, 0);
      expect(m.accumulatedAngle, 0);
      expect(m.arm.angle, JohnTravoltageConstants.armInitialAngle);
      expect(m.leg.angle, JohnTravoltageConstants.legInitialAngle);
      expect(m.sparkVisible, isFalse);
      expect(m.numberOfElectronsDischarged, 0);
      expect(m.arm.dragging, isFalse);
      expect(m.leg.borderVisible, isTrue);
      expect(m.sparkCreationDistToKnob, isNull);
    });

    test('Q. repeated charge → discharge → reset lifecycle', () {
      final m = modelWithSeed(11);
      for (var round = 0; round < 2; round++) {
        // Charge
        m.setLegAngle(1.1);
        m.setLegAngle(2.3);
        m.setLegAngle(1.1);
        m.setLegAngle(2.3);
        expect(m.electronCount, greaterThan(0),
            reason: 'round $round should accumulate charge');

        // Discharge
        _pointFingerNearKnob(m);
        for (var i = 0; i < 800; i++) {
          m.step(1 / 60);
          if (m.electronCount == 0) break;
        }
        expect(m.electronCount, 0, reason: 'round $round discharge');

        m.reset();
        expect(m.electronCount, 0);
        expect(m.arm.angle, JohnTravoltageConstants.armInitialAngle);
        expect(m.leg.angle, JohnTravoltageConstants.legInitialAngle);
      }
    });

    test('constants: doorknob and layout', () {
      expect(JohnTravoltageConstants.layoutWidth, 768);
      expect(JohnTravoltageConstants.layoutHeight, 504);
      expect(JohnTravoltageConstants.doorknobPosition.x,
          closeTo(548.4318903113076, 1e-12));
      expect(JohnTravoltageConstants.doorknobPosition.y,
          closeTo(257.5894162536105, 1e-12));
      expect(JohnTravoltageConstants.bodyVertices.length, 31);
      expect(JohnTravoltageConstants.forceLineCoords.length, 12);
    });

    test('dt clamp ≤ 2/60', () {
      final m = modelWithSeed();
      m.debugAddElectronAt(const JtVec2(400, 280));
      final e = m.electrons.first;
      e.velocity.setXY(50, 0);
      final x0 = e.position.x;
      // Huge dt should behave like maxDt
      m.step(10);
      final dxHuge = (e.position.x - x0).abs();

      m.reset();
      m.debugAddElectronAt(const JtVec2(400, 280));
      final e2 = m.electrons.first;
      e2.velocity.setXY(50, 0);
      final x1 = e2.position.x;
      m.step(JohnTravoltageConstants.maxDt);
      final dxClamped = (e2.position.x - x1).abs();

      expect(dxHuge, closeTo(dxClamped, 1e-6));
    });

    test('no charge when foot not on carpet', () {
      final m = modelWithSeed();
      m.setLegAngle(0.5); // off carpet
      m.setLegAngle(0.0);
      m.setLegAngle(0.5);
      expect(m.electronCount, 0);
    });
  });
}

/// Rotate arm so finger is near doorknob (~actualMin distance).
void _pointFingerNearKnob(JohnTravoltageModel m) {
  final knob = JohnTravoltageConstants.doorknobPosition;
  final pivot = m.arm.position;
  final desired = knob - pivot;
  // angle such that fingerVector.rotated(angle) ≈ desired direction at finger length
  final fingerLen = m.arm.fingerVector.magnitude;
  final target = desired.normalize().times(fingerLen);
  // Solve angle: rotate fingerVector to align with target
  final a0 = m.arm.fingerVector.angle;
  final a1 = target.angle;
  m.setArmAngle(a1 - a0);

  // Verify reasonably close
  final dist = m.fingerPosition.distance(knob);
  expect(dist, lessThan(30),
      reason: 'finger should be near knob, dist=$dist');
}

/// Add enough electrons so `count / distToKnob > 10/15`.
void _addElectronsAboveDischargeThreshold(JohnTravoltageModel m) {
  final dist = m.fingerPosition.distance(m.doorknobPosition);
  final needed =
      (JohnTravoltageConstants.dischargeThreshold * dist).floor() + 1;
  for (var i = 0; i < needed; i++) {
    m.debugAddElectronAt(JtVec2(400 + (i % 5).toDouble(), 280 + (i % 3).toDouble()));
  }
  expect(
    m.electronCount / dist,
    greaterThan(JohnTravoltageConstants.dischargeThreshold),
  );
}
