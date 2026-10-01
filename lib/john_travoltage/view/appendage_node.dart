import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/appendage.dart';
import 'jt_view_geometry.dart';
import 'jt_view_layout.dart';

/// Draggable rotating appendage — PhET `AppendageNode.js` (pointer + border).
class AppendageNode extends StatefulWidget {
  const AppendageNode({
    super.key,
    required this.appendage,
    required this.assetPath,
    required this.imageSize,
    required this.dx,
    required this.dy,
    required this.angleOffset,
    required this.onAngleChanged,
    this.limitRotation,
    this.debugKey,
  });

  final Appendage appendage;
  final String assetPath;
  final Size imageSize;
  final double dx;
  final double dy;
  final double angleOffset;
  final void Function(double angle) onAngleChanged;
  final double Function(double angle)? limitRotation;
  final Key? debugKey;

  @override
  State<AppendageNode> createState() => AppendageNodeState();
}

class AppendageNodeState extends State<AppendageNode> {
  double _currentAngle = 0;
  double _lastAngle = 0;

  Appendage get appendage => widget.appendage;

  Offset get pivot => Offset(appendage.position.x, appendage.position.y);

  /// Border uses initial-angle AABB (AppendageNode constructs border once).
  Rect get borderRect => AppendageTransform.imageBounds(
        pivot: pivot,
        angle: appendage.initialAngle,
        angleOffset: widget.angleOffset,
        dx: widget.dx,
        dy: widget.dy,
        imageSize: widget.imageSize,
      );

  @override
  void initState() {
    super.initState();
    _currentAngle = appendage.angle;
    _lastAngle = appendage.angle;
  }

  @override
  void didUpdateWidget(covariant AppendageNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentAngle = appendage.angle;
  }

  Offset _playLocal(Offset global) {
    final box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
  }

  void _beginDrag(Offset global) {
    appendage.dragging = true;
    appendage.borderVisible = false;
    setState(() {});
    _applyAngleFromGlobal(global);
  }

  void _applyAngleFromGlobal(Offset global) {
    if (appendage.borderVisible) {
      appendage.borderVisible = false;
    }

    final local = _playLocal(global);
    var angle = math.atan2(local.dy - pivot.dy, local.dx - pivot.dx);
    if (widget.limitRotation != null) {
      angle = widget.limitRotation!(angle);
    }

    _lastAngle = _currentAngle;
    final z = math.cos(_currentAngle) * math.sin(_lastAngle) -
        math.sin(_currentAngle) * math.cos(_lastAngle);

    final current = appendage.angle;
    if (current == math.pi && z < 0) return;
    if (current == 0 && z > 0) return;
    if (_distanceBetweenAngles(current, angle) > math.pi / 3 &&
        (current == 0 || current == math.pi)) {
      return;
    }

    angle = _wrapAngle(angle);
    _currentAngle = angle;
    widget.onAngleChanged(angle);
  }

  void _endDrag() {
    appendage.dragging = false;
    setState(() {});
  }

  double _wrapAngle(double angle) {
    var wrapped = angle;
    if (wrapped < appendage.angleMin || wrapped > appendage.angleMax) {
      final max = appendage.angleMax;
      final min = appendage.angleMin;
      if (wrapped < min) {
        wrapped = max - (min - wrapped).abs();
      } else if (wrapped > max) {
        wrapped = min + (max - wrapped).abs();
      }
    }
    return wrapped;
  }

  static double _distanceBetweenAngles(double a, double b) {
    final diff = (a - b).abs() % (math.pi * 2);
    return math.min((diff - math.pi * 2).abs(), diff);
  }

  @override
  Widget build(BuildContext context) {
    final m = AppendageTransform.matrix(
      pivot: pivot,
      angle: appendage.angle,
      angleOffset: widget.angleOffset,
      dx: widget.dx,
      dy: widget.dy,
    );

    return SizedBox(
      width: JtViewLayout.layoutWidth,
      height: JtViewLayout.layoutHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform(
            key: widget.debugKey,
            transform: m,
            alignment: Alignment.topLeft,
            filterQuality: FilterQuality.medium,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _beginDrag(d.globalPosition),
              onPanUpdate: (d) => _applyAngleFromGlobal(d.globalPosition),
              onPanEnd: (_) => _endDrag(),
              onPanCancel: _endDrag,
              child: Image.asset(
                widget.assetPath,
                width: widget.imageSize.width,
                height: widget.imageSize.height,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          if (appendage.borderVisible)
            Positioned.fromRect(
              rect: borderRect,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: const _DashedBorderPainter(),
                  size: borderRect.size,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(JtViewLayout.borderCornerRadius),
    );
    final paint = Paint()
      ..color = JtViewLayout.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = JtViewLayout.borderLineWidth;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      var dashIndex = 0;
      while (distance < metric.length) {
        final len =
            JtViewLayout.borderDash[dashIndex % JtViewLayout.borderDash.length];
        final next = math.min(distance + len, metric.length);
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, next), paint);
        }
        distance = next;
        draw = !draw;
        dashIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
