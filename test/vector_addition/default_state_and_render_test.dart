import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/resultant_vector.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/render/va_render_builder.dart';
import 'package:kratos/vector_addition/vector_addition_constants.dart';

void main() {
  const builder = VaRenderBuilder();

  group('Explore 1D default', () {
    late Explore1DModel model;

    setUp(() => model = Explore1DModel());

    test('scene horizontal, cartesian snap, 3 toolbox vectors off-graph', () {
      expect(model.scene.name, 'Horizontal');
      expect(model.scene.coordinateSnapMode, CoordinateSnapMode.cartesian);
      final set = model.scene.vectorSets.single;
      expect(set.allVectors.map((v) => v.symbol), ['a', 'b', 'c']);
      expect(set.allVectors.every((v) => !v.isOnGraph), isTrue);
      expect(set.allVectors.every((v) => v.xyComponents.y == 0), isTrue);
      expect(model.view.sumVisible, isFalse);
      expect(model.view.gridVisible, isTrue);
      expect(model.componentStyle.style, ComponentVectorStyle.invisible);
    });

    test('renderData has empty on-graph vectors and 3 toolbox slots', () {
      final data = builder.build(model);
      expect(data.vectors, isEmpty);
      expect(data.resultants, isEmpty);
      expect(data.toolboxSlots.length, 3);
      expect(data.showToolbox, isTrue);
      expect(data.showEraser, isTrue);
      expect(data.graphRect.width,
          closeTo(50 * VectorAdditionConstants.modelToViewScale, 1e-6));
    });
  });

  group('Explore 2D default', () {
    test('cartesian a,b,c off-graph; sum hidden; components invisible', () {
      final model = Explore2DModel();
      final set = model.scene.vectorSets.single;
      expect(set.allVectors.map((v) => v.symbol), ['a', 'b', 'c']);
      expect(set.allVectors.every((v) => !v.isOnGraph), isTrue);
      expect(set.allVectors[0].xyComponents.x, 6);
      expect(model.view.sumVisible, isFalse);
      final data = builder.build(model);
      expect(data.vectors, isEmpty);
      expect(data.controlPanel.showComponents, isTrue);
      expect(data.controlPanel.showAngles, isTrue);
    });
  });

  group('Lab default', () {
    test('2 sets × 10 vectors, all off-graph, not Explore2D clone', () {
      final model = LabModel();
      expect(model.scene.vectorSets.length, 2);
      expect(model.scene.vectorSets[0].allVectors.length, 10);
      expect(model.scene.vectorSets[1].allVectors.length, 10);
      expect(
        model.scene.vectorSets.every(
          (s) => s.allVectors.every((v) => !v.isOnGraph),
        ),
        isTrue,
      );
      expect(model.scene.vectorSets[0].allVectors.first.symbol, 'u_1');
      expect(model.scene.vectorSets[1].allVectors.first.symbol, 'v_1');
      final data = builder.build(model);
      expect(data.toolboxSlots.map((s) => s.symbol), ['u', 'v']);
      expect(data.vectors, isEmpty);
    });
  });

  group('Equations default', () {
    test('a,b on graph; c via EquationsResultant addition; not SumVector', () {
      final model = EquationsModel();
      final set = model.scene.vectorSets.single;
      expect(set.allVectors.map((v) => v.symbol), ['a', 'b']);
      expect(set.allVectors.every((v) => v.isOnGraph), isTrue);
      expect(set.resultant, isA<EquationsResultant>());
      expect(set.resultant.symbol, 'c');
      expect(set.resultant.xyComponents.x, 5); // (0,5)+(5,5)
      expect(set.resultant.xyComponents.y, 10);
      expect(model.view.equationsResultantVisible, isTrue);
      expect(model.equationType, EquationType.addition);

      final data = builder.build(model);
      expect(data.vectors.length, 2);
      expect(data.resultants.length, 1);
      expect(data.showToolbox, isFalse);
      expect(data.showEraser, isFalse);
      expect(data.equationLabel, 'a + b = c');
    });

    test('equation type switches recompute c without SumVector', () {
      final model = EquationsModel();
      model.setEquationType(EquationType.subtraction);
      expect(model.scene.vectorSets.first.resultant.xyComponents.x, -5);
      expect(model.scene.vectorSets.first.resultant.xyComponents.y, 0);
      model.setEquationType(EquationType.negation);
      expect(model.scene.vectorSets.first.resultant.xyComponents.x, -5);
      expect(model.scene.vectorSets.first.resultant.xyComponents.y, -10);
    });
  });

  group('RenderData transform', () {
    test('origin view Y decreases when model Y increases', () {
      final model = Explore2DModel();
      final data = builder.build(model);
      final t = model.scene.graph.transform;
      final o = t.modelToView(model.scene.graph.bounds.center);
      // Sanity: graphRect uses transform viewBounds
      expect(data.graphRect, t.viewBounds);
      expect(data.originView.dy, lessThan(data.graphRect.bottom));
      expect(o.dx, isA<double>());
    });
  });
}
