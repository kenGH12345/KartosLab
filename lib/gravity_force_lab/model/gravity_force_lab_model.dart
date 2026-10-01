import 'package:flutter/foundation.dart';

import 'force_notation.dart';
import 'force_solver.dart';
import 'force_values_display.dart';
import 'gravity_force_constants.dart';
import 'mass_model.dart';
import 'ruler_model.dart';

/// Which mass was last pushed by a radius change (ISLCObjectEnum).
enum PushedObject {
  object1,
  object2,
}

/// Root model — PhET `GravityForceLabModel` + `ISLCModel`.
///
/// Units: mass kg, distance m, force N. Independent of Basics.
class GravityForceLabModel extends ChangeNotifier {
  GravityForceLabModel() {
    mass1 = MassModel(
      value: GravityForceConstants.initialMass1,
      positionX: GravityForceConstants.initialPosition1,
      baseColor: GravityForceConstants.mass1BaseColor,
      constantRadiusGetter: () => constantRadius,
    );
    mass2 = MassModel(
      value: GravityForceConstants.initialMass2,
      positionX: GravityForceConstants.initialPosition2,
      baseColor: GravityForceConstants.mass2BaseColor,
      constantRadiusGetter: () => constantRadius,
    );
    ruler = RulerModel();
    _updateEnabledRanges();
  }

  late final MassModel mass1;
  late final MassModel mass2;
  late final RulerModel ruler;

  /// PhET `constantRadiusProperty` (UI: Constant Size).
  bool constantRadius = GravityForceConstants.defaultConstantRadius;

  /// PhET `forceValuesDisplayProperty` — source of truth for notation.
  ForceValuesDisplay forceValuesDisplay = ForceValuesDisplay.decimal;

  /// Derived from [forceValuesDisplay] (not an independent source of truth).
  bool get showForceValues =>
      ForceNotationFormatter.showForceValues(forceValuesDisplay);

  /// Which object was pushed by a radius increase (ISLCModel.pushedObjectEnumProperty).
  PushedObject? pushedObject;

  /// Which mass last grew in radius (for step push semantics).
  int? radiusLastChanged; // 1 or 2

  final ValueNotifier<int> paintEpoch = ValueNotifier<int>(0);

  // —— Derived physics ——

  /// Center-to-center separation (m).
  double get distance => (mass2.positionX - mass1.positionX).abs();

  double get force => ForceSolver.calculateForce(
        mass1.value,
        mass2.value,
        distance,
      );

  double get forceMagnitude => force.abs();

  /// Force on mass1 is toward mass2 (+X when mass2 is to the right).
  double get forceOnMass1Sign {
    if (mass2.positionX >= mass1.positionX) return 1;
    return -1;
  }

  double get forceOnMass2Sign => -forceOnMass1Sign;

  double get radius1 => mass1.radius;
  double get radius2 => mass2.radius;

  double get minForceMagnitude => ForceSolver.getMinForceMagnitude();
  double get maxForce => ForceSolver.getMaxForce();

  double mass1EnabledMin = -GravityForceConstants.pullPositionMax;
  double mass1EnabledMax = GravityForceConstants.pullPositionMax;
  double mass2EnabledMin = -GravityForceConstants.pullPositionMax;
  double mass2EnabledMax = GravityForceConstants.pullPositionMax;

  bool get _anyDragging => mass1.isDragging || mass2.isDragging;

  void _bumpPaint({bool structural = false}) {
    paintEpoch.value++;
    if (structural || !_anyDragging) {
      notifyListeners();
    }
  }

  // —— Force values display ——

  void setForceValuesDisplay(ForceValuesDisplay value) {
    if (forceValuesDisplay == value) return;
    forceValuesDisplay = value;
    notifyListeners();
  }

  // —— Constant Size ——

  void setConstantRadius(bool value) {
    if (constantRadius == value) return;
    constantRadius = value;
    mass1.constantRadiusChangedSinceLastStep = true;
    mass2.constantRadiusChangedSinceLastStep = true;
    radiusLastChanged = 1;
    mass1.radiusLastChanged = true;
    mass2.radiusLastChanged = false;
    step();
    _bumpPaint(structural: true);
  }

  // —— Mass ——

  void setMassValue(int which, double value) {
    final m = which == 1 ? mass1 : mass2;
    final clamped = GravityForceConstants.roundMassToInterval(value);
    if (m.value == clamped) return;
    final oldRadius = m.radius;
    final oldMass = m.value;
    m.value = clamped;
    m.valueChangedSinceLastStep = true;
    if (oldMass > clamped) {
      pushedObject = null;
    }
    if (m.radius > oldRadius + 1e-12) {
      radiusLastChanged = which;
      mass1.radiusLastChanged = which == 1;
      mass2.radiusLastChanged = which == 2;
      step();
    } else {
      _updateEnabledRanges();
    }
    _bumpPaint(structural: true);
  }

  // —— Drag ——

  void beginDrag(int which) {
    if (which == 1) {
      mass1.isDragging = true;
    } else {
      mass2.isDragging = true;
    }
  }

  void endDrag(int which) {
    if (which == 1) {
      mass1.isDragging = false;
    } else {
      mass2.isDragging = false;
    }
    step();
    _bumpPaint(structural: true);
  }

