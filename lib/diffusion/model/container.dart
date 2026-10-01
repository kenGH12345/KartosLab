import '../diffusion_constants.dart';

/// DiffusionContainer @ gas-properties 7a52c48.
///
/// Origin at bottom-right in PhET; we use left/bottom/right/top in pm with
/// left = 0, bottom = 0, right = width, top = height for Flutter simplicity
/// while preserving sizes and divider semantics.
class DiffusionContainer {
  DiffusionContainer() {
    _syncSideBounds();
  }

  final double width = DiffusionConstants.containerWidthPm;
  final double height = DiffusionConstants.containerHeightPm;
  final double wallThickness = DiffusionConstants.wallThicknessPm;
  final double dividerThickness = DiffusionConstants.dividerThicknessPm;

  bool hasDivider = true;

  double get left => 0;
  double get right => width;
  double get bottom => 0;
  double get top => height;
  double get dividerX => width / 2;

  late double leftMaxX;
  late double rightMinX;

  void _syncSideBounds() {
    final half = hasDivider ? dividerThickness / 2 : 0.0;
    leftMaxX = dividerX - half;
    rightMinX = dividerX + half;
  }

  void setHasDivider(bool value) {
    hasDivider = value;
    _syncSideBounds();
  }

  void reset() {
    hasDivider = true;
    _syncSideBounds();
  }

  bool inLeft(double x, double y) =>
      x >= left && x <= leftMaxX && y >= bottom && y <= top;

  bool inRight(double x, double y) =>
      x >= rightMinX && x <= right && y >= bottom && y <= top;
}
