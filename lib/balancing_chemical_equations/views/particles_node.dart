import 'package:flutter/material.dart';

import '../bce_constants.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';
import 'bce_molecule_node.dart';
import 'horizontal_aligner.dart';

/// PhET `ParticlesNode` + `ParticlesAccordionBox` pair.
class ParticlesNode extends StatelessWidget {
  const ParticlesNode({
    super.key,
    required this.equation,
    required this.aligner,
    required this.boxSize,
    required this.coefficientsMax,
    required this.reactantsExpanded,
    required this.productsExpanded,
    required this.onToggleReactants,
    required this.onToggleProducts,
    this.arrowHighlightEnabled = true,
  });

  final Equation equation;
  final HorizontalAligner aligner;
  final Size boxSize;
  final int coefficientsMax;
  final bool reactantsExpanded;
  final bool productsExpanded;
  final VoidCallback onToggleReactants;
  final VoidCallback onToggleProducts;
  final bool arrowHighlightEnabled;

  static const boxColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: equation,
      builder: (context, _) {
        final arrowColor = equation.isBalanced && arrowHighlightEnabled
            ? const Color(0xFFFFFF00)
            : const Color.fromRGBO(46, 107, 178, 1);

        return SizedBox(
          width: aligner.screenWidth,
          height: boxSize.height + 28,
          child: Stack(
            children: [
              Positioned(
                left: aligner.reactantsBoxLeft,
                top: 0,
                child: _AccordionBox(
                  title: 'Reactants',
                  width: boxSize.width,
                  height: boxSize.height,
                  expanded: reactantsExpanded,
                  onToggle: onToggleReactants,
                  child: _MoleculeStack(
                    terms: equation.reactants,
                    xOffsets: aligner.reactantXOffsets(equation),
                    boxLeft: aligner.reactantsBoxLeft,
                    boxWidth: boxSize.width,
                    boxHeight: boxSize.height,
                    coefficientsMax: coefficientsMax,
                  ),
                ),
              ),
              Positioned(
                left: aligner.screenCenterX - 35,
                top: boxSize.height / 2 - 15,
                child: CustomPaint(
                  size: const Size(70, 30),
                  painter: _ParticlesArrowPainter(color: arrowColor),
                ),
              ),
              Positioned(
                left: aligner.productsBoxLeft,
                top: 0,
                child: _AccordionBox(
                  title: 'Products',
                  width: boxSize.width,
                  height: boxSize.height,
                  expanded: productsExpanded,
                  onToggle: onToggleProducts,
                  child: _MoleculeStack(
                    terms: equation.products,
                    xOffsets: aligner.productXOffsets(equation),
                    boxLeft: aligner.productsBoxLeft,
                    boxWidth: boxSize.width,
                    boxHeight: boxSize.height,
                    coefficientsMax: coefficientsMax,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccordionBox extends StatelessWidget {
  const _AccordionBox({
    required this.title,
    required this.width,
    required this.height,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final double width;
  final double height;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ParticlesNode.boxColor,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Stack(
          children: [
            // Expand/collapse button (top-left) — PhET AccordionBox style.
            Positioned(
              left: 5,
              top: 5,
              child: GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79722),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.black54, width: 0.5),
                  ),
                  child: CustomPaint(
                    size: const Size(15, 15),
                    painter: _PlusMinusPainter(expanded: expanded),
                  ),
                ),
              ),
            ),
            if (!expanded)
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}

class _MoleculeStack extends StatelessWidget {
  const _MoleculeStack({
    required this.terms,
    required this.xOffsets,
    required this.boxLeft,
    required this.boxWidth,
    required this.boxHeight,
    required this.coefficientsMax,
  });

  final List<EquationTerm> terms;
  final List<double> xOffsets;
  final double boxLeft;
  final double boxWidth;
  final double boxHeight;
  final int coefficientsMax;

  @override
  Widget build(BuildContext context) {
    final rowHeight = boxHeight / coefficientsMax;
    final children = <Widget>[];

    for (var i = 0; i < terms.length; i++) {
      final term = terms[i];
      final coeff = term.coefficient;
      final localX = xOffsets[i] - boxLeft;
      var y = boxHeight - rowHeight / 2;

      for (var j = 0; j < coeff; j++) {
        final molSize = BceMoleculeNode.layoutSize(
          term.molecule,
          scale: BceConstants.particlesScaleFactor,
        );
        children.add(
          Positioned(
            left: localX - molSize.width / 2,
            top: y - molSize.height / 2,
            child: BceMoleculeNode(
              molecule: term.molecule,
              scale: BceConstants.particlesScaleFactor,
            ),
          ),
        );
        y -= rowHeight;
      }
    }

    return Stack(clipBehavior: Clip.hardEdge, children: children);
  }
}

class _ParticlesArrowPainter extends CustomPainter {
  _ParticlesArrowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.1)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.9)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black87,
    );
  }

  @override
  bool shouldRepaint(covariant _ParticlesArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PlusMinusPainter extends CustomPainter {
  _PlusMinusPainter({required this.expanded});
  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(3, cy), Offset(size.width - 3, cy), p);
    if (!expanded) {
      canvas.drawLine(Offset(cx, 3), Offset(cx, size.height - 3), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PlusMinusPainter oldDelegate) =>
      oldDelegate.expanded != expanded;
}
