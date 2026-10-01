import 'dart:math' as math;

import '../vector_addition_constants.dart';
import 'angle_convention_utils.dart';
import 'enums.dart';
import 'va_vec.dart';

/// Abstract base for all vector models.
///
/// **Canonical (ground truth):** [tailPosition] + [xyComponents].
/// **Derived:** tip, magnitude, angle — never stored as SSOT.
///
/// Mirrors PhET `RootVector.ts`.
class RootVector {
  RootVector({
    required VaVec tailPosition,
    required VaVec xyComponents,
    this.symbol = '',
  })  : _initialTail = tailPosition,
        _initialXy = xyComponents,
        tailPosition = tailPosition,
        xyComponents = xyComponents;

  final VaVec _initialTail;
  final VaVec _initialXy;
  final String symbol;

  /// Initial canonical state (toolbox / reset target).
  VaVec get initialTailPosition => _initialTail;
  VaVec get initialXyComponents => _initialXy;

  /// Canonical: tail in model coordinates.
  VaVec tailPosition;

  /// Canonical: (dx, dy) components.
  VaVec xyComponents;

  double get xComponent => xyComponents.x;
  double get yComponent => xyComponents.y;

  /// Derived: tip = tail + xyComponents.
  VaVec get tip => tailPosition + xyComponents;

  double get tipX => tip.x;
  double get tipY => tip.y;
  double get tailX => tailPosition.x;
  double get tailY => tailPosition.y;

  /// Derived magnitude.
  double get magnitude => xyComponents.magnitude;

  /// Derived angle in radians (atan2). Null when effectively zero magnitude.
  double? get angle {
    if (xyComponents.equalsEpsilon(VaVec.zero, 1e-7)) return null;
    return xyComponents.angle;
  }

  double? getAngleDegrees(AngleConvention convention) {
    final rad = angle;
    if (rad == null) return null;
    var deg = rad * 180 / math.pi;
    if (convention == AngleConvention.unsigned) {
      deg = AngleConventionUtils.signedToUnsignedDegrees(
        deg.clamp(
          VectorAdditionConstants.signedAngleMin.toDouble(),
          VectorAdditionConstants.signedAngleMax.toDouble(),
        ),
      );
    }
    return deg;
  }

  /// Keep tip constant; change magnitude as side effect.
  void setTailXY(double x, double y) {
    final t = tip;
    tailPosition = VaVec(x, y);
    setTip(t);
  }

  void setTail(VaVec tail) => setTailXY(tail.x, tail.y);

  /// Keep tail constant; update xyComponents.
  void setTipXY(double x, double y) {
    final newTip = VaVec(x, y);
    xyComponents = xyComponents + (newTip - tip);
  }

  void setTip(VaVec tip) => setTipXY(tip.x, tip.y);

  bool hasZeroComponent() =>
      xComponent.abs() < VectorAdditionConstants.zeroThreshold ||
      yComponent.abs() < VectorAdditionConstants.zeroThreshold;

  void reset() {
    tailPosition = _initialTail;
    xyComponents = _initialXy;
  }

  /// Prefer [AngleConventionUtils.signedToUnsignedDegrees] (PhET Utils: 0→0).
  static double signedToUnsignedDegrees(double signed) =>
      AngleConventionUtils.signedToUnsignedDegrees(
        signed.clamp(
          VectorAdditionConstants.signedAngleMin.toDouble(),
          VectorAdditionConstants.signedAngleMax.toDouble(),
        ),
      );
}
