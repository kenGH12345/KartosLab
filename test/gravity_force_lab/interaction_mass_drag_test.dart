import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/transform/math_coordinate_transform.dart';

void main() {
  group('Mass drag / track / surface gap', () {
    test('Mass 1 horizontal drag updates position with snap 0.1', () {
      final m = GravityForceLabModel();
      m.beginDrag(1);
      m.setPositionWhileDragging(1, -2.04);
      expect(m.mass1.positionX, -2.0);
      // Use 0.06 offset to avoid float halfway ambiguity around *.05
      m.setPositionWhileDragging(1, -2.06);
      expect(m.mass1.positionX, -2.1);
      m.endDrag(1);
      expect(m.mass1.isDragging, isFalse);
      expect(m.mass2.positionX, 1); // other mass untouched
    });

    test('Mass 2 horizontal drag updates position', () {
      final m = GravityForceLabModel();
      final x1 = m.mass1.positionX;
      m.beginDrag(2);
      m.setPositionWhileDragging(2, 2.3);
      expect(m.mass2.positionX, 2.3);
      m.endDrag(2);
      expect(m.mass1.positionX, x1);
    });

    test('±5 m boundary clamp', () {
      final m = GravityForceLabModel();
      m.beginDrag(1);
      m.setPositionWhileDragging(1, -99);
      m.endDrag(1);
      expect(m.mass1.positionX, greaterThanOrEqualTo(-5));

      m.beginDrag(2);
      m.setPositionWhileDragging(2, 99);
      m.endDrag(2);
      expect(m.mass2.positionX, lessThanOrEqualTo(5));
    });

    test('surface gap 0.1 — no crossing / no overlap', () {
      final m = GravityForceLabModel();
      m.beginDrag(1);
      m.setPositionWhileDragging(1, 5);
      m.endDrag(1);
      expect(m.mass1.positionX, lessThan(m.mass2.positionX));
      expect(
        m.distance + 1e-9,
        greaterThanOrEqualTo(m.getSumRadiusWithSeparation()),
      );
    });

    test('drag is horizontal-only at model API (Y not stored for masses)', () {
      final m = GravityForceLabModel();
      // Masses have no positionY — only positionX exists.
      expect(m.mass1.positionX, isA<double>());
      m.beginDrag(1);
      m.setPositionWhileDragging(1, -2.5);
      m.endDrag(1);
      expect(m.mass1.positionX, -2.5);
    });
  });

  group('Push-on-radius', () {
    test('mass↑ radius↑ pushes other sphere when close', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 10);
      m.setMassValue(2, 10);
      m.setPosition(1, -0.5);
      m.setPosition(2, 0.5);
      final p2Before = m.mass2.positionX;
      final sepBefore = m.distance;
      final fBefore = m.force;

      m.setMassValue(1, 1000);
      expect(m.radius1, greaterThan(0.5));
      expect(m.distance + 1e-9, greaterThanOrEqualTo(m.getSumRadiusWithSeparation()));
      expect(m.mass2.positionX, greaterThan(p2Before));
      expect(m.distance, greaterThan(sepBefore));
      expect(m.force.isFinite, isTrue);
      expect(m.force.isNaN, isFalse);
      expect(m.mass1.positionX, greaterThanOrEqualTo(-5));
      expect(m.mass2.positionX, lessThanOrEqualTo(5));
      // Force changed because mass and/or separation changed.
      expect(m.force, isNot(fBefore));
    });
  });

  group('Force / arrow live update (render binding)', () {
    const builder = GflRenderBuilder();
    final t = MathCoordinateTransform.forLayout();

    test('distance ↑ → force ↓ → arrow tip shorter', () {
      final m = GravityForceLabModel();
      final r0 = builder.build(m, transform: t);
      final f0 = m.force;
      final tip0 = r0.arrow1TipDx.abs();

      m.beginDrag(2);
      m.setPositionWhileDragging(2, 4);
      m.endDrag(2);
      final r1 = builder.build(m, transform: t);
      expect(m.force, lessThan(f0));
      expect(r1.arrow1TipDx.abs(), lessThan(tip0));
      expect(r1.arrow1TipDx.sign, isNot(r1.arrow2TipDx.sign));
    });

    test('mass1 ↑ → force ↑ → arrow tip longer', () {
      final m = GravityForceLabModel();
      final tip0 = builder.build(m, transform: t).arrow1TipDx.abs();
      final f0 = m.force;
      m.setMassValue(1, 500);
      final tip1 = builder.build(m, transform: t).arrow1TipDx.abs();
      expect(m.force, greaterThan(f0));
      expect(tip1, greaterThan(tip0));
    });

    test('mass2 ↑ → force ↑', () {
      final m = GravityForceLabModel();
      final f0 = m.force;
      m.setMassValue(2, 800);
      expect(m.force, greaterThan(f0));
    });

    test('Full arrow params not Basics', () {
      expect(GravityForceConstants.maxArrowWidth, 700);
      expect(GravityForceConstants.forceThresholdPercent, 1.6e-4);
    });

    test('puller frame follows force', () {
      final m = GravityForceLabModel();
      final f0 = builder.build(m, transform: t).puller1Frame;
      m.setMassValue(1, 1000);
      m.setMassValue(2, 1000);
      m.setPosition(1, -1);
      m.setPosition(2, 1);
      final f1 = builder.build(m, transform: t).puller1Frame;
      expect(f1, inInclusiveRange(0, 30));
      expect(f1, greaterThanOrEqualTo(f0));
      final flipFrame = builder.build(m, transform: t).puller2Frame;
      expect(flipFrame, f1); // same force → same frame index
    });
  });
}
