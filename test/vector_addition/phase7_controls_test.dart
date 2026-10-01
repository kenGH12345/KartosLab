import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/interaction/va_graph_interactor.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/render/va_render_builder.dart';

void main() {
  group('Vector Values accordion', () {
    test('expanded with selection exposes magnitude/angle/xy', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      final v = model.scene.vectorSets.single.activeVectors.first;
      model.view.vectorValuesExpanded = true;

      final data = const VaRenderBuilder().build(model);
      expect(data.selectedValues, isNotNull);
      expect(data.selectedValues!.symbol, v.symbol);
      expect(data.selectedValues!.magnitude, closeTo(v.magnitude, 1e-9));
      expect(data.selectedValues!.xComponent, closeTo(v.xComponent, 1e-9));
      expect(data.selectedValues!.yComponent, closeTo(v.yComponent, 1e-9));
    });

    test('no selection → selectedValues null', () {
      final model = Explore2DModel();
      model.view.vectorValuesExpanded = true;
      final data = const VaRenderBuilder().build(model);
      expect(data.selectedValues, isNull);
      expect(data.selectedSymbol, isNull);
    });
  });

  group('control panel per screen', () {
    test('Explore1D hides angles and components', () {
      final data = const VaRenderBuilder().build(Explore1DModel());
      expect(data.controlPanel.showAngles, isFalse);
      expect(data.controlPanel.showComponents, isFalse);
      expect(data.showEraser, isTrue);
      expect(data.showToolbox, isTrue);
    });

    test('Equations hides eraser/toolbox; shows equation options', () {
      final data = const VaRenderBuilder().build(EquationsModel());
      expect(data.showEraser, isFalse);
      expect(data.showToolbox, isFalse);
      expect(data.controlPanel.equationOptions, hasLength(3));
      expect(data.controlPanel.showAngles, isTrue);
    });

    test('Explore2D shows angles + components', () {
      final data = const VaRenderBuilder().build(Explore2DModel());
      expect(data.controlPanel.showAngles, isTrue);
      expect(data.controlPanel.showComponents, isTrue);
    });
  });

  group('Reset / Eraser', () {
    test('erase clears on-graph; reset restores defaults', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      interactor.activateFromToolbox(1);
      expect(model.scene.vectorSets.single.numberOnGraph, 2);

      model.view.sumVisible = true;
      model.view.valuesVisible = true;
      model.componentStyle.style = ComponentVectorStyle.triangle;

      model.erase();
      expect(model.scene.vectorSets.single.numberOnGraph, 0);
      expect(model.scene.selected, isNull);
      // Eraser does not reset view checkboxes (PhET erase ≠ resetAll).
      expect(model.view.sumVisible, isTrue);

      model.reset();
      expect(model.view.sumVisible, isFalse);
      expect(model.view.valuesVisible, isFalse);
      expect(model.componentStyle.style, ComponentVectorStyle.invisible);
      expect(model.scene.vectorSets.single.activeVectors, isEmpty);
    });

    test('Equations erase is no-op; reset restores equation type', () {
      final model = EquationsModel();
      model.setEquationType(EquationType.negation);
      model.erase();
      expect(model.scene.vectorSets.single.activeVectors, hasLength(2));
      model.reset();
      expect(model.equationType, EquationType.addition);
    });
  });

  group('scene radio', () {
    test('Explore1D switches horizontal ↔ vertical', () {
      final model = Explore1DModel();
      expect(model.scene.name, 'Horizontal');
      model.selectScene(1);
      expect(model.scene.name, 'Vertical');
      expect(model.scene.graph.orientation, GraphOrientation.vertical);
    });

    test('Explore2D switches cartesian ↔ polar snap', () {
      final model = Explore2DModel();
      expect(model.scene.coordinateSnapMode, CoordinateSnapMode.cartesian);
      model.selectScene(1);
      expect(model.scene.coordinateSnapMode, CoordinateSnapMode.polar);
    });
  });

  group('angles render flag', () {
    test('anglesVisible marks on-graph arrows showAngle', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      model.view.anglesVisible = true;
      final data = const VaRenderBuilder().build(model);
      expect(data.vectors.first.showAngle, isTrue);
    });
  });
}
