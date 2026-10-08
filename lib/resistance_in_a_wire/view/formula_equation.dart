import 'package:flutter/material.dart';
import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';

import '../model/resistance_in_a_wire_constants.dart';
import '../model/resistance_in_a_wire_model.dart';
import '../resistance_in_a_wire_view_constants.dart';

/// PhET `FormulaNode` — dynamic `R = ρ L / A` (no multiply glyph).
///
/// Letter scale: `(7 / defaultValue) * value + 1`. VD-02: R is **uncapped**.
class FormulaEquation extends StatelessWidget {
  const FormulaEquation({super.key, required this.model});

  final ResistanceInAWireModel model;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: RiawStrings.equationA11y(),
      child: CustomPaint(
        size: ResistanceInAWireViewConstants.formulaPaintSize,
        painter: _FormulaPainter(model: model),
      ),
    );
  }
}

class _FormulaPainter extends CustomPainter {
  _FormulaPainter({required this.model});

  final ResistanceInAWireModel model;

  @override
  void paint(Canvas canvas, Size size) {
    // Local FormulaNode origin at equals center (100, 0) maps to paint center.
    final origin = Offset(
      size.width / 2 - ResistanceInAWireViewConstants.equalsLocalX,
      size.height / 2,
    );
    canvas.save();
    canvas.translate(origin.dx, origin.dy);

    final r0 = ResistanceInAWireModel.computeResistance(
      ResistanceInAWireConstants.resistivityRange.defaultValue,
      ResistanceInAWireConstants.lengthRange.defaultValue,
      ResistanceInAWireConstants.areaRange.defaultValue,
    );

    _paintScaledLetter(
      canvas,
      'R',
      ResistanceInAWireViewConstants.rLocalX,
      ResistanceInAWireViewConstants.equalsLocalY,
      model.formulaScaleMagnitude(model.resistance, r0),
      ResistanceInAWireViewConstants.red,
    );
    _paintScaledLetter(
      canvas,
      'ρ',
      ResistanceInAWireViewConstants.rhoLocalX,
      ResistanceInAWireViewConstants.rhoLocalY,
      model.formulaScaleMagnitude(
        model.resistivity,
        ResistanceInAWireConstants.resistivityRange.defaultValue,
      ),
      ResistanceInAWireViewConstants.blue,
    );
    _paintScaledLetter(
      canvas,
      'L',
      ResistanceInAWireViewConstants.lengthLocalX,
      ResistanceInAWireViewConstants.lengthLocalY,
      model.formulaScaleMagnitude(
        model.length,
        ResistanceInAWireConstants.lengthRange.defaultValue,
      ),
      ResistanceInAWireViewConstants.blue,
    );
    _paintScaledLetter(
      canvas,
      'A',
      ResistanceInAWireViewConstants.areaLocalX,
      ResistanceInAWireViewConstants.areaLocalY,
      model.formulaScaleMagnitude(
        model.area,
        ResistanceInAWireConstants.areaRange.defaultValue,
      ),
      ResistanceInAWireViewConstants.blue,
    );

    // Equals + fraction line on top (source z-order).
    final equals = TextPainter(
      text: TextSpan(
        text: '=',
        style: TextStyle(
          fontFamily: ResistanceInAWireViewConstants.fontFamily,
          fontSize: ResistanceInAWireViewConstants.equalsFontSize,
          color: ResistanceInAWireViewConstants.black,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    equals.paint(
      canvas,
      Offset(
        ResistanceInAWireViewConstants.equalsLocalX - equals.width / 2,
        ResistanceInAWireViewConstants.equalsLocalY - equals.height / 2,
      ),
    );

    final linePaint = Paint()
      ..color = ResistanceInAWireViewConstants.black
      ..strokeWidth = ResistanceInAWireViewConstants.fractionLineWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(
        ResistanceInAWireViewConstants.fractionLineStartX,
        ResistanceInAWireViewConstants.fractionLineY,
      ),
      Offset(
        ResistanceInAWireViewConstants.fractionLineEndX,
        ResistanceInAWireViewConstants.fractionLineY,
      ),
      linePaint,
    );

    canvas.restore();
  }

  void _paintScaledLetter(
    Canvas canvas,
    String letter,
    double centerX,
    double centerY,
    double scale,
    Color color,
  ) {
    final style = TextStyle(
      fontFamily: ResistanceInAWireViewConstants.fontFamily,
      fontSize: ResistanceInAWireViewConstants.formulaLetterBaseSize,
      color: color,
      height: 1,
    );
    final fill = TextPainter(
      text: TextSpan(text: letter, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    // OutlinedTextNode: background-colored stroke behind fill (width 0.2).
    final outline = TextPainter(
      text: TextSpan(
        text: letter,
        style: style.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth =
                ResistanceInAWireViewConstants.formulaOutlineWidth * 2 /
                    scale.clamp(0.5, 100)
            ..color = ResistanceInAWireViewConstants.background,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(scale);
    final offset = Offset(-fill.width / 2, -fill.height / 2);
    outline.paint(canvas, offset);
    fill.paint(canvas, offset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FormulaPainter oldDelegate) => true;
}
