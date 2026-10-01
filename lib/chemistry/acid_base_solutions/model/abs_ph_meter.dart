import 'dart:ui';

import 'abs_beaker.dart';
import 'abs_range.dart';

/// Movable pH meter — PhET `PHMeter.ts`.
///
/// Position is at the tip of the probe. pH reading comes from [pHOfSolution]
/// only when the tip is inside the beaker.
class AbsPhMeter {
  AbsPhMeter({
    required this.beaker,
    required this.pHOfSolution,
  })  : dragYRange = AbsRange(beaker.top - 5, beaker.top + 60),
        _position = Offset(beaker.right - 65, beaker.top - 5),
        _initialPosition = Offset(beaker.right - 65, beaker.top - 5);

  final AbsBeaker beaker;

  /// Current solution pH (from model).
  final double Function() pHOfSolution;

  /// Vertical drag range for the tip.
  final AbsRange dragYRange;

  Offset _position;
  final Offset _initialPosition;

  Offset get position => _position;

  set position(Offset value) {
    final y = dragYRange.constrain(value.dy);
    _position = Offset(_initialPosition.dx, y);
  }

  /// Tip is in solution when inside beaker bounds.
  bool get isInSolution => beaker.containsPoint(_position);

  /// Displayed pH, or `null` when tip is out of solution (blank readout).
  double? get displayedPH => isInSolution ? pHOfSolution() : null;

  /// Drag bounds constrained to vertical motion (fixed x).
  Rect get dragBounds {
    final x = _position.dx;
    return Rect.fromLTRB(x, dragYRange.min, x, dragYRange.max);
  }

  void reset() {
    _position = _initialPosition;
  }
}
