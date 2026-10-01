/// Base class for PhET custom painters.
///
/// Extends Flutter's [CustomPainter] with optional coordinate system
/// access, enabling world→screen mapping inside paint code.
library;

import 'package:flutter/material.dart';
import '../core/coordinate_system.dart';

abstract class PhetPainter extends CustomPainter {
  /// The coordinate system for world↔screen conversion.
  ///
  /// May be null if the painter doesn't use world coordinates.
  final CoordinateSystem? coord;

  const PhetPainter({this.coord});

  /// Subclasses implement this instead of [paint].
  void paintWithCoord(Canvas canvas, Size size, CoordinateSystem coord);

  @override
  void paint(Canvas canvas, Size size) {
    paintWithCoord(canvas, size, coord ?? CoordinateSystem(screenSize: size, worldBounds: Rect.fromLTWH(0, 0, size.width, size.height)));
  }
}
