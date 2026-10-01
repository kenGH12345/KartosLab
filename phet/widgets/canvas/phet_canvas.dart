/// PhET Canvas — a layered simulation canvas with coordinate transform,
/// drag support, and animation.
///
/// Each simulation uses [PhetCanvas] as the base for its visual area.
/// Painters are registered as layers, each receiving the same
/// [CoordinateSystem] for world→screen mapping.
library;

import 'package:flutter/material.dart';
import '../core/coordinate_system.dart';
import 'phet_layer.dart';

/// A layered simulation canvas.
///
/// Usage:
/// ```dart
/// PhetCanvas(
///   worldBounds: Rect.fromLTWH(-5, -5, 10, 10),
///   layers: [
///     BackgroundLayer(),
///     FieldLayer(...),
///     ObjectLayer(...),
///   ],
/// )
/// ```
class PhetCanvas extends StatefulWidget {
  /// The world-space rectangle that maps to the available screen size.
  final Rect worldBounds;

  /// Whether to preserve world aspect ratio (letterbox if needed).
  final bool preserveAspect;

  /// Painters to render, from bottom to top.
  final List<PhetLayer> layers;

  /// Called when a pointer drag is detected in screen coordinates.
  final void Function(Offset screenPos, Offset worldPos)? onPanUpdate;

  /// Called when a pointer drag starts.
  final void Function(Offset screenPos, Offset worldPos)? onPanStart;

  /// Called when a pointer drag ends.
  final void Function(Offset screenPos, Offset worldPos)? onPanEnd;

  /// Optional child widget to overlay on top of the canvas (for Flutter
  /// widgets like panels that still need to be inside the canvas stack).
  final Widget? overlay;

  const PhetCanvas({
    super.key,
    required this.worldBounds,
    this.preserveAspect = true,
    this.layers = const [],
    this.onPanUpdate,
    this.onPanStart,
    this.onPanEnd,
    this.overlay,
  });

  @override
  State<PhetCanvas> createState() => _PhetCanvasState();
}

class _PhetCanvasState extends State<PhetCanvas> {
  CoordinateSystem? _coord;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final screen = Size(constraints.maxWidth, constraints.maxHeight);
        _coord = CoordinateSystem(
          screenSize: screen,
          worldBounds: widget.worldBounds,
          preserveAspect: widget.preserveAspect,
        );
        final coord = _coord!;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: widget.onPanStart != null
              ? (d) => widget.onPanStart!(d.localPosition, coord.screenToWorld(d.localPosition))
              : null,
          onPanUpdate: widget.onPanUpdate != null
              ? (d) => widget.onPanUpdate!(d.localPosition, coord.screenToWorld(d.localPosition))
              : null,
          onPanEnd: widget.onPanEnd != null
              ? (_) {
                  // GestureDetector doesn't provide final position
                  widget.onPanEnd!(Offset.zero, Offset.zero);
                }
              : null,
          child: Stack(
            children: [
              // Painted layers
              RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LayeredPainter(widget.layers, coord),
                ),
              ),
              // Optional overlay
              if (widget.overlay != null) widget.overlay!,
            ],
          ),
        );
      },
    );
  }
}

/// Painter that delegates to a list of [PhetLayer]s.
class _LayeredPainter extends CustomPainter {
  final List<PhetLayer> layers;
  final CoordinateSystem coord;

  _LayeredPainter(this.layers, this.coord);

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      if (!layer.visible) continue;
      layer.paint(canvas, size, coord);
    }
  }

  @override
  bool shouldRepaint(_LayeredPainter old) => true;
}
