import '../gases_intro_constants.dart';

/// Port of BaseContainer + IdealGasLawContainer @ 10c7c08.
/// Origin at bottom-right (0,0); width expands left. Ideal: leftWallVelocityX=0.
class ContainerModel {
  ContainerModel() {
    width = GasesIntroConstants.widthDefault;
    desiredWidth = width;
    lidWidth = maxLidWidth;
  }

  final double positionX = 0;
  final double positionY = 0;

  final double height = GasesIntroConstants.height;
  final double depth = GasesIntroConstants.depth;
  final double wallThickness = GasesIntroConstants.wallThickness;

  double width = GasesIntroConstants.widthDefault;
  double desiredWidth = GasesIntroConstants.widthDefault;
  double leftWallVelocityX = 0;
  bool userIsAdjustingWidth = false;

  bool lidIsOn = true;
  late double lidWidth;

  double get volume => width * height * depth;

  double get left => positionX - width;
  double get right => positionX;
  double get bottom => positionY;
  double get top => positionY + height;

  double get minLidWidth =>
      GasesIntroConstants.openingLeftInset + wallThickness;

  double get maxLidWidth =>
      width - GasesIntroConstants.openingRightInset + wallThickness;

  bool get isOpen => !lidIsOn || lidWidth < maxLidWidth - 1e-6;

  double get particleEntryX => positionX;
  double get particleEntryY => positionY + height / 5;

  /// Opening left edge (lid on vs off).
  double getOpeningLeft() {
    if (lidIsOn) {
      return (left - wallThickness + lidWidth).roundToDouble();
    }
    return left + GasesIntroConstants.openingLeftInset;
  }

  double getOpeningRight() =>
      positionX - GasesIntroConstants.openingRightInset;

  double get openingLeft => getOpeningLeft();
  double get openingRight => getOpeningRight();

  /// Left edge of the drawn lid (model X). Matches [PlayAreaPainter].
  double get lidLeft => positionX - lidWidth;

  /// Horizontal span of the top gap. When the lid is on, that is the visible
  /// notch left of the lid; when the lid is off, the full top is open.
  double get escapeOpeningLeft => lidIsOn ? left : left + GasesIntroConstants.openingLeftInset;

  double get escapeOpeningRight =>
      lidIsOn ? lidLeft : positionX - GasesIntroConstants.openingRightInset;

  bool isInEscapeOpening(double particleLeft, double particleRight) {
    if (!isOpen) return false;
    return particleLeft > escapeOpeningLeft && particleRight < escapeOpeningRight;
  }

  void blowLidOff() {
    lidIsOn = false;
  }

  void returnLid() {
    lidIsOn = true;
    lidWidth = maxLidWidth;
  }

  void setWidth(double newWidth) {
    final clamped =
        newWidth.clamp(GasesIntroConstants.widthMin, GasesIntroConstants.widthMax).toDouble();
    if (clamped == width) return;
    final openingW = getOpeningRight() - getOpeningLeft();
    width = clamped;
    if (lidIsOn) {
      final next = maxLidWidth - openingW;
      lidWidth = next < minLidWidth ? minLidWidth : next;
    }
  }

  void resizeImmediately(double newWidth) {
    setWidth(newWidth);
    desiredWidth = width;
  }

  /// Ideal leftWallDoesWork=false — jump to desired; vx stays 0.
  void step(double dt) {
    if (desiredWidth != width) {
      setWidth(desiredWidth);
    }
  }

  void reset() {
    width = GasesIntroConstants.widthDefault;
    desiredWidth = width;
    lidIsOn = true;
    lidWidth = maxLidWidth;
    leftWallVelocityX = 0;
    userIsAdjustingWidth = false;
  }
}