  void setPositionWhileDragging(int which, double modelX) {
    final snapped = GravityForceConstants.snapToGrid(modelX);
    if (which == 1) {
      mass1.positionX =
          snapped.clamp(mass1EnabledMin, mass1EnabledMax).toDouble();
      _updateEnabledRanges();
    } else {
      mass2.positionX =
          snapped.clamp(mass2EnabledMin, mass2EnabledMax).toDouble();
      _updateEnabledRanges();
    }
    paintEpoch.value++;
  }

  void setPosition(int which, double modelX) {
    final snapped = GravityForceConstants.snapToGrid(modelX);
    if (which == 1) {
      mass1.positionX =
          snapped.clamp(mass1EnabledMin, mass1EnabledMax).toDouble();
    } else {
      mass2.positionX =
          snapped.clamp(mass2EnabledMin, mass2EnabledMax).toDouble();
    }
    _updateEnabledRanges();
    _bumpPaint(structural: true);
  }

  // —— Ruler (physics-independent) ——

  void setRulerPosition(double x, double y) {
    ruler.setPosition(x, y);
    notifyListeners();
  }

  void jumpRulerHome() {
    ruler.jumpHome();
    notifyListeners();
  }

  void jumpRulerZeroToMass1Center() {
    ruler.jumpZeroToMass1Center(mass1.positionX);
    notifyListeners();
  }

  // —— Ranges / step ——

  double getSumRadiusWithSeparation() {
    return GravityForceConstants.snapToGrid(
      mass1.radius +
          mass2.radius +
          GravityForceConstants.minSeparationBetweenObjects,
    );
  }

  void _updateEnabledRanges() {
    final sum = getSumRadiusWithSeparation();
    mass1EnabledMin = -GravityForceConstants.pullPositionMax;
    mass1EnabledMax = GravityForceConstants.snapToGrid(mass2.positionX - sum);
    mass2EnabledMin = GravityForceConstants.snapToGrid(mass1.positionX + sum);
    mass2EnabledMax = GravityForceConstants.pullPositionMax;
  }

  /// ISLCModel.step — keep within bounds / separation; push when radius grows.
  void step() {
    _updateEnabledRanges();

    var p1 = mass1.positionX;
    var p2 = mass2.positionX;

    p1 = p1.clamp(mass1EnabledMin, mass1EnabledMax).toDouble();
    p2 = p2.clamp(mass2EnabledMin, mass2EnabledMax).toDouble();
    p1 = GravityForceConstants.snapToGrid(p1);
    p2 = GravityForceConstants.snapToGrid(p2);

    final maxX = GravityForceConstants.pullPositionMax;
    final minX = -GravityForceConstants.pullPositionMax;

    if (mass1.isDragging) {
      mass1.positionX = p1;
    } else if (mass2.isDragging) {
      mass2.positionX = p2;
    } else if (mass1.radiusLastChanged || radiusLastChanged == 1) {
      if (mass2.positionX < maxX) {
        if (p2 != mass2.positionX) {
          mass2.positionX = p2;
          if (mass1.valueChangedSinceLastStep || mass2.valueChangedSinceLastStep) {
            pushedObject = PushedObject.object2;
          }
        }
      } else {
        if (p1 != mass1.positionX) {
          mass1.positionX = p1;
          if (mass1.valueChangedSinceLastStep || mass2.valueChangedSinceLastStep) {
            pushedObject = PushedObject.object1;
          }
        }
      }
    } else if (mass2.radiusLastChanged || radiusLastChanged == 2) {
      if (mass1.positionX > minX) {
        if (p1 != mass1.positionX) {
          mass1.positionX = p1;
          if (mass1.valueChangedSinceLastStep || mass2.valueChangedSinceLastStep) {
            pushedObject = PushedObject.object1;
          }
        }
      } else {
        if (p2 != mass2.positionX) {
          mass2.positionX = p2;
          if (mass1.valueChangedSinceLastStep || mass2.valueChangedSinceLastStep) {
            pushedObject = PushedObject.object2;
          }
        }
      }
    } else {
      mass1.positionX = p1;
      mass2.positionX = p2;
    }

    _updateEnabledRanges();
    mass1.positionX =
        mass1.positionX.clamp(mass1EnabledMin, mass1EnabledMax).toDouble();
    mass2.positionX =
        mass2.positionX.clamp(mass2EnabledMin, mass2EnabledMax).toDouble();
    _updateEnabledRanges();

    mass1.onStepEnd();
    mass2.onStepEnd();
  }

  void reset() {
    constantRadius = GravityForceConstants.defaultConstantRadius;
    forceValuesDisplay = ForceValuesDisplay.decimal;
    radiusLastChanged = null;
    pushedObject = null;
    ruler.reset();
    // Avoid edge case where object2 sits on object1's initial position.
    if (mass2.positionX == GravityForceConstants.initialPosition1) {
      mass2.reset(
        value: GravityForceConstants.initialMass2,
        positionX: GravityForceConstants.initialPosition2,
      );
      mass1.reset(
        value: GravityForceConstants.initialMass1,
        positionX: GravityForceConstants.initialPosition1,
      );
    } else {
      mass1.reset(
        value: GravityForceConstants.initialMass1,
        positionX: GravityForceConstants.initialPosition1,
      );
      mass2.reset(
        value: GravityForceConstants.initialMass2,
        positionX: GravityForceConstants.initialPosition2,
      );
    }
    _updateEnabledRanges();
    paintEpoch.value++;
    notifyListeners();
  }

  @override
  void dispose() {
    paintEpoch.dispose();
    super.dispose();
  }
}
