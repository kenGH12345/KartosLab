import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../model/bam_atom.dart';
import '../model/bam_kit.dart';

/// Draws bonds as lines and atoms as colored circles with optional symbols.
class BamPlayAreaPainter extends CustomPainter {
  BamPlayAreaPainter({
    required this.kit,
    required this.modelToView,
    this.showSymbols = true,
  });

  final BamKit kit;
  final Offset Function(Offset model) modelToView;
  final bool showSymbols;

  @override
  void paint(Canvas canvas, Size size) {
    final bondPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final molecule in kit.molecules) {
      for (final bond in molecule.bonds) {
        final a = bond.a as BamPlayAtom;
        final b = bond.b as BamPlayAtom;
        if (!a.visible || !b.visible) continue;
        canvas.drawLine(modelToView(a.position), modelToView(b.position), bondPaint);
      }
    }

    for (final atom in kit.atomsInPlayArea) {
      if (!atom.visible) continue;
      _paintAtom(canvas, atom);
    }
  }

  void _paintAtom(Canvas canvas, BamPlayAtom atom) {
    final center = modelToView(atom.position);
    // Scale radius: covalentRadius is picometers (~37–118); map to view px.
    final r = (atom.covalentRadius * 0.35).clamp(10.0, 36.0);
    final fill = Paint()..color = atom.element.color;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r, fill);
    canvas.drawCircle(center, r, stroke);

    if (showSymbols) {
      final tp = TextPainter(
        text: TextSpan(
          text: atom.symbol,
          style: TextStyle(
            color: BamConstants.atomTextColor(atom.element.color),
            fontSize: r * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant BamPlayAreaPainter oldDelegate) => true;
}
