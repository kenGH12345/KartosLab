import 'package:flutter/material.dart';

import '../../model/reaction.dart';
import '../../model/substance.dart';
import 'formula_text.dart';

/// Equation for Molecules screen — `MoleculesEquationNode.ts`.
class MoleculesEquationNode extends StatelessWidget {
  const MoleculesEquationNode({
    super.key,
    required this.reaction,
    this.fill = Colors.white,
    this.fontSize = 28,
  });

  final Reaction reaction;
  final Color fill;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._side(reaction.reactants),
          const SizedBox(width: 15),
          CustomPaint(
            size: const Size(36, 16),
            painter: _ArrowPainter(color: fill),
          ),
          const SizedBox(width: 15),
          ..._side(reaction.products),
        ],
      ),
    );
  }

  List<Widget> _side(List<Substance> terms) {
    final widgets = <Widget>[];
    for (var i = 0; i < terms.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(width: 15));
        widgets.add(Text(
          '+',
          style: TextStyle(color: fill, fontSize: fontSize * 0.85),
        ));
        widgets.add(const SizedBox(width: 15));
      }
      widgets.add(Text(
        '${terms[i].coefficient}',
        style: TextStyle(
          color: fill,
          fontSize: fontSize,
          fontFamily: 'Arial',
        ),
      ));
      widgets.add(const SizedBox(width: 8));
      widgets.add(FormulaText(
        symbolHtml: terms[i].symbol,
        fontSize: fontSize,
        color: fill,
      ));
    }
    return widgets;
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.85)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
