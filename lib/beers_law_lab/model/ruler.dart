import 'dart:ui';

import 'beers_law_constants.dart';

/// PhET `Ruler` — interactive, does not affect physics.
class Ruler {
  Ruler({
    Offset position = BeersLawConstants.rulerPosition,
    this.dragBounds = BeersLawConstants.rulerDragBounds,
    this.length = BeersLawConstants.rulerLength,
    this.height = BeersLawConstants.rulerHeight,
  })  : _position = position,
        _initialPosition = position;

  final Rect dragBounds;
  final double length;
  final double height;
  final Offset _initialPosition;

  Offset _position;

  Offset get position => _position;

  void setPosition(Offset value) {
    _position = Offset(
      value.dx.clamp(dragBounds.left, dragBounds.right),
      value.dy.clamp(dragBounds.top, dragBounds.bottom),
    );
  }

  void reset() {
    _position = _initialPosition;
  }
}
