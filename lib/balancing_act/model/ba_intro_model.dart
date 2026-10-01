import '../ba_shared_constants.dart';
import 'ba_mass.dart';
import 'ba_vector2.dart';
import 'balance_model.dart';

/// Approximate visible model-X range for Intro drop-off-stage check.
/// Derived from Intro/Lab MVT: origin at (width*0.375, …), scale 105.
abstract final class BaIntroViewport {
  static double get modelXMin =>
      (0 - BaSharedConstants.layoutWidth *
              BaSharedConstants.introLabOriginViewXFactor) /
      BaSharedConstants.introLabMvtScale;

  static double get modelXMax =>
      (BaSharedConstants.layoutWidth -
              BaSharedConstants.layoutWidth *
                  BaSharedConstants.introLabOriginViewXFactor) /
      BaSharedConstants.introLabMvtScale;
}

/// Source: `js/intro/model/BAIntroModel.ts` + drop logic from `BAIntroView.ts`.
class BAIntroModel extends BalanceModel {
  BAIntroModel() {
    fireExtinguisher1 = BaMass.fromType(
      BaMassType.fireExtinguisher,
      const BaVector2(2.7, 0),
    );
    fireExtinguisher2 = BaMass.fromType(
      BaMassType.fireExtinguisher,
      const BaVector2(3.2, 0),
    );
    smallTrashCan = BaMass.fromType(
      BaMassType.smallTrashCan,
      const BaVector2(3.7, 0),
    );
    addMass(fireExtinguisher1);
    addMass(fireExtinguisher2);
    addMass(smallTrashCan);
  }

  late final BaMass fireExtinguisher1;
  late final BaMass fireExtinguisher2;
  late final BaMass smallTrashCan;

  @override
  bool endDrag(BaMass mass) {
    mass.userControlled = false;
    userControlledMasses.remove(mass);
    if (plank.addMassToSurface(mass)) {
      return true;
    }
    // Intro View miss semantics (ported into model for Phase 1).
    final x = mass.position.x;
    if (x > BaIntroViewport.modelXMin && x < BaIntroViewport.modelXMax) {
      mass.position = BaVector2(x, 0);
    } else {
      mass.reset();
    }
    return false;
  }

  @override
  void reset() {
    for (final mass in massList) {
      mass.reset();
    }
    super.reset();
  }
}
