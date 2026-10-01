import 'package:flutter/material.dart';

import '../bce_constants.dart';
import '../model/atom_count.dart';
import '../model/bce_element.dart';
import '../model/equation.dart';

/// PhET `BarChartsNode` — reactant/product bars per element with equality op.
class BarChartsNode extends StatelessWidget {
  const BarChartsNode({super.key, required this.equation});

  final Equation equation;

  static const unitBarHeight = 5.0;
  static const maxAtoms = 12;
  static const barWidth = 40.0;
  static const xSpacing = 100.0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: equation,
      builder: (context, _) {
        final counts = equation.getAtomCounts();
        if (counts.isEmpty) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < counts.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              _ElementBarRow(atomCount: counts[i]),
            ],
          ],
        );
      },
    );
  }
}

class _ElementBarRow extends StatelessWidget {
  const _ElementBarRow({required this.atomCount});
  final AtomCount atomCount;

  @override
  Widget build(BuildContext context) {
    final balanced = atomCount.isElementBalanced;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _BarColumn(
          element: atomCount.element,
          count: atomCount.reactantsCount,
        ),
        SizedBox(
          width: 50,
          height: 80,
          child: Center(
            child: Text(
              balanced ? '=' : '\u2260',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: balanced
                    ? const Color(0xFFFFFF00)
                    : const Color.fromRGBO(46, 107, 178, 1),
              ),
            ),
          ),
        ),
        _BarColumn(
          element: atomCount.element,
          count: atomCount.productsCount,
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({required this.element, required this.count});
  final BceElement element;
  final int count;

  @override
  Widget build(BuildContext context) {
    final displayCount = count;
    final height = displayCount <= BarChartsNode.maxAtoms
        ? displayCount * BarChartsNode.unitBarHeight
        : BarChartsNode.maxAtoms * BarChartsNode.unitBarHeight;
    final showArrow = displayCount > BarChartsNode.maxAtoms;

    return SizedBox(
      width: BarChartsNode.barWidth + 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$displayCount',
            style: const TextStyle(fontFamily: 'Arial', fontSize: 18),
          ),
          const SizedBox(height: 2),
          if (displayCount > 0)
            CustomPaint(
              size: Size(BarChartsNode.barWidth, height + (showArrow ? 15 : 0)),
              painter: _BarPainter(
                color: Color(element.colorArgb),
                height: height,
                withArrow: showArrow,
              ),
            )
          else
            SizedBox(height: 0, width: BarChartsNode.barWidth),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: Size(
                  12 * BceConstants.particlesScaleFactor,
                  12 * BceConstants.particlesScaleFactor,
                ),
                painter: _AtomDotPainter(Color(element.colorArgb)),
              ),
              const SizedBox(width: 3),
              Text(
                element.symbol,
                style: const TextStyle(fontFamily: 'Arial', fontSize: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.color,
    required this.height,
    required this.withArrow,
  });
  final Color color;
  final double height;
  final bool withArrow;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (!withArrow) {
      final rect = Rect.fromLTWH(0, size.height - height, size.width, height);
      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, stroke);
    } else {
      final arrowH = 15.0;
      final path = Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, arrowH)
        ..lineTo(size.width * 0.75, arrowH)
        ..lineTo(size.width * 0.75, size.height)
        ..lineTo(size.width * 0.25, size.height)
        ..lineTo(size.width * 0.25, arrowH)
        ..lineTo(0, arrowH)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.height != height || oldDelegate.withArrow != withArrow;
}

class _AtomDotPainter extends CustomPainter {
  _AtomDotPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _AtomDotPainter oldDelegate) =>
      oldDelegate.color != color;
}
