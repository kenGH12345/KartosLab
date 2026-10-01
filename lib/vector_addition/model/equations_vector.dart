import '../vector_addition_constants.dart';
import 'angle_convention_utils.dart';
import 'enums.dart';
import 'va_vec.dart';
import 'vector.dart';

/// Equations-screen vector = coefficient × baseVector.
/// Mirrors PhET `EquationsVector` — does **not** change RootVector canonical shape.
///
/// Coefficient range [-5, 5], default 1.
/// Base xy written via Cartesian (x,y) or Polar (|v|, θ°) pickers → then
/// `xyComponents = baseXy * coefficient`.
class EquationsVector extends VaVector {
  EquationsVector({
    required VaVec vectorTail,
    required VaVec baseTail,
    required VaVec baseXy,
    required super.graph,
    required super.coordinateSnapMode,
    required super.componentStyle,
    required super.symbol,
    this.coefficient = VectorAdditionConstants.coefficientDefault,
  })  : baseTailPosition = baseTail,
        _initialBaseXy = baseXy,
        _initialCoefficient = VectorAdditionConstants.coefficientDefault,
        baseX = VaVec.roundSymmetric(baseXy.x).toInt(),
        baseY = VaVec.roundSymmetric(baseXy.y).toInt(),
        baseMagnitude = VaVec.roundSymmetric(baseXy.magnitude).toInt(),
        baseAngleDegrees = _initialAngleDegrees(baseXy),
        super(
          tailPosition: vectorTail,
          xyComponents:
              baseXy * VectorAdditionConstants.coefficientDefault.toDouble(),
          isOnGraph: true,
          isTipDraggable: false,
          isRemovableFromGraph: false,
        );

  static int _initialAngleDegrees(VaVec xy) {
    if (xy.isEffectivelyZero) return 0;
    return VaVec.roundSymmetric(xy.angle * 180 / 3.141592653589793).toInt();
  }

  /// PhET `COEFFICIENT_RANGE` / default.
  int coefficient;
  final int _initialCoefficient;

  VaVec baseTailPosition;
  final VaVec _initialBaseXy;

  /// Cartesian base pickers (Integer −10…10).
  int baseX;
  int baseY;

  /// Polar base pickers.
  int baseMagnitude;
  int baseAngleDegrees;

  VaVec get baseXy {
    if (coordinateSnapMode == CoordinateSnapMode.cartesian) {
      return VaVec(baseX.toDouble(), baseY.toDouble());
    }
    final rad = baseAngleDegrees * 3.141592653589793 / 180;
    return VaVec.createPolar(baseMagnitude.toDouble(), rad);
  }

  void setCoefficient(int value) {
    coefficient = value.clamp(
      VectorAdditionConstants.coefficientMin,
      VectorAdditionConstants.coefficientMax,
    );
    _applyBaseToVector();
  }

  void setBaseX(int x) {
    baseX = x.clamp(
      VectorAdditionConstants.xyComponentMin,
      VectorAdditionConstants.xyComponentMax,
    );
    _syncPolarFromCartesian();
    _applyBaseToVector();
  }

  void setBaseY(int y) {
    baseY = y.clamp(
      VectorAdditionConstants.xyComponentMin,
      VectorAdditionConstants.xyComponentMax,
    );
    _syncPolarFromCartesian();
    _applyBaseToVector();
  }

  void setBaseMagnitude(int mag) {
    baseMagnitude = mag.clamp(
      VectorAdditionConstants.magnitudeMin,
      VectorAdditionConstants.magnitudeMax,
    );
    _syncCartesianFromPolar();
    _applyBaseToVector();
  }

  void setBaseAngleDegrees(int deg) {
    // Model ground truth is always signed [-180, 180].
    baseAngleDegrees = deg.clamp(
      VectorAdditionConstants.signedAngleMin,
      VectorAdditionConstants.signedAngleMax,
    );
    _syncCartesianFromPolar();
    _applyBaseToVector();
  }

  /// Display value for unsigned convention picker (0…355).
  int get baseAngleDegreesUnsigned {
    final u = AngleConventionUtils.signedToUnsignedInt(baseAngleDegrees);
    // Never show 360; clamp to picker max 355 when needed.
    if (u >= 360) return 0;
    if (u > VectorAdditionConstants.unsignedAngleMax) {
      return VectorAdditionConstants.unsignedAngleMax;
    }
    return u;
  }

  /// Set angle from unsigned UI (0…355); converts to signed model.
  void setBaseAngleDegreesUnsigned(int unsignedDeg) {
    final clamped = unsignedDeg.clamp(
      VectorAdditionConstants.unsignedAngleMin,
      VectorAdditionConstants.unsignedAngleMax,
    );
    setBaseAngleDegrees(AngleConventionUtils.unsignedToSignedInt(clamped));
  }

  void _syncPolarFromCartesian() {
    final xy = VaVec(baseX.toDouble(), baseY.toDouble());
    baseMagnitude = VaVec.roundSymmetric(xy.magnitude).toInt();
    if (!xy.isEffectivelyZero) {
      baseAngleDegrees =
          VaVec.roundSymmetric(xy.angle * 180 / 3.141592653589793).toInt();
    }
  }

  void _syncCartesianFromPolar() {
    final xy = VaVec.createPolar(
      baseMagnitude.toDouble(),
      baseAngleDegrees * 3.141592653589793 / 180,
    );
    baseX = VaVec.roundSymmetric(xy.x).toInt();
    baseY = VaVec.roundSymmetric(xy.y).toInt();
  }

  void _applyBaseToVector() {
    // Keep tip/tail canonical: only xyComponents changes (tail fixed).
    xyComponents = baseXy * coefficient.toDouble();
    xComponentVector.update();
    yComponentVector.update();
  }

  @override
  void reset() {
    coefficient = _initialCoefficient;
    baseX = VaVec.roundSymmetric(_initialBaseXy.x).toInt();
    baseY = VaVec.roundSymmetric(_initialBaseXy.y).toInt();
    baseMagnitude = VaVec.roundSymmetric(_initialBaseXy.magnitude).toInt();
    baseAngleDegrees = _initialAngleDegrees(_initialBaseXy);
    super.reset();
    _applyBaseToVector();
  }
}
