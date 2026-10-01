import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/widgets/pl_stopwatch_node.dart';

import '../../data/ruler_data.dart';

/// Physical-unit formatter for QWI stopwatch (PhET `createPhysicalStopwatchFormatter`).
({String value, String unit}) formatQwiStopwatch(double timeSeconds) {
  const units = <(double, double, String)>[
    (1e-12, 1e15, 'fs'),
    (1e-9, 1e12, 'ps'),
    (1e-6, 1e9, 'ns'),
    (1e-3, 1e6, 'µs'),
    (1.0, 1e3, 'ms'),
    (double.infinity, 1.0, 's'),
  ];
  final t = timeSeconds < 0 ? 0.0 : timeSeconds;
  for (final (threshold, multiplier, unit) in units) {
    if (t < threshold) {
      final scaled = t * multiplier;
      final decimals = scaled < 10 ? 2 : scaled < 100 ? 1 : 0;
      return (value: scaled.toStringAsFixed(decimals), unit: unit);
    }
  }
  return (value: '0.00', unit: 'fs');
}

/// Draggable scenery-phet-style stopwatch with adaptive physical units.
class QwiStopwatchOverlay extends StatelessWidget {
  const QwiStopwatchOverlay({
    super.key,
    required this.state,
    required this.canvasSize,
    required this.onChanged,
  });

  final QwiStopwatchState state;
  final Size canvasSize;
  final VoidCallback onChanged;

  static const double _width = 118;
  static const double _height = 78;

  @override
  Widget build(BuildContext context) {
    if (!state.visible) return const SizedBox.shrink();
    final left = state.left.clamp(0.0, (canvasSize.width - _width).clamp(0.0, double.infinity));
    final top = state.top.clamp(0.0, (canvasSize.height - _height).clamp(0.0, double.infinity));
    final formatted = formatQwiStopwatch(state.timeSeconds);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (d) {
          state.left = (state.left + d.delta.dx)
              .clamp(0.0, (canvasSize.width - _width).clamp(0.0, double.infinity));
          state.top = (state.top + d.delta.dy)
              .clamp(0.0, (canvasSize.height - _height).clamp(0.0, double.infinity));
          onChanged();
        },
        child: KeyedSubtree(
          key: const Key('qwi_stopwatch'),
          child: PlShadedRectangle(
            baseColor: PlStopwatchNode.backgroundBase,
            shades: plStopwatchShades,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFD3D3D3), width: 1),
                  ),
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: PlStopwatchNode.fontFamily,
                        color: Colors.black,
                        height: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text: formatted.value,
                          style: const TextStyle(fontSize: 20),
                        ),
                        TextSpan(
                          text: ' ${formatted.unit}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconButton(
                      key: const Key('qwi_stopwatch_reset'),
                      enabled: state.timeSeconds > 0,
                      onTap: () {
                        state.resetTime();
                        onChanged();
                      },
                      child: CustomPaint(
                        size: const Size(12, 10),
                        painter: _UTurnPainter(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _iconButton(
                      key: const Key('qwi_stopwatch_play_pause'),
                      enabled: true,
                      onTap: () {
                        state.toggleRunning();
                        onChanged();
                      },
                      child: CustomPaint(
                        size: Size(state.isRunning ? 6 : 8, 10),
                        painter: state.isRunning ? _PausePainter() : _PlayPainter(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _iconButton({
    required Key key,
    required bool enabled,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        key: key,
        onTap: enabled ? onTap : null,
        child: Container(
          width: 28,
          height: 23,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PlStopwatchNode.buttonBase,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFF999999)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.9)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PausePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.25, size.height * 0.8),
      p,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.1, size.width * 0.25, size.height * 0.8),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UTurnPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final r = size.height * 0.35;
    final path = Path()
      ..moveTo(size.width * 0.85, size.height * 0.75)
      ..lineTo(size.width * 0.85, size.height * 0.45)
      ..arcToPoint(
        Offset(size.width * 0.15, size.height * 0.45),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(size.width * 0.15, size.height * 0.75);
    canvas.drawPath(path, paint);
    final tip = Offset(size.width * 0.15, size.height * 0.75);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx - 3, tip.dy - 4)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + 3, tip.dy - 4),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
