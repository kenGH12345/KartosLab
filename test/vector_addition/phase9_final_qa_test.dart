import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/interaction/va_graph_interactor.dart';
import 'package:kratos/vector_addition/model/angle_convention_utils.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/equations_vector.dart';
import 'package:kratos/vector_addition/model/resultant_vector.dart';
import 'package:kratos/vector_addition/model/root_vector.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';
import 'package:kratos/vector_addition/vector_addition_constants.dart';

void main() {
  group('AngleConventionUtils (PhET VectorAdditionUtils)', () {
    test('signed→unsigned: 0 stays 0 (not 360)', () {
      expect(AngleConventionUtils.signedToUnsignedDegrees(0), 0);
      expect(RootVector.signedToUnsignedDegrees(0), 0);
    });

    test('signed→unsigned table', () {
      expect(AngleConventionUtils.signedToUnsignedDegrees(90), 90);
      expect(AngleConventionUtils.signedToUnsignedDegrees(180), 180);
      expect(AngleConventionUtils.signedToUnsignedDegrees(-90), 270);
      expect(AngleConventionUtils.signedToUnsignedDegrees(-180), 180);
      expect(AngleConventionUtils.signedToUnsignedDegrees(-5), 355);
    });

    test('unsigned→signed table; 0 and 360 → 0', () {
      expect(AngleConventionUtils.unsignedToSignedDegrees(0), 0);
      expect(AngleConventionUtils.unsignedToSignedDegrees(360), 0);
      expect(AngleConventionUtils.unsignedToSignedDegrees(90), 90);
      expect(AngleConventionUtils.unsignedToSignedDegrees(180), 180);
      expect(AngleConventionUtils.unsignedToSignedDegrees(270), -90);
      expect(AngleConventionUtils.unsignedToSignedDegrees(355), -5);
    });

    test('round-trip signed ↔ unsigned for step-5 values', () {
      for (var s = -180; s <= 180; s += 5) {
        final u = AngleConventionUtils.signedToUnsignedInt(s);
        expect(u, inInclusiveRange(0, 360));
        expect(u == 360, isFalse, reason: 'display never 360 for $s');
        // -180 and 180 both map to unsigned 180 → signed 180
        final back = AngleConventionUtils.unsignedToSignedInt(u > 355 ? 355 : u);
        if (s == -180) {
          expect(back, 180);
        } else {
          expect(back, s);
        }
      }
    });
  });

  group('unsigned dual picker wrap boundaries', () {
    EquationsVector polarE() {
      final model = EquationsModel()..selectScene(1);
      return model.scene.vectorSets.single.allVectors[1] as EquationsVector;
    }

    test('unsigned picker range is 0…355 step 5', () {
      expect(VectorAdditionConstants.unsignedAngleMin, 0);
      expect(VectorAdditionConstants.unsignedAngleMax, 355);
      expect(VectorAdditionConstants.polarAngleIntervalDegrees, 5);
    });

    test('0° / 355° edges: no negative, no 360 display', () {
      final e = polarE();
      e.setBaseAngleDegreesUnsigned(0);
      expect(e.baseAngleDegrees, 0);
      expect(e.baseAngleDegreesUnsigned, 0);

      e.setBaseAngleDegreesUnsigned(355);
      expect(e.baseAngleDegrees, -5);
      expect(e.baseAngleDegreesUnsigned, 355);

      // Clamp above max
      e.setBaseAngleDegreesUnsigned(360);
      expect(e.baseAngleDegreesUnsigned, lessThanOrEqualTo(355));
      expect(e.baseAngleDegreesUnsigned, greaterThanOrEqualTo(0));
    });

    test('continuous step across quadrant without desync', () {
      final e = polarE();
      e.setBaseAngleDegreesUnsigned(350);
      expect(e.baseAngleDegrees, -10);
      e.setBaseAngleDegreesUnsigned(355);
      expect(e.baseAngleDegrees, -5);
      e.setBaseAngleDegrees(0);
      expect(e.baseAngleDegreesUnsigned, 0);
      e.setBaseAngleDegrees(5);
      expect(e.baseAngleDegreesUnsigned, 5);
      e.setBaseAngleDegrees(90);
      expect(e.baseAngleDegreesUnsigned, 90);
      e.setBaseAngleDegrees(180);
      expect(e.baseAngleDegreesUnsigned, 180);
    });

    test('switching convention display stays consistent', () {
      final model = EquationsModel()..selectScene(1);
      final e = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      e.setBaseAngleDegrees(-90);
      model.view.angleConvention = AngleConvention.unsigned;
      expect(e.baseAngleDegreesUnsigned, 270);
      model.view.angleConvention = AngleConvention.signed;
      expect(e.baseAngleDegrees, -90);
    });
  });

  group('coefficient / equation / reset boundaries', () {
    test('coefficient -5 / 0 / 1 / 5', () {
      final model = EquationsModel();
      final a = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      expect(a.coefficient, 1);
      a.setCoefficient(0);
      expect(a.xyComponents, VaVec.zero);
      a.setCoefficient(-5);
      expect(a.coefficient, -5);
      expect(a.xyComponents.y, -25); // base (0,5) × -5
      a.setCoefficient(5);
      expect(a.coefficient, 5);
      expect(a.xyComponents.y, 25);
      a.setCoefficient(99);
      expect(a.coefficient, 5);
      a.setCoefficient(-99);
      expect(a.coefficient, -5);
    });

    test('resultant stays EquationsResultant after coeff change', () {
      final model = EquationsModel();
      final a = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      a.setCoefficient(2);
      model.notifyEquationVectorsChanged();
      expect(model.scene.vectorSets.single.resultant, isA<EquationsResultant>());
      expect(model.scene.vectorSets.single.resultant, isNot(isA<SumVector>()));
    });

    test('Cartesian ↔ Polar isolation + reset', () {
      final model = EquationsModel();
      final a = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      a.setCoefficient(3);
      model.notifyEquationVectorsChanged();
      model.selectScene(1);
      expect(model.scene.coordinateSnapMode, CoordinateSnapMode.polar);
      final d = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      expect(d.coefficient, 1); // independent scene
      expect(d.symbol, 'd');
      model.selectScene(0);
      expect(
        (model.scene.vectorSets.single.allVectors[0] as EquationsVector)
            .coefficient,
        3,
      );
      model.reset();
      expect(
        (model.scene.vectorSets.single.allVectors[0] as EquationsVector)
            .coefficient,
        1,
      );
      expect(model.equationType, EquationType.addition);
      expect(model.view.angleConvention, AngleConvention.signed);
    });

    test('Lab toolbox symbols stay u/v; Explore2D a/b/c', () {
      expect(
        LabModel()
            .scene
            .vectorSets
            .map((s) => s.allVectors.first.symbol.split('_').first)
            .toList(),
        ['u', 'v'],
      );
      expect(
        Explore2DModel().scene.vectorSets.single.allVectors.map((v) => v.symbol),
        ['a', 'b', 'c'],
      );
    });

    test('Explore vs Lab state isolation', () {
      final explore = Explore2DModel();
      final lab = LabModel();
      VaGraphInteractor(explore).activateFromToolbox(0);
      expect(lab.scene.vectorSets.every((s) => s.activeVectors.isEmpty), isTrue);
      explore.view.sumVisible = true;
      expect(lab.view.sumVisible, isFalse);
    });
  });

  group('getAngleDegrees unsigned uses Utils (0→0)', () {
    test('zero angle vector reports 0° unsigned', () {
      final v = RootVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(5, 0),
      );
      expect(v.getAngleDegrees(AngleConvention.signed), closeTo(0, 1e-9));
      expect(v.getAngleDegrees(AngleConvention.unsigned), closeTo(0, 1e-9));
    });
  });
}
