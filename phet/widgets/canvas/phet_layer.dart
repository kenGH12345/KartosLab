/// Base class for PhET canvas layers.
///
/// A layer is a single visual plane within the simulation canvas (e.g.
/// background, field arrows, objects, particles, overlay). Each layer
/// receives the canvas and coordinate system and paints its content.
library;

import 'package:flutter/material.dart';
import '../core/coordinate_system.dart';

abstract class PhetLayer {
  /// Whether this layer is currently visible.
  bool get visible => true;

  /// Paint this layer onto [canvas].
  ///
  /// [size] is the full canvas size in screen pixels.
  /// [coord] provides world↔screen conversion.
  void paint(Canvas canvas, Size size, CoordinateSystem coord);
}

/// A layer backed by a single [CustomPainter].
class PainterLayer extends PhetLayer {
  @override
  final bool visible;
  final CustomPainter painter;

  PainterLayer({this.visible = true, required this.painter});

  @override
  void paint(Canvas canvas, Size size, CoordinateSystem coord) {
    painter.paint(canvas, size);
  }
}

/// A layer that needs coordinate system access.
abstract class PhetCoordinateLayer extends PhetLayer {
  /// Paint with access to coordinate system.
  void paintWithCoord(Canvas canvas, Size size, CoordinateSystem coord);

  @override
  void paint(Canvas canvas, Size size, CoordinateSystem coord) {
    paintWithCoord(canvas, size, coord);
  }
}
