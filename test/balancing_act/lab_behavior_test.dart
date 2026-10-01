import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  test('Lab initial state: empty masses, DOUBLE columns, defaults', () {
    final c = BaBalanceLabController();
    expect(c.model.massList, isEmpty);
    expect(c.model.supportsEnabled, isTrue);
    expect(c.model.columnState, ColumnState.doubleColumns);
    expect(c.viewProperties.massLabelsVisible, isTrue);
    expect(c.viewProperties.forceVectorsFromObjectsVisible, isFalse);
    expect(c.viewProperties.levelIndicatorVisible, isFalse);
    expect(
      c.viewProperties.positionMarkerState,
      PositionIndicatorChoice.none,
    );
    expect(c.model.carousel.pageIndex, 0);
    c.dispose();
  });

  test('brick creator drag → valid snap', () {
    final c = BaBalanceLabController();
    final viewPos = c.mvt.modelToView(const BaVector2(1.0, 0.9));
    c.startBrickCreator(2, viewPos);
    expect(c.model.massList.length, 1);
    expect(c.dragging!.numBricks, 2);
    expect(c.dragging!.massValue, 10);

    c.updateDrag(c.mvt.modelToView(const BaVector2(1.0, 0.9)));
    c.endDrag();
    expect(c.dragging, isNull);
    expect(c.model.massList.single.onPlank, isTrue);
    expect(c.model.massList.single.position.x, closeTo(1.0, 1e-9));
    c.dispose();
  });

  test('occupied position rejects duplicate slot', () {
    final c = BaBalanceLabController();
    c.startBrickCreator(1, c.mvt.modelToView(const BaVector2(0.5, 0.9)));
    c.updateDrag(c.mvt.modelToView(const BaVector2(0.5, 0.9)));
    c.endDrag();
    final first = c.model.massList.single;
    expect(first.onPlank, isTrue);

    c.startBrickCreator(1, c.mvt.modelToView(const BaVector2(0.5, 0.9)));
    c.updateDrag(c.mvt.modelToView(const BaVector2(0.5, 0.9)));
    c.endDrag();
    final second = c.model.massList.last;
    if (second.onPlank) {
      expect(second.position.x, isNot(closeTo(0.5, 1e-9)));
    } else {
      expect(second.animating, isTrue);
    }
    c.dispose();
  });

  test('miss branch animates then removes', () {
    final c = BaBalanceLabController();
    c.startBrickCreator(1, c.mvt.modelToView(const BaVector2(3.0, 0.5)));
    final mass = c.dragging!;
    c.updateDrag(c.mvt.modelToView(const BaVector2(3.0, 0.5)));
    c.endDrag();
    expect(mass.animating, isTrue);
    for (var i = 0; i < 120; i++) {
      c.model.step(1 / 60);
    }
    expect(c.model.massList.contains(mass), isFalse);
    c.dispose();
  });

  test('Show / Position / AB reflect view properties', () {
    final c = BaBalanceLabController();
    c.setForcesVisible(true);
    expect(c.viewProperties.forceVectorsFromObjectsVisible, isTrue);
    c.setLevelVisible(true);
    expect(c.viewProperties.levelIndicatorVisible, isTrue);
    c.setPositionChoice(PositionIndicatorChoice.rulers);
    expect(
      c.viewProperties.positionMarkerState,
      PositionIndicatorChoice.rulers,
    );
    c.setPositionChoice(PositionIndicatorChoice.marks);
    expect(
      c.viewProperties.positionMarkerState,
      PositionIndicatorChoice.marks,
    );
    c.setSupportsEnabled(false);
    expect(c.model.columnState, ColumnState.noColumns);
    c.dispose();
  });

  test('Reset All clears masses, carousel, view properties', () {
    final c = BaBalanceLabController();
    c.nextCarouselPage();
    c.setForcesVisible(true);
    c.setPositionChoice(PositionIndicatorChoice.rulers);
    c.startBrickCreator(3, c.mvt.modelToView(const BaVector2(1.25, 0.9)));
    c.updateDrag(c.mvt.modelToView(const BaVector2(1.25, 0.9)));
    c.endDrag();
    expect(c.model.massList, isNotEmpty);

    c.resetAll();
    expect(c.model.massList, isEmpty);
    expect(c.model.carousel.pageIndex, 0);
    expect(c.viewProperties.forceVectorsFromObjectsVisible, isFalse);
    expect(
      c.viewProperties.positionMarkerState,
      PositionIndicatorChoice.none,
    );
    expect(c.model.supportsEnabled, isTrue);
    c.dispose();
  });

  test('person and mystery creators add typed masses', () {
    final c = BaBalanceLabController();
    c.startPersonCreator(
      BaMassType.boy,
      c.mvt.modelToView(const BaVector2(-1.0, 0.9)),
    );
    expect(c.dragging!.type, BaMassType.boy);
    expect(c.dragging!.massValue, 20);
    c.updateDrag(c.mvt.modelToView(const BaVector2(-1.0, 0.9)));
    c.endDrag();
    expect(c.model.massList.single.onPlank, isTrue);

    c.startMysteryCreator(2, c.mvt.modelToView(const BaVector2(1.5, 0.9)));
    expect(c.dragging!.isMystery, isTrue);
    expect(c.dragging!.mysteryMassId, 2);
    c.updateDrag(c.mvt.modelToView(const BaVector2(1.5, 0.9)));
    c.endDrag();
    expect(c.model.massList.length, 2);
    c.dispose();
  });

  test('continuous drag does not snap until release', () {
    final c = BaBalanceLabController();
    c.startBrickCreator(1, Offset.zero);
    c.updateDrag(c.mvt.modelToView(const BaVector2(0.37, 1.0)));
    expect(c.dragging!.position.x, closeTo(0.37, 0.05));
    expect(c.dragging!.onPlank, isFalse);
    c.dispose();
  });
}
