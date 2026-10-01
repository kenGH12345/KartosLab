import 'package:flutter/material.dart';

import '../model/equation.dart';
import '../model/equation_term.dart';
import 'coefficient_picker.dart';
import 'horizontal_aligner.dart';

/// PhET `EquationNode` — coefficient pickers + chemical symbols + arrow.
class BceEquationNode extends StatelessWidget {
  const BceEquationNode({
    super.key,
    required this.equation,
    required this.aligner,
    this.fontSize = 32,
    this.coefficientsEditable = true,
    this.balancedHighlightEnabled = true,
  });

  final Equation equation;
  final HorizontalAligner aligner;
  final double fontSize;
  final bool coefficientsEditable;
  final bool balancedHighlightEnabled;

  static const unbalancedArrow = Color.fromRGBO(46, 107, 178, 1);
  static const balancedArrow = Color(0xFFFFFF00);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: equation,
      builder: (context, _) {
        final reactantOffsets = aligner.reactantXOffsets(equation);
        final productOffsets = aligner.productXOffsets(equation);
        final arrowColor = equation.isBalanced && balancedHighlightEnabled
            ? balancedArrow
            : unbalancedArrow;

        return SizedBox(
          width: aligner.screenWidth,
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ..._side(
                equation.reactants,
                reactantOffsets,
                showPlus: true,
              ),
              Positioned(
                left: aligner.screenCenterX - 35,
                top: 28,
                child: CustomPaint(
                  size: const Size(70, 30),
                  painter: _ArrowPainter(color: arrowColor),
                ),
              ),
              ..._side(
                equation.products,
                productOffsets,
                showPlus: true,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _side(
    List<EquationTerm> terms,
    List<double> offsets, {
    required bool showPlus,
  }) {
    final widgets = <Widget>[];
    for (var i = 0; i < terms.length; i++) {
      final term = terms[i];
      final cx = offsets[i];
      widgets.add(
        Positioned(
          left: cx - 50,
          top: 0,
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CoefficientPicker(
                term: term,
                fontSize: fontSize,
                enabled: coefficientsEditable,
              ),
              const SizedBox(height: 2),
              _FormulaText(symbol: term.molecule.symbol, fontSize: fontSize),
            ],
          ),
        ),
      );
      if (showPlus && i < terms.length - 1) {
        final mid = (offsets[i] + offsets[i + 1]) / 2;
        widgets.add(
          Positioned(
            left: mid - 8,
            top: 36,
            child: Text(
              '+',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: fontSize * 0.85,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

/// Renders RichText-style `H<sub>2</sub>O` as baseline + subscripts.
class _FormulaText extends StatelessWidget {
  const _FormulaText({required this.symbol, required this.fontSize});
  final String symbol;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'<sub>(.*?)</sub>|([^<]+)');
    for (final m in re.allMatches(symbol)) {
      if (m.group(1) != null) {
        spans.add(TextSpan(
          text: m.group(1),
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: fontSize * 0.65,
            height: 1,
          ),
        ));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(
          text: m.group(2),
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: fontSize,
            height: 1,
          ),
        ));
      }
    }
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.1)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.9)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black87,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
