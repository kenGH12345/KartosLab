import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';

/// StopwatchNode.ts — ShadedRectangle rgb(80,130,230), fonts 25/17 (ESP ScreenView).
class StopwatchOverlay extends StatefulWidget {
  const StopwatchOverlay({
    super.key,
    required this.controller,
    required this.playAreaSize,
  });

  final EspController controller;
  final Size playAreaSize;

  static const Size nodeSize = Size(168, 56);
  static const Color backgroundBase = Color.fromRGBO(80, 130, 230, 1);

  @override
  State<StopwatchOverlay> createState() => _StopwatchOverlayState();
}

class _StopwatchOverlayState extends State<StopwatchOverlay> {
  final GlobalKey _nodeKey = GlobalKey();

  Rect? _globalBounds() {
    final ctx = _nodeKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final o = box.localToGlobal(Offset.zero);
    return o & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.controller.model;
    if (!model.stopwatchVisible) return const SizedBox.shrink();

    final pos = model.tools.stopwatchViewPosition;
    final seconds = model.stopwatchTime;
    final m = (seconds / 60).floor();
    final s = seconds - m * 60;
    final cs = ((seconds - m * 60 - s) * 100).round().clamp(0, 99);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          widget.controller.dragStopwatch(
            widget.controller.model.tools.stopwatchViewPosition + d.delta,
            widget.playAreaSize,
          );
        },
        onPanEnd: (_) {
          final bounds = _globalBounds();
          if (bounds != null) {
            widget.controller.onStopwatchDragEnd(bounds);
          }
        },
        child: Material(
          key: _nodeKey,
          elevation: 2,
          borderRadius: BorderRadius.circular(6),
          child: CustomPaint(
            painter: _StopwatchBackgroundPainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Trebuchet MS, Lucida Grande, monospace',
                        color: Colors.black87,
                        height: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${m.toString().padLeft(2, '0')}:${s.floor().toString().padLeft(2, '0')}.',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: cs.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _RoundButton(
                    onTap: widget.controller.resetStopwatch,
                    child: CustomPaint(
                      size: const Size(14, 14),
                      painter: _ResetIconPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFDFE0E1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: child,
        ),
      ),
    );
  }
}

class _StopwatchBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            StopwatchOverlay.backgroundBase.withValues(alpha: 0.95),
            StopwatchOverlay.backgroundBase.withValues(alpha: 0.75),
          ],
        ).createShader(r.outerRect),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = const Color(0xFF3A5A9E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResetIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: size.width * 0.42),
      0.8,
      4.5,
      false,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    final tip = Offset(c.dx + size.width * 0.35, c.dy - size.height * 0.1);
    canvas.drawLine(
      tip,
      tip + const Offset(-3, -3),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
