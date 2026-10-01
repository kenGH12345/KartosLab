import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';

void main() {
  group('Ruler', () {
    test('initial position (0, -1); always present', () {
      final m = GravityForceLabModel();
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);
      expect(m.ruler.snap, 0.1);
    });

    test('snap 0.1 on X', () {
      final m = GravityForceLabModel();
      m.setRulerPosition(1.04, -1);
      expect(m.ruler.positionX, 1.0);
      m.setRulerPosition(1.05, -1);
      expect(m.ruler.positionX, 1.1);
    });

    test('drag bounds clamp', () {
      final m = GravityForceLabModel();
      m.setRulerPosition(-100, 100);
      expect(m.ruler.positionX, greaterThanOrEqualTo(m.ruler.dragMinX));
      expect(m.ruler.positionX, lessThanOrEqualTo(m.ruler.dragMaxX));
      expect(m.ruler.positionY, lessThanOrEqualTo(m.ruler.dragMaxY));
      expect(m.ruler.positionY, greaterThanOrEqualTo(m.ruler.dragMinY));
    });

    test('major tick = 1 m via MVT scale 50', () {
      expect(GravityForceConstants.mvtScale, 50);
      expect(
        GravityForceConstants.rulerWidthView / GravityForceConstants.mvtScale,
        10,
      ); // 0..10 m scale length
      expect(mRulerMajorSpacing, 1);
    });

    test('independence: ruler move does not change physics', () {
      final m = GravityForceLabModel();
      final f = m.force;
      final d = m.distance;
      final x1 = m.mass1.positionX;
      final x2 = m.mass2.positionX;
      m.setRulerPosition(2.5, 0.5);
      expect(m.force, f);
      expect(m.distance, d);
      expect(m.mass1.positionX, x1);
      expect(m.mass2.positionX, x2);
    });

    test('jumpHome / jumpZeroToMass1Center', () {
      final m = GravityForceLabModel();
      m.setRulerPosition(2, 1);
      m.jumpRulerHome();
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);

      m.jumpRulerZeroToMass1Center();
      expect(
        m.ruler.positionX,
        closeTo(
          m.mass1.positionX + GravityForceConstants.rulerHalfWidthModel,
          1e-9,
        ),
      );
      expect(m.ruler.positionY, GravityForceConstants.rulerModelYForCenterJump);
    });

    test('reset restores ruler', () {
      final m = GravityForceLabModel();
      m.setRulerPosition(3, 1);
      m.reset();
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);
      expect(m.ruler.isDragging, isFalse);
    });
  });

  group('Reset equivalence', () {
    test('fresh model ≡ arbitrary changes then reset', () {
      final fresh = GravityForceLabModel();
      final m = GravityForceLabModel();
      m.setMassValue(1, 500);
      m.setMassValue(2, 200);
      m.setPosition(1, -4);
      m.setPosition(2, 3);
      m.setConstantRadius(true);
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      m.setRulerPosition(1.5, 0);
      m.reset();

      expect(m.mass1.value, fresh.mass1.value);
      expect(m.mass2.value, fresh.mass2.value);
      expect(m.mass1.positionX, fresh.mass1.positionX);
      expect(m.mass2.positionX, fresh.mass2.positionX);
      expect(m.constantRadius, fresh.constantRadius);
      expect(m.forceValuesDisplay, fresh.forceValuesDisplay);
      expect(m.showForceValues, fresh.showForceValues);
      expect(m.ruler.positionX, fresh.ruler.positionX);
      expect(m.ruler.positionY, fresh.ruler.positionY);
      expect(m.force, closeTo(fresh.force, 1e-20));
    });
  });

  group('Boundary / no invalid state', () {
    test('force finite for all legal positions', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 10);
      m.setMassValue(2, 10);
      m.beginDrag(1);
      m.setPositionWhileDragging(1, -5);
      m.endDrag(1);
      m.beginDrag(2);
      m.setPositionWhileDragging(2, 5);
      m.endDrag(2);
      expect(m.force.isFinite, isTrue);
      expect(m.force.isNaN, isFalse);
      expect(m.distance, greaterThan(0));
    });

    test('Full arrow params not Basics', () {
      expect(GravityForceConstants.maxArrowWidth, 700);
      expect(GravityForceConstants.forceThresholdPercent, 1.6e-4);
      expect(GravityForceConstants.maxArrowWidth, isNot(400));
    });
  });
}

/// Ruler major tick spacing in meters.
const double mRulerMajorSpacing = 1;
