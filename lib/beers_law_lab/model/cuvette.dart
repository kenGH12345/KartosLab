import 'dart:ui';

import 'beers_law_constants.dart';

/// PhET `Cuvette` — fixed height, variable width (path-length upper bound).
class Cuvette {
  Cuvette({
    this.position = BeersLawConstants.cuvettePosition,
    this.height = BeersLawConstants.cuvetteHeight,
  })  : _width = BeersLawConstants.cuvetteWidthDefault,
        snapInterval = BeersLawConstants.cuvetteSnapIntervalDefault;

  final Offset position;
  final double height;

  double _width;

  /// Snap interval at end of pointer drag; NOT reset by [reset].
  double snapInterval;

  double get width => _width;

  double get centerX => position.dx + _width / 2;

  double get right => position.dx + _width;

  void setWidth(double cm) {
    _width = cm.clamp(
      BeersLawConstants.cuvetteWidthMin,
      BeersLawConstants.cuvetteWidthMax,
    );
  }

  /// Apply [snapInterval] rounding (0 = no snap). Source: CuvetteDragListener end.
  void snapWidth() {
    if (snapInterval <= 0) return;
    final snapped = (_width / snapInterval).round() * snapInterval;
    setWidth(snapped);
  }

  void reset() {
    _width = BeersLawConstants.cuvetteWidthDefault;
    // snapInterval intentionally NOT reset — source Cuvette.reset()
  }
}
