/// Coordinate system for PhET simulations.
///
/// Provides conversion between world (simulation) coordinates and screen
/// (pixel) coordinates. All simulations should use this instead of doing
/// manual offset math.
library;

import 'package:flutter/material.dart' show Offset, Size, Rect;

/// Handles world ↔ screen coordinate transforms.
///
/// World coordinates are in simulation units (e.g. meters, or arbitrary).
/// Screen coordinates are in device pixels for a given canvas size.
class CoordinateSystem {
  /// The canvas size in screen pixels.
  final Size screenSize;

  /// The world-space bounds that map to [screenSize].
  final Rect worldBounds;

  /// If true, preserve world aspect ratio when mapping to screen (adds
  /// letterbox offset).
  final bool preserveAspect;

  late final double _scaleX;
  late final double _scaleY;
  late final double _scale;
  late final Offset _offset;

  CoordinateSystem({
    required this.screenSize,
    required this.worldBounds,
    this.preserveAspect = true,
  }) {
    final ww = worldBounds.width;
    final wh = worldBounds.height;
    if (ww <= 0 || wh <= 0) {
      _scaleX = _scaleY = _scale = 1;
      _offset = Offset.zero;
      return;
    }
    _scaleX = screenSize.width / ww;
    _scaleY = screenSize.height / wh;
    if (preserveAspect) {
      _scale = _scaleX < _scaleY ? _scaleX : _scaleY;
      final renderedW = ww * _scale;
      final renderedH = wh * _scale;
      _offset = Offset(
        (screenSize.width - renderedW) / 2 - worldBounds.left * _scale,
        (screenSize.height - renderedH) / 2 - worldBounds.top * _scale,
      );
    } else {
      _scale = 1; // not used in non-aspect mode
      _offset = Offset(-worldBounds.left * _scaleX, -worldBounds.top * _scaleY);
    }
  }

  /// Convert a world coordinate to screen pixels.
  Offset worldToScreen(Offset world) {
    if (preserveAspect) {
      return Offset(
        world.dx * _scale + _offset.dx,
        world.dy * _scale + _offset.dy,
      );
    }
    return Offset(
      world.dx * _scaleX + _offset.dx,
      world.dy * _scaleY + _offset.dy,
    );
  }

  /// Convert a screen pixel coordinate back to world coordinates.
  Offset screenToWorld(Offset screen) {
    if (preserveAspect) {
      return Offset(
        (screen.dx - _offset.dx) / _scale,
        (screen.dy - _offset.dy) / _scale,
      );
    }
    return Offset(
      (screen.dx - _offset.dx) / _scaleX,
      (screen.dy - _offset.dy) / _scaleY,
    );
  }

  /// Scale a world-space distance to screen pixels.
  double scaleToScreen(double worldDist) {
    return preserveAspect ? worldDist * _scale : worldDist * _scaleX;
  }

  /// Scale a screen-pixel distance back to world units.
  double scaleToWorld(double screenDist) {
    return preserveAspect ? screenDist / _scale : screenDist / _scaleX;
  }
}
