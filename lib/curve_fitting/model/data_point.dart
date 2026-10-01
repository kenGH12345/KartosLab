import 'package:flutter/foundation.dart';

import '../curve_fitting_constants.dart';

/// PhET `Point` model — position, uncertainty, drag / animation flags.
class DataPoint extends ChangeNotifier {
  DataPoint({
    double x = 0,
    double y = 0,
    this.delta = CurveFittingConstants.defaultDelta,
    this.dragging = false,
    this.animationActive = false,
  })  : _x = x,
        _y = y,
        initialX = x,
        initialY = y;

  double _x;
  double _y;

  /// Creation / bucket-return target (PhET `positionProperty.initialValue`).
  final double initialX;
  final double initialY;

  double get x => _x;
  set x(double v) {
    if (_x == v) return;
    _x = v;
    notifyListeners();
  }

  double get y => _y;
  set y(double v) {
    if (_y == v) return;
    _y = v;
    notifyListeners();
  }

  /// Vertical uncertainty δ (default 0.8).
  double delta;

  bool dragging;

  /// True while animating back to the bucket (`animation !== null` in PhET).
  bool animationActive;

  void setDragging(bool value) {
    if (dragging == value) return;
    dragging = value;
    notifyListeners();
  }

  /// Inside white graph background [-10,-10]×[10,10] (inclusive edges).
  ///
  /// Uses closed bounds like PhET `Bounds2.containsPoint` — not Flutter's
  /// half-open [Rect.contains].
  bool get isInsideGraph {
    const b = CurveFittingConstants.graphBackgroundModelBounds;
    return x >= b.left && x <= b.right && y >= b.top && y <= b.bottom;
  }

  void setPosition(double nx, double ny) {
    if (_x == nx && _y == ny) return;
    _x = nx;
    _y = ny;
    notifyListeners();
  }
}
