import 'dart:ui' show Offset, Rect;

import '../faradays_law_constants.dart';
import 'magnet_orientation.dart';

/// PhET `Magnet.js`
class Magnet {
  Offset position = FaradaysLawConstants.defaultMagnetPosition;
  MagnetOrientation orientation = MagnetOrientation.ns;
  bool fieldLinesVisible = false;
  bool isDragging = false;

  double get width => FaradaysLawConstants.magnetWidth;
  double get height => FaradaysLawConstants.magnetHeight;

  Rect get bounds => Rect.fromCenter(
        center: position,
        width: width,
        height: height,
      );

  void setPosition(Offset value) {
    position = value;
  }

  void flipPolarity() {
    orientation = orientation.flipped;
  }

  void reset() {
    position = FaradaysLawConstants.defaultMagnetPosition;
    orientation = MagnetOrientation.ns;
    fieldLinesVisible = false;
    isDragging = false;
  }
}
