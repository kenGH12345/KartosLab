import 'package:flutter/foundation.dart';

import '../gflb_colors.dart';
import '../gflb_constants.dart';
import '../solver/force_solver.dart';
import 'mass_model.dart';

/// Root model — PhET `GFLBModel` + ISLC snap / separation / step push.
///
/// During mass drag, position updates bump [paintEpoch] but do **not** call
/// [notifyListeners] (avoids cancelling the active gesture).
class GravityModel extends ChangeNotifier {
  GravityModel() {
    mass1 = MassModel(
      value: GflbConstants.initialMass1,
      positionX: GflbConstants.initialPosition1,
      baseColor: GflbColors.mass1Base,
      constantSizeGetter: () => constantSize,
    );
    mass2 = MassModel(
      value: GflbConstants.initialMass2,
      positionX: GflbConstants.initialPosition2,
      baseColor: GflbColors.mass2Base,
      constantSizeGetter: () => constantSize,
    );
    _updateEnabledRanges();
  }

  late final MassModel mass1;
  late final MassModel mass2;

  bool constantSize = GflbConstants.defaultConstantSize;
  bool showForceValues = GflbConstants.defaultShowForceValues;
  bool showDistance = GflbConstants.defaultShowDistance;

  /// Which mass last grew in radius (for step push semantics).
  int? radiusLastChanged; // 1 or 2

  final ValueNotifier<int> paintEpoch = ValueNotifier<int>(0);

  double get separation => (mass2.positionX - mass1.positionX).abs();

  double get force => ForceSolver.calculateForce(
        mass1.value,
        mass2.value,
        separation,
      );

  double get forceMagnitude => force.abs();

  /// Force on mass1 is toward mass2 (positive X when mass2 is to the right).
  double get forceOnMass1Sign {
    if (mass2.positionX >= mass1.positionX) return 1;
    return -1;
  }

  double get forceOnMass2Sign => -forceOnMass1Sign;

  double get minForceMagnitude => ForceSolver.getMinForceMagnitude();
  double get maxForce => ForceSolver.getMaxForce();

  double mass1EnabledMin = -GflbConstants.pullPositionMax;
  double mass1EnabledMax = GflbConstants.pullPositionMax;
  double mass2EnabledMin = -GflbConstants.pullPositionMax;
  double mass2EnabledMax = GflbConstants.pullPositionMax;

  bool get _anyDragging => mass1.isDragging || mass2.isDragging;

  void _bumpPaint({bool structural = false}) {
    paintEpoch.value++;
    if (structural || !_anyDragging) {
      notifyListeners();
    }
  }

  void setConstantSize(bool value) {
    if (constantSize == value) return;
    constantSize = value;
    // Radius change may require push.
    radiusLastChanged = 1;
    step();
    _bumpPaint(structural: true);
  }

  void setShowForceValues(bool value) {
    if (showForceValues == value) return;
    showForceValues = value;
    notifyListeners();
  }

  void setShowDistance(bool value) {
    if (showDistance == value) return;
    showDistance = value;
    notifyListeners();
  }

  void setMassValue(int which, double value) {
    final m = which == 1 ? mass1 : mass2;
    final clamped = value.clamp(GflbConstants.massMin, GflbConstants.massMax);
    if (m.value == clamped) return;
    final oldRadius = m.radius;
    m.value = clamped;
    if (m.radius > oldRadius + 1e-9) {
      radiusLastChanged = which;
      step();
    } else {
      _updateEnabledRanges();
    }
    _bumpPaint(structural: true);
  }

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

  /// Drag update — snap + clamp; paint only (no notifyListeners).
  void setPositionWhileDragging(int which, double modelX) {
    final snapped = ForceSolver.snapToGrid(modelX);
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
    final snapped = ForceSolver.snapToGrid(modelX);
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

  double getSumRadiusWithSeparation() {
    return ForceSolver.snapToGrid(
      mass1.radius + mass2.radius + GflbConstants.minDistanceBetweenMasses,
    );
  }

  void _updateEnabledRanges() {
    final sum = getSumRadiusWithSeparation();
    mass1EnabledMin = -GflbConstants.pullPositionMax;
    mass1EnabledMax = ForceSolver.snapToGrid(mass2.positionX - sum);
    mass2EnabledMin = ForceSolver.snapToGrid(mass1.positionX + sum);
    mass2EnabledMax = GflbConstants.pullPositionMax;
  }

  /// ISLCModel.step — keep within bounds / separation; push when radius grows.
  void step() {
    _updateEnabledRanges();

    var p1 = mass1.positionX;
    var p2 = mass2.positionX;

    p1 = p1.clamp(mass1EnabledMin, mass1EnabledMax).toDouble();
    p2 = p2.clamp(mass2EnabledMin, mass2EnabledMax).toDouble();
    p1 = ForceSolver.snapToGrid(p1);
    p2 = ForceSolver.snapToGrid(p2);

    if (mass1.isDragging) {
      mass1.positionX = p1;
    } else if (mass2.isDragging) {
      mass2.positionX = p2;
    } else if (radiusLastChanged == 1) {
      if (mass2.positionX < GflbConstants.pullPositionMax) {
        if (p2 != mass2.positionX) mass2.positionX = p2;
      } else {
        if (p1 != mass1.positionX) mass1.positionX = p1;
      }
    } else if (radiusLastChanged == 2) {
      if (mass1.positionX > -GflbConstants.pullPositionMax) {
        if (p1 != mass1.positionX) mass1.positionX = p1;
      } else {
        if (p2 != mass2.positionX) mass2.positionX = p2;
      }
    } else {
      mass1.positionX = p1;
      mass2.positionX = p2;
    }

    _updateEnabledRanges();
    // Re-clamp after range update (mutual dependency).
    mass1.positionX =
        mass1.positionX.clamp(mass1EnabledMin, mass1EnabledMax).toDouble();
    mass2.positionX =
        mass2.positionX.clamp(mass2EnabledMin, mass2EnabledMax).toDouble();
    _updateEnabledRanges();
  }

  void reset() {
    constantSize = GflbConstants.defaultConstantSize;
    showForceValues = GflbConstants.defaultShowForceValues;
    showDistance = GflbConstants.defaultShowDistance;
    radiusLastChanged = null;
    mass1.reset(
      value: GflbConstants.initialMass1,
      positionX: GflbConstants.initialPosition1,
    );
    mass2.reset(
      value: GflbConstants.initialMass2,
      positionX: GflbConstants.initialPosition2,
    );
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
