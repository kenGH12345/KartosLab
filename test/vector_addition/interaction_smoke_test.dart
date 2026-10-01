import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/interaction/va_graph_interactor.dart';
import 'package:kratos/vector_addition/model/resultant_vector.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/render/va_render_builder.dart';

void main() {
  test('toolbox activate drops vector on graph and updates sum', () {
    final model = Explore2DModel();
    final interactor = VaGraphInteractor(model);
    expect(interactor.activateFromToolbox(0), isTrue);
    final set = model.scene.vectorSets.single;
    expect(set.allVectors.first.isOnGraph, isTrue);
    expect(set.activeVectors, isNotEmpty);
    (set.resultant as SumVector).recompute();
    expect(set.resultant.isDefined, isTrue);

    model.view.sumVisible = true;
    final data = const VaRenderBuilder().build(model);
    expect(data.vectors, isNotEmpty);
    expect(data.resultants, isNotEmpty);
  });

  test('equations tip not draggable', () {
    final model = EquationsModel();
    for (final v in model.scene.vectorSets.single.allVectors) {
      expect(v.isTipDraggable, isFalse);
    }
    expect(model.scene.vectorSets.single.resultant.isTipDraggable, isFalse);
  });
}
