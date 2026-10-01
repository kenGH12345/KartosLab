import 'dart:ui' show Offset, Rect;

import 'package:flutter/foundation.dart';

import '../faradays_law_constants.dart';
import 'bulb_model.dart';
import 'coil.dart';
import 'field_lines.dart';
import 'magnet.dart';
import 'voltmeter_model.dart';

/// PhET `FaradaysLawModel.js` — single-screen root model.
///
/// Data chain:
/// ```
/// Magnet.position + orientation
///   → Coil B → EMF = N·ΔB/dt
///   → signal = 0.2·Σemf → voltage (needle) → bulb |voltage|
/// ```
///
/// View layering (for later phases; not painted here):
/// coil back → magnet (+ field lines) → coil front.
class FaradaysLawModel extends ChangeNotifier {
  FaradaysLawModel() {
    magnet = Magnet();
    bottomCoil = Coil(
      position: FaradaysLawConstants.bottomCoilPosition,
      numberOfSpirals: FaradaysLawConstants.bottomCoilSpirals,
      magnet: magnet,
    );
    topCoil = Coil(
      position: FaradaysLawConstants.topCoilPosition,
      numberOfSpirals: FaradaysLawConstants.topCoilSpirals,
      magnet: magnet,
    );
    voltmeter = VoltmeterModel();
    bulb = BulbModel(voltageGetter: () => voltage);
    fieldLines = FieldLinesModel(
      visibleGetter: () => magnet.fieldLinesVisible,
      magnetPositionGetter: () => magnet.position,
      orientationGetter: () => magnet.orientation,
    );
    _buildRestrictedBounds();
  }

  late final Magnet magnet;
  late final Coil bottomCoil;
  late final Coil topCoil;
  late final VoltmeterModel voltmeter;
  late final BulbModel bulb;
  late final FieldLinesModel fieldLines;

  /// Dual-coil mode: top 2-spiral visible (`topCoilVisibleProperty`).
  bool topCoilVisible = false;

  /// Drag hint arrows (`magnetArrowsVisibleProperty`).
  bool magnetArrowsVisible = true;

  bool voltmeterVisible = false;

  bool resetInProgress = false;

  late final List<Rect> topCoilRestrictedBounds;
  late final List<Rect> bottomCoilRestrictedBounds;

  Rect get bounds => FaradaysLawConstants.layoutBounds;

  /// Root voltage — drives needle angle and bulb brightness.
  double get voltage => voltmeter.voltage;

  double get needleAngle => voltmeter.needleAngle;

  void _buildRestrictedBounds() {
    final top = FaradaysLawConstants.topCoilPosition;
    final bottom = FaradaysLawConstants.bottomCoilPosition;
    const h = FaradaysLawConstants.coilRestrictedAreaHeight;
    const topW = FaradaysLawConstants.topCoilRestrictedAreaWidth;
    const bottomW = FaradaysLawConstants.bottomCoilRestrictedAreaWidth;

    topCoilRestrictedBounds = [
      Rect.fromLTWH(top.dx - 7, top.dy - 77, topW, h),
      Rect.fromLTWH(top.dx, top.dy + 65, topW, h),
    ];
    bottomCoilRestrictedBounds = [
      Rect.fromLTWH(bottom.dx - 31, bottom.dy - 77, bottomW, h),
      Rect.fromLTWH(bottom.dx - 23, bottom.dy + 65, bottomW, h),
    ];
  }

  List<Rect> get activeRestrictedBounds {
    if (topCoilVisible) {
      return [...bottomCoilRestrictedBounds, ...topCoilRestrictedBounds];
    }
    return List<Rect>.from(bottomCoilRestrictedBounds);
  }

  /// Joist `maxDT: 0.1` — clamp before stepping. `dt <= 0` is a no-op.
  void step(double dt) {
    if (dt <= 0) return;
    final stepped = dt > FaradaysLawConstants.maxDt
        ? FaradaysLawConstants.maxDt
        : dt;

    bottomCoil.step(stepped);
    if (topCoilVisible) {
      topCoil.step(stepped);
    }
    voltmeter.step(
      bottomCoil: bottomCoil,
      topCoil: topCoil,
      dt: stepped,
    );
    notifyListeners();
  }

