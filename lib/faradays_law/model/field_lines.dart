import 'dart:math' as math;

import 'dart:ui' show Offset;

import 'magnet_orientation.dart';

/// One predefined field-line ellipse from `MagnetFieldLines.js` `LINE_DESCRIPTION`.
class FieldLineEllipseSpec {
  const FieldLineEllipseSpec({
    required this.a,
    required this.b,
    required this.arrowPositions,
  });

  final double a;
  final double b;
  final List<double> arrowPositions;
}

/// Source-defined ellipse parameters (not a B-field solver).
const List<FieldLineEllipseSpec> kFieldLineEllipseSpecs = [
  FieldLineEllipseSpec(
    a: 600,
    b: 300,
    arrowPositions: [math.pi / 3.5, math.pi - math.pi / 3.5],
  ),
  FieldLineEllipseSpec(
    a: 350,
    b: 125,
    arrowPositions: [math.pi / 7, math.pi - math.pi / 7],
  ),
  FieldLineEllipseSpec(
    a: 180,
    b: 50,
    arrowPositions: [-math.pi / 2],
  ),
  FieldLineEllipseSpec(
    a: 90,
    b: 25,
    arrowPositions: [-math.pi / 2],
  ),
];

/// Vertical dy between stacked ellipses on one side (`dy = 3` per index).
const double kFieldLineEllipseDy = 3;

/// View-consumable snapshot of field-line state.
///
/// Geometry is predefined ellipses centered on the magnet; polarity flips arrow
/// direction (source rotates each arrow by π on orientation change).
class FieldLineGeometry {
  const FieldLineGeometry({
    required this.visible,
    required this.magnetPosition,
    required this.orientation,
    required this.ellipses,
    required this.arrowDirectionFlipped,
  });

  final bool visible;
  final Offset magnetPosition;
  final MagnetOrientation orientation;

  /// Same 4 ellipses for top (+1) and bottom (−1) sides.
  final List<FieldLineEllipseSpec> ellipses;

  /// True when orientation is SN (arrows flipped once from NS construction).
  final bool arrowDirectionFlipped;
}

/// Model facade for predefined field lines — `MagnetFieldLines.js`.
///
/// Does **not** solve Maxwell / dipole field lines. View will paint ellipses.
class FieldLinesModel {
  FieldLinesModel({
    required bool Function() visibleGetter,
    required Offset Function() magnetPositionGetter,
    required MagnetOrientation Function() orientationGetter,
  })  : _visibleGetter = visibleGetter,
        _magnetPositionGetter = magnetPositionGetter,
        _orientationGetter = orientationGetter;

  final bool Function() _visibleGetter;
  final Offset Function() _magnetPositionGetter;
  final MagnetOrientation Function() _orientationGetter;

  bool get visible => _visibleGetter();
  Offset get magnetPosition => _magnetPositionGetter();
  MagnetOrientation get orientation => _orientationGetter();

  FieldLineGeometry get geometry => FieldLineGeometry(
        visible: visible,
        magnetPosition: magnetPosition,
        orientation: orientation,
        ellipses: kFieldLineEllipseSpecs,
        arrowDirectionFlipped: orientation == MagnetOrientation.sn,
      );
}
