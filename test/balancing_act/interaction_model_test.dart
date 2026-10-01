import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  group('Drag / drop', () {
    test('during drag position is continuous (not snapped)', () {
      final model = BAIntroModel();
      final mass = model.fireExtinguisher1;
      model.beginDrag(mass);
      model.dragMassTo(mass, const BaVector2(0.37, 1.2));
      expect(mass.position.x, 0.37);
      expect(mass.onPlank, isFalse);
    });

    test('release over open slot snaps', () {
      final model = BAIntroModel();
      final mass = model.fireExtinguisher1;
      model.beginDrag(mass);
      model.dragMassTo(mass, const BaVector2(1.0, 0.9));
      expect(model.endDrag(mass), isTrue);
      expect(mass.position.x, closeTo(1.0, 1e-12));
      expect(mass.onPlank, isTrue);
    });

    test('Intro miss in viewport drops to y=0', () {
      final model = BAIntroModel();
      final mass = model.fireExtinguisher1;
      model.beginDrag(mass);
      model.dragMassTo(mass, const BaVector2(3.0, 0.5));
      expect(model.endDrag(mass), isFalse);
      expect(mass.position.y, 0);
      expect(mass.position.x, 3.0);
    });

    test('pick up from plank removes from surface', () {
      final model = BAIntroModel();
      final mass = model.fireExtinguisher1;
      model.beginDrag(mass);
      model.dragMassTo(mass, const BaVector2(-1.0, 0.9));
      model.endDrag(mass);
      expect(mass.onPlank, isTrue);
      model.beginDrag(mass);
      expect(mass.onPlank, isFalse);
      expect(model.plank.massesOnSurface.contains(mass), isFalse);
    });

    test('Lab miss triggers animated remove', () {
      final model = BalanceLabModel();
      final mass = model.createBrickStack(1, const BaVector2(3.0, 0.5));
      expect(model.endDrag(mass), isFalse);
      expect(mass.animating, isTrue);
      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      expect(model.massList.contains(mass), isFalse);
    });
  });

  group('ABSwitch (supports)', () {
    test('A=DOUBLE B=NO and round-trip', () {
      final model = BalanceModel();
      expect(model.supportsEnabled, isTrue);
      expect(model.columnState, ColumnState.doubleColumns);

      model.setSupportsEnabled(false);
      expect(model.columnState, ColumnState.noColumns);
      expect(model.supportsEnabled, isFalse);

      final m = BaMass.generic(40, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(m, 1.5);
      model.step(1 / 60);
      expect(model.plank.tiltAngle.abs(), greaterThan(0));

      model.setSupportsEnabled(true);
      expect(model.columnState, ColumnState.doubleColumns);
      expect(model.plank.tiltAngle, 0);
      expect(model.plank.angularVelocity, 0);
    });
  });

  group('Show / Position', () {
    test('defaults and reset', () {
      final props = BalanceViewProperties();
      expect(props.massLabelsVisible, isTrue);
      expect(props.forceVectorsFromObjectsVisible, isFalse);
      expect(props.levelIndicatorVisible, isFalse);
      expect(props.positionMarkerState, PositionIndicatorChoice.none);

      props.massLabelsVisible = false;
      props.forceVectorsFromObjectsVisible = true;
      props.levelIndicatorVisible = true;
      props.positionMarkerState = PositionIndicatorChoice.rulers;
      props.reset();
      expect(props.massLabelsVisible, isTrue);
      expect(props.forceVectorsFromObjectsVisible, isFalse);
      expect(props.levelIndicatorVisible, isFalse);
      expect(props.positionMarkerState, PositionIndicatorChoice.none);
    });
  });

  group('Carousel', () {
    test('pages boundary no wrap', () {
      final carousel = LabCarouselState();
      expect(carousel.pageCount, 5);
      expect(carousel.currentPage, LabCarouselPage.bricks);
      carousel.previousPage();
      expect(carousel.pageIndex, 0);
      for (var i = 0; i < 10; i++) {
        carousel.nextPage();
      }
      expect(carousel.pageIndex, 4);
      expect(carousel.currentPage, LabCarouselPage.mystery2);
      carousel.reset();
      expect(carousel.pageIndex, 0);
    });
  });

  group('Reset All', () {
    test('Intro resets masses, angle, columns', () {
      final model = BAIntroModel();
      final props = BalanceViewProperties()
        ..massLabelsVisible = false
        ..positionMarkerState = PositionIndicatorChoice.marks;

      model.beginDrag(model.fireExtinguisher1);
      model.dragMassTo(model.fireExtinguisher1, const BaVector2(-1.5, 0.9));
      model.endDrag(model.fireExtinguisher1);
      model.setSupportsEnabled(false);
      model.step(1 / 60);

      model.reset();
      props.reset();

      expect(model.fireExtinguisher1.position, const BaVector2(2.7, 0));
      expect(model.fireExtinguisher2.position, const BaVector2(3.2, 0));
      expect(model.smallTrashCan.position, const BaVector2(3.7, 0));
      expect(model.plank.massesOnSurface, isEmpty);
      expect(model.columnState, ColumnState.doubleColumns);
      expect(model.plank.tiltAngle, 0);
      expect(model.plank.angularVelocity, 0);
      expect(props.massLabelsVisible, isTrue);
      expect(props.positionMarkerState, PositionIndicatorChoice.none);
    });

    test('Lab reset clears dynamic masses and carousel', () {
      final model = BalanceLabModel();
      model.carousel.nextPage();
      model.createBrickStack(2, const BaVector2(1.0, 0.9));
      model.endDrag(model.massList.single);
      model.reset();
      expect(model.massList, isEmpty);
      expect(model.carousel.pageIndex, 0);
    });
  });

  group('Mass catalog', () {
    test('Intro seed masses', () {
      final model = BAIntroModel();
      expect(model.fireExtinguisher1.massValue, 5);
      expect(model.fireExtinguisher2.massValue, 5);
      expect(model.smallTrashCan.massValue, 10);
    });

    test('brick and mystery values', () {
      expect(BaMass.brickStack(4, BaVector2.zero).massValue, 20);
      expect(BaMass.mystery(0, BaVector2.zero).massValue, 20);
      expect(BaMass.mystery(7, BaVector2.zero).massValue, 7.5);
      expect(BaMass.fromType(BaMassType.barrel, BaVector2.zero).massValue, 90);
    });
  });
}
