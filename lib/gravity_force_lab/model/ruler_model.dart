import 'gravity_force_constants.dart';

/// Movable measure-distance ruler — PhET `rulerPositionProperty` + ISLCRulerNode.
///
/// Always present (no `showRuler` checkbox). Does not affect physics.
class RulerModel {
  RulerModel({
    double x = GravityForceConstants.rulerInitialX,
    double y = GravityForceConstants.rulerInitialY,
  })  : positionX = x,
        positionY = y;

  double positionX;
  double positionY;
  bool isDragging = false;

  /// Model-space drag bounds after ISLCRulerNode dilation / maxX extension.
  double get dragMinX => GravityForceConstants.rulerDragMinX;
  double get dragMaxX => GravityForceConstants.rulerDragMaxX;
  double get dragMinY =>
      GravityForceConstants.rulerDragMinY -
      GravityForceConstants.rulerHalfHeightModel;
  double get dragMaxY =>
      GravityForceConstants.rulerDragMaxY +
      GravityForceConstants.rulerHalfHeightModel;

  double get snap => GravityForceConstants.rulerSnap;

  /// Major tick spacing in model meters (50 view px / MVT scale 50).
  static const double majorTickSpacingMeters = 1;

  void setPosition(double x, double y) {
    positionX = _snapX(x).clamp(dragMinX, dragMaxX).toDouble();
    positionY = y.clamp(dragMinY, dragMaxY).toDouble();
  }

  void setPositionWhileDragging(double x, double y) {
    isDragging = true;
    setPosition(x, y);
  }

  void endDrag() {
    isDragging = false;
    // End-of-drag snap (keyboard path in ISLCRulerNode).
    positionX = _snapX(positionX).clamp(dragMinX, dragMaxX).toDouble();
  }

  /// J+H — jump and release to home.
  void jumpHome() {
    positionX = GravityForceConstants.rulerInitialX;
    positionY = GravityForceConstants.rulerInitialY;
    isDragging = false;
  }

  /// J+C — align ruler zero mark with mass1 center.
  ///
  /// [mass1PositionX] is the center of m1; ruler center shifts by half width.
  void jumpZeroToMass1Center(double mass1PositionX) {
    final x = mass1PositionX + GravityForceConstants.rulerHalfWidthModel;
    final y = GravityForceConstants.rulerModelYForCenterJump;
    setPosition(x, y);
  }

  void reset() {
    jumpHome();
  }

  double _snapX(double x) {
    final s = snap;
    if (s <= 0) return x;
    final snapped = _roundSymmetric(x / s) * s;
    return double.parse(snapped.toStringAsFixed(_decimalPlaces(s)));
  }

  static double _roundSymmetric(double value) =>
      value < 0 ? -value.abs().roundToDouble() : value.roundToDouble();

  static int _decimalPlaces(double value) {
    final s = value.toString();
    final i = s.indexOf('.');
    if (i < 0) return 0;
    return s.length - i - 1;
  }
}
