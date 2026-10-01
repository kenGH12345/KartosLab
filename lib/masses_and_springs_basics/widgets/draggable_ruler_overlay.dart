import 'package:flutter/material.dart';

import '../transform/masb_coordinate_transform.dart';

/// PhET `DraggableRulerNode` — 1 m vertical ruler in cm, view-space drag.
class DraggableRulerOverlay extends StatefulWidget {
  const DraggableRulerOverlay({
    super.key,
    required this.transform,
    required this.workspaceSize,
    this.visible = true,
    this.resetToken = 0,
  });

  final MasbCoordinateTransform transform;
  final Size workspaceSize;
  final bool visible;
  final int resetToken;

  @override
  State<DraggableRulerOverlay> createState() => _DraggableRulerOverlayState();
}

class _DraggableRulerOverlayState extends State<DraggableRulerOverlay> {
  Offset? _position;
  bool _dragged = false;

  double get _lengthPx =>
      widget.transform.modelToViewDeltaY(-1).abs(); // 1 meter

  double get _widthPx => 0.125 * _lengthPx;

  Offset _defaultPosition() {
    // Near right edge of workspace (StretchScreenView: optionsPanel.rightBottom).
    return Offset(
      widget.workspaceSize.width - _widthPx - 12,
      widget.workspaceSize.height * 0.22,
    );
  }

  @override
  void didUpdateWidget(covariant DraggableRulerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken) {
      _dragged = false;
      _position = _defaultPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    final pos = _position ?? _defaultPosition();
    final length = _lengthPx;
    final width = _widthPx;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _dragged = true),
        onPanUpdate: (d) {
          final cur = _position ?? _defaultPosition();
          setState(() {
            _position = Offset(
              (cur.dx + d.delta.dx)
                  .clamp(0, widget.workspaceSize.width - width),
              (cur.dy + d.delta.dy)
                  .clamp(0, widget.workspaceSize.height - length),
            );
          });
        },
        child: Opacity(
          opacity: _dragged ? 1 : 0.95,
          child: CustomPaint(
            size: Size(width, length),
            painter: _RulerPainter(lengthPx: length, widthPx: width),
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({required this.lengthPx, required this.widthPx});

  final double lengthPx;
  final double widthPx;

  @override
  void paint(Canvas canvas, Size size) {
    // PhET rotates RulerNode by π/2; we paint vertical directly.
    // Labels: '', '', '10', '', '20', … '90', '', '' → 21 majors over 1 m.
    final majorLabels = <String>[''];
    for (var i = 1; i < 10; i++) {
      majorLabels.add('');
      majorLabels.add('${i * 10}');
    }
    majorLabels.add('');
    majorLabels.add('');
    final majorCount = majorLabels.length; // 21
    final majorStep = lengthPx / (majorCount - 1);
    const unitsIndex = 19;

    final bg = Paint()
      ..color = const Color(0xFFEDDF79).withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, widthPx, lengthPx),
        const Radius.circular(2),
      ),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, widthPx, lengthPx),
        const Radius.circular(2),
      ),
      Paint()
        ..color = const Color(0xFF6B7280)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    for (var i = 0; i < majorCount; i++) {
      final y = i * majorStep;
      canvas.drawLine(Offset(0, y), Offset(10, y), tickPaint);
      // 4 minor ticks between majors
      if (i < majorCount - 1) {
        for (var m = 1; m <= 4; m++) {
          final my = y + majorStep * m / 5;
          canvas.drawLine(Offset(0, my), Offset(5, my), tickPaint);
        }
      }
      final label = majorLabels[i];
      if (label.isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 9, color: Colors.black),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(12, y - tp.height / 2));
      }
      if (i == unitsIndex) {
        final tp = TextPainter(
          text: const TextSpan(
            text: 'cm',
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(widthPx - tp.width - 4, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.lengthPx != lengthPx || oldDelegate.widthPx != widthPx;
}
