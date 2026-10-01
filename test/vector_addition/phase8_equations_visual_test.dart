import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/equations_vector.dart';
import 'package:kratos/vector_addition/model/resultant_vector.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/render/va_render_builder.dart';
import 'package:kratos/vector_addition/vector_addition_constants.dart';

void main() {
  group('Equations coefficient', () {
    test('default 1; range −5…5; updates xy and resultant', () {
      final model = EquationsModel();
      final a = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      final b = model.scene.vectorSets.single.allVectors[1] as EquationsVector;
      expect(a.coefficient, 1);
      expect(b.coefficient, 1);
      expect(a.xyComponents.y, 5); // base (0,5) × 1

      a.setCoefficient(2);
      model.notifyEquationVectorsChanged();
      expect(a.xyComponents.y, 10);
      expect(a.coefficient, 2);

      a.setCoefficient(99);
      expect(a.coefficient, VectorAdditionConstants.coefficientMax);

      final r = model.scene.vectorSets.single.resultant as EquationsResultant;
      expect(r, isA<EquationsResultant>());
      expect(r, isNot(isA<SumVector>()));
      expect(r.xyComponents.y, closeTo(10 + 5, 1e-9)); // 2*a + b
    });

    test('reset restores coefficient and base', () {
      final model = EquationsModel();
      final a = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      a.setCoefficient(-3);
      a.setBaseY(8);
      model.notifyEquationVectorsChanged();
      model.reset();
      final a2 = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      expect(a2.coefficient, 1);
      expect(a2.baseY, 5);
      expect(a2.xyComponents.y, 5);
    });
  });

  group('Equations polar scene', () {
    test('independent from cartesian; pink palette; d,e,f', () {
      final model = EquationsModel();
      expect(model.scenes.length, 2);
      model.selectScene(1);
      expect(model.scene.name, 'Polar');
      expect(model.scene.coordinateSnapMode, CoordinateSnapMode.polar);
      final set = model.scene.vectorSets.single;
      expect(set.allVectors.map((v) => v.symbol), ['d', 'e']);
      expect(set.resultantSymbol, 'f');
      expect(set.resultant, isA<EquationsResultant>());
      final d = set.allVectors[0] as EquationsVector;
      expect(d.baseMagnitude, 5);
      expect(d.baseAngleDegrees, 0);
    });

    test('polar base angle step drives xy via Model→derived', () {
      final model = EquationsModel();
      model.selectScene(1);
      final e = model.scene.vectorSets.single.allVectors[1] as EquationsVector;
      e.setBaseAngleDegrees(90);
      e.setBaseMagnitude(4);
      model.notifyEquationVectorsChanged();
      expect(e.xyComponents.x.abs(), lessThan(1e-6));
      expect(e.xyComponents.y, closeTo(4, 1e-6));
    });
  });

  group('equation types stay EquationsResultant', () {
    test('addition / subtraction / negation', () {
      final model = EquationsModel();
      final set = model.scene.vectorSets.single;
      final a = set.allVectors[0] as EquationsVector;
      final b = set.allVectors[1] as EquationsVector;
      // a=(0,5), b=(5,5)
      model.setEquationType(EquationType.addition);
      expect((set.resultant as EquationsResultant).xyComponents.x, 5);
      expect((set.resultant as EquationsResultant).xyComponents.y, 10);

      model.setEquationType(EquationType.subtraction);
      expect((set.resultant as EquationsResultant).xyComponents.x, -5);
      expect((set.resultant as EquationsResultant).xyComponents.y, 0);

      model.setEquationType(EquationType.negation);
      expect((set.resultant as EquationsResultant).xyComponents.x, -5);
      expect((set.resultant as EquationsResultant).xyComponents.y, -10);

      a.setCoefficient(0);
      model.notifyEquationVectorsChanged();
      expect((set.resultant as EquationsResultant).xyComponents.x, -5);
      expect((set.resultant as EquationsResultant).xyComponents.y, -5);
    });
  });

  group('base vectors render', () {
    test('visible only when toggled; uses base xy not coefficient', () {
      final model = EquationsModel();
      final a = model.scene.vectorSets.single.allVectors[0] as EquationsVector;
      a.setCoefficient(3);
      model.notifyEquationVectorsChanged();
      model.view.baseVectorsVisible = true;
      final data = const VaRenderBuilder().build(model);
      expect(data.baseVectors, hasLength(2));
      // Base still (0,5) while vector is 3×
      expect(data.baseVectors.first.magnitude, closeTo(5, 1e-9));
      expect(a.magnitude, closeTo(15, 1e-9));
    });
  });

  group('screen layout anchors', () {
    test('1D vs 2D vs Lab vs Equations differ by source', () {
      final b = const VaRenderBuilder();
      final d1 = b.build(Explore1DModel());
      final d2 = b.build(Explore2DModel());
      final dL = b.build(LabModel());
      final dE = b.build(EquationsModel());
      expect(d1.controlPanel.showAngles, isFalse);
      expect(d2.controlPanel.showAngles, isTrue);
      expect(dL.toolboxSlots.length, 2);
      expect(d2.toolboxSlots.length, 3);
      expect(dE.showToolbox, isFalse);
      expect(dE.showEraser, isFalse);
      expect(dE.controlPanel.equationOptions, hasLength(3));
      // Lab not Explore2D clone
      expect(dL.toolboxSlots.map((s) => s.symbol).toList(), ['u', 'v']);
    });
  });
}
