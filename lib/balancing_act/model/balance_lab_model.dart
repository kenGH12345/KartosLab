import 'ba_enums.dart';
import 'ba_mass.dart';
import 'ba_vector2.dart';
import 'balance_model.dart';

/// Lab MassCarousel pages. Source: `MassCarousel.ts` (non-stanford).
enum LabCarouselPage {
  bricks,
  people1,
  people2,
  mystery1,
  mystery2,
}

/// Carousel index state — no UI; page wrap follows sun/Carousel itemsPerPage=1.
class LabCarouselState {
  LabCarouselState({
    this.pages = const [
      LabCarouselPage.bricks,
      LabCarouselPage.people1,
      LabCarouselPage.people2,
      LabCarouselPage.mystery1,
      LabCarouselPage.mystery2,
    ],
  });

  final List<LabCarouselPage> pages;
  int pageIndex = 0;

  LabCarouselPage get currentPage => pages[pageIndex];

  int get pageCount => pages.length;

  void nextPage() {
    if (pageIndex < pages.length - 1) {
      pageIndex++;
    }
  }

  void previousPage() {
    if (pageIndex > 0) {
      pageIndex--;
    }
  }

  void reset() {
    pageIndex = 0;
  }
}

/// Source: `js/balancelab/model/BalanceLabModel.ts`
class BalanceLabModel extends BalanceModel {
  final LabCarouselState carousel = LabCarouselState();
  final List<BaMass> _pendingRemoveAfterAnimation = [];

  /// Create brick stack from toolbox (creator semantics without view).
  BaMass createBrickStack(int numBricks, BaVector2 position) {
    final mass = BaMass.brickStack(numBricks, position);
    mass.animationDestination = position;
    mass.userControlled = true;
    addMass(mass);
    beginDrag(mass);
    return mass;
  }

  BaMass createMystery(int mysteryMassId, BaVector2 position) {
    final mass = BaMass.mystery(mysteryMassId, position);
    mass.animationDestination = position;
    mass.userControlled = true;
    addMass(mass);
    beginDrag(mass);
    return mass;
  }

  BaMass createPerson(BaMassType type, BaVector2 position) {
    final mass = BaMass.fromType(type, position);
    mass.animationDestination = position;
    mass.userControlled = true;
    addMass(mass);
    beginDrag(mass);
    return mass;
  }

  @override
  bool endDrag(BaMass mass) {
    mass.userControlled = false;
    userControlledMasses.remove(mass);
    if (plank.addMassToSurface(mass)) {
      return true;
    }
    removeMassAnimated(mass);
    return false;
  }

  void removeMassAnimated(BaMass mass) {
    mass.animationDestination ??= mass.position;
    mass.initiateAnimation();
    _pendingRemoveAfterAnimation.add(mass);
  }

  @override
  void step(double dt) {
    super.step(dt);
    final finished = <BaMass>[];
    for (final mass in _pendingRemoveAfterAnimation) {
      if (!mass.animating) {
        finished.add(mass);
      }
    }
    for (final mass in finished) {
      _pendingRemoveAfterAnimation.remove(mass);
      removeMass(mass);
    }
  }

  @override
  void reset() {
    super.reset();
    final copy = List<BaMass>.from(massList);
    for (final mass in copy) {
      removeMass(mass);
    }
    carousel.reset();
    _pendingRemoveAfterAnimation.clear();
  }
}

/// Show / Position view properties. Source: `BasicBalanceScreenView.viewProperties`.
class BalanceViewProperties {
  bool massLabelsVisible = true;
  bool forceVectorsFromObjectsVisible = false;
  bool levelIndicatorVisible = false;
  PositionIndicatorChoice positionMarkerState = PositionIndicatorChoice.none;

  void reset() {
    massLabelsVisible = true;
    forceVectorsFromObjectsVisible = false;
    levelIndicatorVisible = false;
    positionMarkerState = PositionIndicatorChoice.none;
  }
}
