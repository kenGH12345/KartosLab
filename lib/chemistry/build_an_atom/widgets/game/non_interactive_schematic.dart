import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/baa_constants.dart';
import '../../model/baa_particle.dart';
import '../../model/number_atom.dart';
import '../../painters/particle_sphere_painter.dart';

/// PhET `NonInteractiveSchematicAtomNode` — static shells + packed nucleus.
class NonInteractiveSchematicAtom extends StatelessWidget {
  const NonInteractiveSchematicAtom({
    super.key,
    required this.atom,
    this.size = 220,
  });

  final NumberAtom atom;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SchematicPainter(atom: atom),
      ),
    );
  }
}

class _SchematicPainter extends CustomPainter {
  _SchematicPainter({required this.atom});
  final NumberAtom atom;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 280;
    final innerR = BAAConstants.innerElectronShellRadius * scale;
    final outerR = BAAConstants.outerElectronShellRadius * scale;

    final ring = Paint()
      ..color = const Color(0xFF4A90D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _dashedCircle(canvas, c, innerR, ring);
    _dashedCircle(canvas, c, outerR, ring);

    final nucleons = <BaaParticleType>[];
    for (var i = 0; i < atom.protons; i++) {
      nucleons.add(BaaParticleType.proton);
    }
    for (var i = 0; i < atom.neutrons; i++) {
      nucleons.add(BaaParticleType.neutron);
    }
    final nR = BAAConstants.nucleonRadius * scale;
    for (var i = 0; i < nucleons.length; i++) {
      final offset = _nucleusOffset(i, nucleons.length) * scale;
      final center = Offset(c.dx + offset.dx, c.dy + offset.dy);
      ParticleSpherePainter.paint(
        canvas,
        center,
        nR,
        ParticleSpherePainter.colorFor(nucleons[i]),
      );
    }

    final eR = BAAConstants.electronRadius * scale * 0.85;
    final innerCount = atom.electrons.clamp(0, 2);
    final outerCount = (atom.electrons - innerCount).clamp(0, 8);
    _placeElectrons(canvas, c, innerR, innerCount, eR);
    _placeElectrons(canvas, c, outerR, outerCount, eR);
  }

  void _placeElectrons(
    Canvas canvas,
    Offset c,
    double r,
    int count,
    double eR,
  ) {
    for (var i = 0; i < count; i++) {
      final a = -math.pi / 2 + i * (2 * math.pi / math.max(count, 1));
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      ParticleSpherePainter.paint(
        canvas,
        p,
        eR,
        ParticleSpherePainter.colorFor(BaaParticleType.electron),
      );
    }
  }

  Offset _nucleusOffset(int index, int total) {
    if (total <= 1) return Offset.zero;
    const step = 14.0;
    final angle = index * 2.4;
    final ring = (index / 3).floor();
    final rad = step * (0.5 + ring * 0.85);
    return Offset(rad * math.cos(angle), rad * math.sin(angle));
  }

  void _dashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final circ = 2 * math.pi * r;
    var drawn = 0.0;
    while (drawn < circ) {
      final a0 = drawn / r;
      final a1 = (drawn + dash) / r;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a0,
        a1 - a0,
        false,
        paint,
      );
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SchematicPainter oldDelegate) =>
      oldDelegate.atom != atom;
}