  void setTopCoilVisible(bool visible) {
    if (topCoilVisible == visible) return;
    topCoilVisible = visible;
    if (visible && _magnetIntersectsTopCoilArea()) {
      magnet.position = FaradaysLawConstants.defaultMagnetPosition;
    }
    topCoil.reset();
    notifyListeners();
  }

  void setVoltmeterVisible(bool visible) {
    if (voltmeterVisible == visible) return;
    voltmeterVisible = visible;
    notifyListeners();
  }

  void setFieldLinesVisible(bool visible) {
    if (magnet.fieldLinesVisible == visible) return;
    magnet.fieldLinesVisible = visible;
    notifyListeners();
  }

  void flipPolarity() {
    magnet.flipPolarity();
    notifyListeners();
  }

  /// Attempt to move magnet; clamps against layout bounds and coil obstacles.
  void moveMagnetToPosition(Offset proposedPosition) {
    final translation = proposedPosition - magnet.position;
    final allowed = _checkProposedMagnetMotion(translation);
    magnet.position = magnet.position + allowed;
    magnetArrowsVisible = false;
    notifyListeners();
  }

  /// Unconstrained position set for physics regression tests only.
  @visibleForTesting
  void setMagnetPositionForTest(Offset position) {
    magnet.position = position;
    notifyListeners();
  }

  Offset _checkProposedMagnetMotion(Offset proposedTranslation) {
    var remaining = proposedTranslation;
    final restricted = activeRestrictedBounds;

    // Iteratively clamp against layout then restricted AABBs (source intent).
    remaining = _clampTranslationToLayout(remaining);
    for (final obstacle in restricted) {
      remaining = _limitTranslationAgainstObstacle(remaining, obstacle);
    }
    remaining = _clampTranslationToLayout(remaining);
    return remaining;
  }

  Offset _clampTranslationToLayout(Offset translation) {
    final proposedCenter = magnet.position + translation;
    final halfW = magnet.width / 2;
    final halfH = magnet.height / 2;
    final minX = bounds.left + halfW;
    final maxX = bounds.right - halfW;
    final minY = bounds.top + halfH;
    final maxY = bounds.bottom - halfH;
    final clamped = Offset(
      proposedCenter.dx.clamp(minX, maxX),
      proposedCenter.dy.clamp(minY, maxY),
    );
    return clamped - magnet.position;
  }

  Offset _limitTranslationAgainstObstacle(
    Offset translation,
    Rect obstacle,
  ) {
    if (translation == Offset.zero) return translation;

    final current = magnet.bounds;
    final proposed = current.shift(translation);
    if (!proposed.overlaps(obstacle)) {
      return translation;
    }

    // Binary-search scale of translation that avoids overlap (stable for tests).
    var lo = 0.0;
    var hi = 1.0;
    for (var i = 0; i < 16; i++) {
      final mid = (lo + hi) / 2;
      final trial = current.shift(translation * mid);
      if (trial.overlaps(obstacle)) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return translation * lo;
  }

  bool _magnetIntersectsTopCoilArea() {
    final magnetBounds = magnet.bounds;
    return magnetBounds.overlaps(topCoilRestrictedBounds[0]) ||
        magnetBounds.overlaps(topCoilRestrictedBounds[1]);
  }

  /// Full reset to source initial state.
  ///
  /// VERSION_DELTA (VD-02): also clears [voltage] / needle dynamics immediately
  /// so Model initial state is deterministic (source relies on damping after
  /// coil EMF reset).
  void reset() {
    resetInProgress = true;
    magnet.reset();
    topCoilVisible = false;
    magnetArrowsVisible = true;
    bottomCoil.reset();
    topCoil.reset();
    voltmeterVisible = false;
    voltmeter.reset();
    resetInProgress = false;
    notifyListeners();
  }
}
