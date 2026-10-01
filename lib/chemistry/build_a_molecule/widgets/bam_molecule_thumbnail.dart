import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../model/bam_atom.dart';
import '../model/bam_complete_molecule.dart';

/// Canvas space-fill thumbnail from PubChem 3D coords.
/// Ported from BAMIconFactory + Molecule3DNode (Canvas 2D projection, not WebGL).
class BamMoleculeThumbnail extends StatelessWidget {
  const BamMoleculeThumbnail({
    super.key,
    required this.molecule,
    this.background = Colors.black,
    this.yaw = 0.55,
    this.pitch = 0.35,
  });

  final BamCompleteMolecule molecule;
  final Color background;
  final double yaw;
  final double pitch;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: CustomPaint(
        painter: BamMoleculeThumbnailPainter(
          molecule: molecule,
          yaw: yaw,
          pitch: pitch,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class BamMoleculeThumbnailPainter extends CustomPainter {
  BamMoleculeThumbnailPainter({
    required this.molecule,
    required this.yaw,
    required this.pitch,
  });

  final BamCompleteMolecule molecule;
  final double yaw;
  final double pitch;

  @override
  void paint(Canvas canvas, Size size) {
    final projected = <_P>[];
    for (final a in molecule.atoms) {
      if (a is! BamPubChemAtom) continue;
      var x = a.x3d * 75;
      var y = a.y3d * 75;
      var z = a.z3d * 75;

      final cosY = math.cos(yaw);
      final sinY = math.sin(yaw);
      final x1 = x * cosY - z * sinY;
      final z1 = x * sinY + z * cosY;
      x = x1;
      z = z1;

      final cosP = math.cos(pitch);
      final sinP = math.sin(pitch);
      final y1 = y * cosP - z * sinP;
      final z2 = y * sinP + z * cosP;
      y = y1;
      z = z2;

      projected.add(_P(x, y, z, a));
    }

    if (projected.isEmpty) {
      // 2d-only molecules: fall back to 2d coords
      for (final a in molecule.atoms) {
        if (a is! BamPubChemAtom) continue;
        projected.add(_P(a.x2d * 40, -a.y2d * 40, 0, a));
      }
    }
    if (projected.isEmpty) return;

    projected.sort((a, b) => a.z.compareTo(b.z));
    var maxR = 1.0;
    for (final p in projected) {
      maxR = math.max(
        maxR,
        math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z) + p.atom.covalentRadius,
      );
    }
    final scale = math.min(size.width, size.height) * 0.42 / maxR;
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final p in projected) {
      final depth = ((p.z / maxR) + 1) / 2;
      final r = (p.atom.covalentRadius * scale * 0.85).clamp(3.0, 28.0);
      final center = Offset(cx + p.x * scale, cy - p.y * scale);
      final base = p.atom.element.color;
      final shade = Color.lerp(Colors.black, base, 0.5 + 0.5 * depth)!;
      canvas.drawCircle(center, r.toDouble(), Paint()..color = shade);
      // highlight
      canvas.drawCircle(
        center + Offset(-r * 0.25, -r * 0.25),
        r * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BamMoleculeThumbnailPainter oldDelegate) =>
      oldDelegate.molecule != molecule;
}

class _P {
  _P(this.x, this.y, this.z, this.atom);
  final double x, y, z;
  final BamPubChemAtom atom;
}

/// Shared 3D dialog painter entry — reuses thumbnail math with larger size.
class BamMolecule3dView extends StatefulWidget {
  const BamMolecule3dView({super.key, required this.molecule});

  final BamCompleteMolecule molecule;

  @override
  State<BamMolecule3dView> createState() => _BamMolecule3dViewState();
}

class _BamMolecule3dViewState extends State<BamMolecule3dView> {
  double _yaw = 0.4;
  double _pitch = 0.3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) {
        setState(() {
          _yaw += d.delta.dx * 0.01;
          _pitch = (_pitch + d.delta.dy * 0.01).clamp(-1.2, 1.2);
        });
      },
      child: ColoredBox(
        color: BamConstants.completeBackgroundColor,
        child: CustomPaint(
          painter: BamMoleculeThumbnailPainter(
            molecule: widget.molecule,
            yaw: _yaw,
            pitch: _pitch,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
