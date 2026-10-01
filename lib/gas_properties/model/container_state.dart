import '../gas_properties_constants.dart';

/// Port of BaseContainer + IdealGasLawContainer.
/// Origin at bottom-right (0,0); width expands to the left.
class ContainerState {
  ContainerState({
    this.leftWallDoesWork = false,
    double? fixedWidth,
  }) : widthRangeMin = fixedWidth ?? GasPropertiesConstants.widthMin,
       widthRangeMax = fixedWidth ?? GasPropertiesConstants.widthMax {
    final initial = fixedWidth ?? GasPropertiesConstants.widthDefault;
    width = initial;
    desiredWidth = initial;
    lidWidth = maxLidWidth;
    previousLeft = left;
  }

  final bool leftWallDoesWork;
  final double widthRangeMin;
  final double widthRangeMax;

  final double positionX = 0;
  final double positionY = 0;
  final double height = GasPropertiesConstants.height;
  final double depth = GasPropertiesConstants.depth;
  final double wallThickness = GasPropertiesConstants.wallThickness;

  double width = GasPropertiesConstants.widthDefault;
  double desiredWidth = GasPropertiesConstants.widthDefault;
  double leftWallVelocityX = 0;
  double previousLeft = 0;
  bool userIsAdjustingWidth = false;

  bool lidIsOn = true;
  late double lidWidth;

  double get volume => width * height * depth;

  double get left => positionX - width;
  double get right => positionX;
  double get bottom => positionY;
  double get top => positionY + height;

  double get minLidWidth =>
      GasPropertiesConstants.openingLeftInset + wallThickness;

  double get maxLidWidth =>
      width - GasPropertiesConstants.openingRightInset + wallThickness;

  bool get isOpen => !lidIsOn || lidWidth < maxLidWidth - 1e-6;

  double get particleEntryX => positionX;
  double get particleEntryY => positionY + height / 5;

  bool get isFixedWidth => widthRangeMin == widthRangeMax;

  double getOpeningLeft() {
    if (lidIsOn) {
      return (left - wallThickness + lidWidth).roundToDouble();
    }
    return left + GasPropertiesConstants.openingLeftInset;
  }

  double getOpeningRight() =>
      positionX - GasPropertiesConstants.openingRightInset;

  /// Opening width in pm — IdealGasLawContainer.getOpeningWidth.
  double getOpeningWidth() {
    final w = getOpeningRight() - getOpeningLeft();
    return w < 0 ? 0.0 : w;
  }

  /// LidHandleDragListener semantics: clamp lid width to [minLidWidth, maxLidWidth].
  void setLidWidth(double widthPm) {
    if (!lidIsOn) return;
    lidWidth = widthPm.clamp(minLidWidth, maxLidWidth).toDouble();
  }

  /// PhET IdealGasLawContainer.blowLidOff — only if closed or opening is small.
  void blowLidOff() {
    if (!isOpen ||
        getOpeningWidth() < GasPropertiesConstants.openingWidthThreshold) {
      lidIsOn = false;
    }
  }

  void returnLid() {
    lidIsOn = true;
    lidWidth = maxLidWidth;
  }

  void setDesiredWidth(double w) {
    desiredWidth =
        w.clamp(widthRangeMin, widthRangeMax).toDouble();
  }

  void setWidth(double newWidth) {
    final clamped = newWidth.clamp(widthRangeMin, widthRangeMax).toDouble();
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
    previousLeft = left;
    leftWallVelocityX = 0;
  }

  /// Animate toward [desiredWidth]; Explore applies wall speed limit + velocity.
  void step(double dt) {
    assert(dt > 0);
    final widthDifference = desiredWidth - width;
    if (widthDifference != 0) {
      var newWidth = desiredWidth;
      if (leftWallDoesWork) {
        final widthStep = dt * GasPropertiesConstants.wallSpeedLimit;
        if (widthStep < widthDifference.abs()) {
          newWidth = widthDifference > 0
              ? width + widthStep
              : width - widthStep;
        }
      }
      setWidth(newWidth);
    }

    if (leftWallDoesWork) {
      final dx = left - previousLeft;
      leftWallVelocityX = dx / dt;
      previousLeft = left;
    } else {
      leftWallVelocityX = 0;
    }
  }

  void reset() {
    final initial = isFixedWidth ? widthRangeMin : GasPropertiesConstants.widthDefault;
    width = initial;
    desiredWidth = width;
    lidIsOn = true;
    lidWidth = maxLidWidth;
    leftWallVelocityX = 0;
    previousLeft = left;
    userIsAdjustingWidth = false;
  }
}
