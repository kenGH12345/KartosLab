import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  test('Reset All restores Intro model + view properties', () {
    final c = BaIntroController();
    final m = c.model.fireExtinguisher1;
    c.beginDrag(m, c.mvt.modelToView(m.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(-1.5, 0.9)));
    c.endDrag();
    c.setSupportsEnabled(false);
    c.setMassLabelsVisible(false);
    c.setForcesVisible(true);
    c.setLevelVisible(true);
    c.setPositionChoice(PositionIndicatorChoice.rulers);
    c.model.step(1 / 60);

    c.resetAll();

    expect(c.model.fireExtinguisher1.position, const BaVector2(2.7, 0));
    expect(c.model.fireExtinguisher2.position, const BaVector2(3.2, 0));
    expect(c.model.smallTrashCan.position, const BaVector2(3.7, 0));
    expect(c.model.plank.massesOnSurface, isEmpty);
    expect(c.model.columnState, ColumnState.doubleColumns);
    expect(c.model.plank.tiltAngle, 0);
    expect(c.model.plank.angularVelocity, 0);
    expect(c.viewProperties.massLabelsVisible, isTrue);
    expect(c.viewProperties.forceVectorsFromObjectsVisible, isFalse);
    expect(c.viewProperties.levelIndicatorVisible, isFalse);
    expect(
      c.viewProperties.positionMarkerState,
      PositionIndicatorChoice.none,
    );
    c.dispose();
  });

  testWidgets('Reset All button fires reset', (tester) async {
    final c = BaIntroController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaIntroScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();

    c.beginDrag(
      c.model.fireExtinguisher1,
      c.mvt.modelToView(c.model.fireExtinguisher1.position),
    );
    c.updateDrag(c.mvt.modelToView(const BaVector2(1.0, 0.9)));
    c.endDrag();
    expect(c.model.plank.massesOnSurface, isNotEmpty);

    await tester.tap(find.byKey(const Key('ba_intro_reset_all')));
    await tester.pump();
    expect(c.model.plank.massesOnSurface, isEmpty);
    expect(c.model.fireExtinguisher1.position, const BaVector2(2.7, 0));
    c.dispose();
  });
}
