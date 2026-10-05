import 'package:flutter/material.dart';

import '../model/bam_atom.dart';
import '../model/bam_kit.dart';
import 'bam_atom_sphere_painter.dart';

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
      if (!atom.visible || atom.dragging) continue;
      _paintAtom(canvas, atom);
    }
  }

  void _paintAtom(Canvas canvas, BamPlayAtom atom) {
    final center = modelToView(atom.position);
    final origin = modelToView(Offset.zero);
    final unit = modelToView(const Offset(1, 0));
    final scale = (unit.dx - origin.dx).abs();
    final r = BamAtomSpherePainter.viewRadius(atom.covalentRadius, scale);
    BamAtomSpherePainter.paint(
      canvas,
      center,
      r,
      atom.element.color,
      symbol: showSymbols ? atom.symbol : null,
    );
  }

  @override
  bool shouldRepaint(covariant BamPlayAreaPainter oldDelegate) => true;
}
