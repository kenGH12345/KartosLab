/// PhET Molecule — a collection of atoms connected by bonds.
library;

import 'package:flutter/material.dart';
import '../atoms/atom.dart';
import '../bonds/bond.dart';

class Molecule {
  final String name;
  final String formula;
  final List<MoleculeAtom> atoms;
  final List<Bond> bonds;
  Offset position;
  double rotation;

  Molecule({
    required this.name,
    required this.formula,
    required this.atoms,
    required this.bonds,
    this.position = Offset.zero,
    this.rotation = 0,
  });

  void draw(Canvas canvas) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    // Draw bonds first (behind atoms)
    for (final b in bonds) {
      b.draw(canvas);
    }
    // Draw atoms
    for (final a in atoms) {
      a.draw(canvas);
    }

    canvas.restore();
  }
}

/// An atom placed within a molecule (has a relative position).
class MoleculeAtom {
  final Atom atom;
  final Offset offset;
  final double radius;
  final Color color;

  MoleculeAtom({
    required this.atom,
    this.offset = Offset.zero,
    this.radius = 16,
    this.color = const Color(0xffe0e0e0),
  });

  void draw(Canvas canvas) {
    canvas.drawCircle(offset, radius, Paint()..color = color);
    canvas.drawCircle(offset, radius, Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    // Element symbol
    final tp = TextPainter(
      text: TextSpan(text: atom.symbol,
          style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  Offset get position => offset;
}
