import 'package:flutter/material.dart';

import '../model/gravity_model.dart';
import '../transform/math_coordinate_transform.dart';

/// Hit-target for one mass; uses [layoutKey] for model conversion.
class MassDragTarget extends StatefulWidget {
  const MassDragTarget({
    super.key,
    required this.model,
    required this.transform,
    required this.layoutKey,
    required this.which,
    required this.center,
    required this.radiusView,
  });

  final GravityModel model;
  final MathCoordinateTransform transform;
  final GlobalKey layoutKey;
  final int which;
  final Offset center;
  final double radiusView;

  @override
  State<MassDragTarget> createState() => _MassDragTargetState();
}

class _MassDragTargetState extends State<MassDragTarget> {
  bool _dragging = false;
  double _clickOffsetView = 0;

  @override
  Widget build(BuildContext context) {
    final hitR = widget.radiusView + 28;
    return Positioned(
      left: widget.center.dx - hitR,
      top: widget.center.dy - hitR,
      width: hitR * 2,
      height: hitR * 2,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          _dragging = true;
          widget.model.beginDrag(widget.which);
          final local = _layoutLocal(e.position);
          if (local != null) {
            _clickOffsetView = local.dx - widget.center.dx;
          } else {
            _clickOffsetView = 0;
          }
        },
        onPointerMove: (e) {
          if (!_dragging) return;
          final local = _layoutLocal(e.position);
          if (local == null) return;
          final viewX = local.dx - _clickOffsetView;
          final modelX = widget.transform.viewToModelX(viewX);
          widget.model.setPositionWhileDragging(widget.which, modelX);
        },
        onPointerUp: (_) => _end(),
        onPointerCancel: (_) => _end(),
        child: const SizedBox.expand(),
      ),
    );
  }

  Offset? _layoutLocal(Offset global) {
    final box =
        widget.layoutKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  void _end() {
    if (!_dragging) return;
    _dragging = false;
    widget.model.endDrag(widget.which);
  }
}
