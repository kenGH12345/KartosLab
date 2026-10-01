import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/transform/math_coordinate_transform.dart';

void main() {
  const builder = GflRenderBuilder();
  final t = MathCoordinateTransform.forLayout();

  group('Force label live update', () {
    test('DECIMAL label changes with force', () {
      final m = GravityForceLabModel();
      m.setForceValuesDisplay(ForceValuesDisplay.decimal);
      final l0 = builder.build(m, transform: t).forceLabel1;
      m.setMassValue(1, 200);
      final l1 = builder.build(m, transform: t).forceLabel1;
      expect(l0.contains('='), isTrue);
      expect(l1.contains('='), isTrue);
      expect(l1, isNot(l0));
      expect(l1.endsWith(' N'), isTrue);
    });

    test('SCIENTIFIC label changes with force', () {
      final m = GravityForceLabModel();
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      final l0 = builder.build(m, transform: t).forceLabel1;
      m.beginDrag(2);
      m.setPositionWhileDragging(2, 3);
      m.endDrag(2);
      final l1 = builder.build(m, transform: t).forceLabel1;
      expect(l0.contains('× 10^'), isTrue);
      expect(l1.contains('× 10^'), isTrue);
      expect(l1, isNot(l0));
    });

    test('HIDDEN keeps qualitative; arrows remain', () {
      final m = GravityForceLabModel();
      m.setForceValuesDisplay(ForceValuesDisplay.hidden);
      final r = builder.build(m, transform: t);
      expect(r.showForceValues, isFalse);
      expect(r.forceLabel1, 'Force on m1 by m2');
      expect(r.arrow1TipDx.abs(), greaterThan(0));
      final f = m.force;
      m.setMassValue(1, 300);
      expect(m.force, isNot(f));
      expect(m.forceValuesDisplay, ForceValuesDisplay.hidden);
    });

    test('Decimal→Scientific→Hidden→Decimal preserves physics', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 250);
      final f = m.force;
      final x1 = m.mass1.positionX;
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      m.setForceValuesDisplay(ForceValuesDisplay.hidden);
      m.setForceValuesDisplay(ForceValuesDisplay.decimal);
      expect(m.force, f);
      expect(m.mass1.positionX, x1);
      expect(m.showForceValues, isTrue);
    });
  });

  group('Mass controls / Constant Size', () {
    test('step 10 kg; clamp 10..1000', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 100);
      m.setMassValue(1, 110);
      expect(m.mass1.value, 110);
      m.setMassValue(1, 5);
      expect(m.mass1.value, 10);
      m.setMassValue(1, 10);
      m.setMassValue(1, 0);
      expect(m.mass1.value, 10);
      m.setMassValue(2, 2000);
      expect(m.mass2.value, 1000);
    });

    test('mass change updates radius OFF', () {
      final m = GravityForceLabModel();
      expect(m.constantRadius, isFalse);
      final r0 = m.radius1;
      m.setMassValue(1, 400);
      expect(m.radius1, greaterThan(r0));
    });

    test('Constant Size ON keeps radius 0.5; OFF restores density radius', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 400);
      m.setConstantRadius(true);
      expect(m.radius1, 0.5);
      expect(m.radius2, 0.5);
      m.setMassValue(1, 800);
      expect(m.radius1, 0.5);
      // Color still mass-dependent under constant size.
      final c800 = m.mass1.displayColor;
      m.setMassValue(1, 100);
      final c100 = m.mass1.displayColor;
      expect(c100, isNot(c800));

      m.setConstantRadius(false);
      expect(m.constantRadius, isFalse);
      // After OFF at mass 100, radius matches density formula (~0.542).
      expect(m.radius1, closeTo(0.5419260701392891, 1e-6));
      expect(m.force.isFinite, isTrue);
    });

    test('Constant Size ON/OFF rapid does not NaN', () {
      final m = GravityForceLabModel();
      for (var i = 0; i < 20; i++) {
        m.setConstantRadius(i.isEven);
        expect(m.force.isFinite, isTrue);
        expect(m.distance, greaterThan(0));
      }
    });

    test('force uses center distance even when Constant Size ON', () {
      final m = GravityForceLabModel();
      final d = m.distance;
      m.setConstantRadius(true);
      // Same centers → same force (radius visual only).
      expect(m.distance, d);
      final fOn = m.force;
      m.setConstantRadius(false);
      // May push if radii grow — force may change due to position push.
      expect(m.force.isFinite, isTrue);
      expect(fOn.isFinite, isTrue);
    });
  });
}
