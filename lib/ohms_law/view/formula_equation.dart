import 'package:flutter/material.dart';

import '../model/ohms_law_model.dart';
import '../ohms_law_view_constants.dart';

/// PhET `FormulaNode` — dynamic `V = I R` (no multiply glyph).
class FormulaEquation extends StatelessWidget {
  const FormulaEquation({super.key, required this.model});

  final OhmsLawModel model;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(640, 220),
      painter: _FormulaPainter(model: model),
    );
  }
}

class _FormulaPainter extends CustomPainter {
  _FormulaPainter({required this.model});

  final OhmsLawModel model;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height * 0.55;

    _paintScaledLetter(
      canvas,
      'V',
      OhmsLawViewConstants.voltageLocalX,
      cy,
      OhmsLawViewConstants.othersScaleM * model.getNormalizedVoltage() +
          OhmsLawViewConstants.othersScaleB,
      OhmsLawViewConstants.blue,
    );
    _paintScaledLetter(
      canvas,
      'I',
      OhmsLawViewConstants.currentLocalX,
      cy,
      OhmsLawViewConstants.currentScaleM * model.getNormalizedCurrent() +
          OhmsLawViewConstants.currentScaleB,
      OhmsLawViewConstants.redColorblind,
    );
    _paintScaledLetter(
      canvas,
      'R',
      OhmsLawViewConstants.resistanceLocalX,
      cy,
      OhmsLawViewConstants.othersScaleM * model.getNormalizedResistance() +
          OhmsLawViewConstants.othersScaleB,
      OhmsLawViewConstants.blue,
    );

    final equals = TextPainter(
      text: TextSpan(
        text: '=',
        style: TextStyle(
          fontFamily: OhmsLawViewConstants.fontFamily,
          fontSize: OhmsLawViewConstants.equalsFontSize,
          fontWeight: FontWeight.bold,
          color: OhmsLawViewConstants.black,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    equals.paint(
      canvas,
      Offset(
        OhmsLawViewConstants.equalsLocalX - equals.width / 2,
        cy - equals.height / 2,
      ),
    );
  }

  void _paintScaledLetter(
    Canvas canvas,
    String letter,
    double centerX,
    double centerY,
    double scale,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontFamily: OhmsLawViewConstants.fontFamily,
          fontSize: OhmsLawViewConstants.formulaLetterBaseSize,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(scale);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FormulaPainter oldDelegate) => true;
}
