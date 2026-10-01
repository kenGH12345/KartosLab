/// PhET Atom — an atom model with element, symbol, atomic number, mass,
/// and charge.
///
/// Supports drawing as a Bohr-style diagram (nucleus + electron shells).
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'nucleus.dart';

class Atom {
  final String element;
  final String symbol;
  final int atomicNumber;
  final int massNumber;
  final int charge;
  Offset position;
  double scale;

  Atom({
    required this.element,
    required this.symbol,
    required this.atomicNumber,
    required this.massNumber,
    this.charge = 0,
    this.position = Offset.zero,
    this.scale = 1,
  });

  /// Number of protons.
  int get protons => atomicNumber;

  /// Number of neutrons.
  int get neutrons => massNumber - atomicNumber;

  /// Number of electrons (adjusts for charge).
  int get electrons => atomicNumber - charge;

  /// Get electron shell configuration (simplified).
  List<int> get electronShells {
    final shells = <int>[];
    var remaining = electrons;
    var capacity = 2;
    while (remaining > 0) {
      final n = remaining > capacity ? capacity : remaining;
      shells.add(n);
      remaining -= n;
      capacity += 6; // 2, 8, 14, ... (simplified)
    }
    return shells;
  }

  /// Draw the atom (Bohr model).
  void draw(Canvas canvas) {
    final r = 40.0 * scale;
    // Electron shells
    for (int i = 0; i < electronShells.length; i++) {
      final shellR = r * (1 + i * 0.5);
      canvas.drawCircle(position, shellR, Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5);

      // Electrons on shell
      final count = electronShells[i];
      for (int j = 0; j < count; j++) {
        final angle = 2 * pi * j / count;
        final ex = position.dx + cos(angle) * shellR;
        final ey = position.dy + sin(angle) * shellR;
        canvas.drawCircle(Offset(ex, ey), 3, Paint()..color = const Color(0xff42a5f5));
      }
    }

    // Nucleus
    final nucleus = Nucleus(center: position, protons: protons, neutrons: neutrons, scale: scale);
    nucleus.draw(canvas);
  }
}
