/// PhET Draggable — a widget that can be dragged by pointer (mouse/touch).
///
/// Provides a builder that receives the current position.
///
/// Usage:
/// ```dart
/// PhetDraggable(
///   initialPosition: Offset(100, 100),
///   builder: (context, pos) => MyWidget(pos),
/// )
/// ```
library;

import 'package:flutter/material.dart';

class PhetDraggable extends StatefulWidget {
  final Offset initialPosition;
  final Widget Function(BuildContext context, Offset position) builder;
  final ValueChanged<Offset>? onPositionChanged;

  const PhetDraggable({
    super.key,
    required this.initialPosition,
    required this.builder,
    this.onPositionChanged,
  });

  @override
  State<PhetDraggable> createState() => _PhetDraggableState();
}

class _PhetDraggableState extends State<PhetDraggable> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _position += d.delta;
          });
          widget.onPositionChanged?.call(_position);
        },
        child: widget.builder(context, _position),
      ),
    );
  }
}
