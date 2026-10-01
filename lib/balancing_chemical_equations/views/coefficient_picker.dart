import 'dart:async';

import 'package:flutter/material.dart';

import '../model/equation_term.dart';

/// PhET `CoefficientPicker` / sun `NumberPicker`.
///
/// Up/down triangles; long-press repeats after 400ms then every 200ms (source).
class CoefficientPicker extends StatefulWidget {
  const CoefficientPicker({
    super.key,
    required this.term,
    this.fontSize = 32,
    this.enabled = true,
  });

  final EquationTerm term;
  final double fontSize;
  final bool enabled;

  @override
  State<CoefficientPicker> createState() => _CoefficientPickerState();
}

class _CoefficientPickerState extends State<CoefficientPicker> {
  Timer? _repeat;
  Timer? _delay;

  @override
  void dispose() {
    _cancelRepeat();
    super.dispose();
  }

  void _cancelRepeat() {
    _delay?.cancel();
    _repeat?.cancel();
    _delay = null;
    _repeat = null;
  }

  void _startRepeat(VoidCallback action) {
    action();
    _delay = Timer(const Duration(milliseconds: 400), () {
      _repeat = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted || !widget.enabled) {
          _cancelRepeat();
          return;
        }
        action();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final term = widget.term;
    final enabled = widget.enabled;
    final arrowColor = enabled ? const Color(0xFF323232) : Colors.transparent;

    return ListenableBuilder(
      listenable: term,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: enabled
                  ? (_) => _startRepeat(() {
                        if (term.coefficient < term.coefficientRange.max) {
                          term.increment();
                        }
                      })
                  : null,
              onTapUp: (_) => _cancelRepeat(),
              onTapCancel: _cancelRepeat,
              child: CustomPaint(
                size: const Size(28, 14),
                painter: _TrianglePainter(color: arrowColor, up: true),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 36),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF323232)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${term.coefficient}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: widget.fontSize,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: enabled
                  ? (_) => _startRepeat(() {
                        if (term.coefficient > term.coefficientRange.min) {
                          term.decrement();
                        }
                      })
                  : null,
              onTapUp: (_) => _cancelRepeat(),
              onTapCancel: _cancelRepeat,
              child: CustomPaint(
                size: const Size(28, 14),
                painter: _TrianglePainter(color: arrowColor, up: false),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color, required this.up});
  final Color color;
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path.moveTo(size.width / 2, 2);
      path.lineTo(size.width - 2, size.height - 2);
      path.lineTo(2, size.height - 2);
    } else {
      path.moveTo(2, 2);
      path.lineTo(size.width - 2, 2);
      path.lineTo(size.width / 2, size.height - 2);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.up != up;
}
