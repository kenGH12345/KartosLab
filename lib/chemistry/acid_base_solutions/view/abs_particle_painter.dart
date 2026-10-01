import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/abs_colors.dart';
import '../model/particle_key.dart';

/// Procedural particle drawing matching `createParticleNode.ts` + `AtomNode.ts`.
class AbsParticlePainter {
  AbsParticlePainter._();

  static void paintAtom(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final focal = Offset(center.dx - radius * 0.2, center.dy - radius * 0.3);
    final shader = ui.Gradient.radial(
      focal,
      radius * 2,
      [Colors.white, color, Colors.black],
      const [0.0, 0.33, 1.0],
      TileMode.clamp,
      null,
      focal,
      0.25,
    );
    canvas.drawCircle(center, radius, Paint()..shader = shader);
  }

  static void paintKey(Canvas canvas, ParticleKey key, Offset origin) {
    void atom(double r, Color c, double dx, double dy) {
      paintAtom(canvas, origin + Offset(dx, dy), r, c);
    }

    switch (key) {
      case ParticleKey.a:
        atom(7, AbsColors.a, 0, 0);
      case ParticleKey.b:
        atom(7, AbsColors.b, 0, 0);
      case ParticleKey.bh:
        atom(4, AbsColors.bh, -6, -6);
        atom(7, AbsColors.bh, 0, 0);
      case ParticleKey.h2o:
        atom(4, AbsColors.h2o, 0, -9);
        atom(7, AbsColors.h2o, 0, 0);
        atom(4, AbsColors.h2o, -6, 5);
      case ParticleKey.h3o:
        atom(4, AbsColors.h3o, 3, -7.5);
        atom(4, AbsColors.h3o, 3, 7.5);
        atom(7, AbsColors.h3o, 0, 0);
        atom(4, AbsColors.h3o, -8, 0);
      case ParticleKey.ha:
        atom(7, AbsColors.ha, 0, 0);
        atom(4, AbsColors.ha, -8, -1);
      case ParticleKey.m:
        atom(7, AbsColors.m, 0, 0);
      case ParticleKey.moh:
        atom(6, AbsColors.moh, 0, 0);
        _bar(canvas, origin + const Offset(0, 10));
        atom(7, AbsColors.moh, 15, 0);
        atom(4, AbsColors.moh, 22, -4);
        _bar(canvas, origin + const Offset(15, 10));
        // Plus on M (vertical tick through horizontal bar)
        canvas.drawRect(
          Rect.fromCenter(
            center: origin + const Offset(0, 10),
            width: 1,
            height: 6,
          ),
          Paint()..color = Colors.black,
        );
      case ParticleKey.oh:
        atom(4, AbsColors.oh, 8, -3);
        atom(7, AbsColors.oh, 0, 0);
    }
  }

  static void _bar(Canvas canvas, Offset c) {
    canvas.drawRect(
      Rect.fromCenter(center: c, width: 6, height: 1),
      Paint()..color = Colors.black,
    );
  }

  static Size approximateSize(ParticleKey key) {
    switch (key) {
      case ParticleKey.moh:
        return const Size(30, 20);
      case ParticleKey.h3o:
        return const Size(24, 24);
      case ParticleKey.h2o:
        return const Size(20, 24);
      case ParticleKey.bh:
        return const Size(20, 20);
      case ParticleKey.ha:
      case ParticleKey.oh:
        return const Size(20, 16);
      default:
        return const Size(16, 16);
    }
  }
}

/// Widget icon for radio labels / equations.
class AbsParticleIcon extends StatelessWidget {
  const AbsParticleIcon(this.particleKey, {super.key, this.scale = 1.0});

  final ParticleKey particleKey;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = AbsParticlePainter.approximateSize(particleKey);
    return CustomPaint(
      size: Size(size.width * scale, size.height * scale),
      painter: _ParticleIconPainter(particleKey, scale),
    );
  }
}

class _ParticleIconPainter extends CustomPainter {
  _ParticleIconPainter(this.key, this.scale);

  final ParticleKey key;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);
    final origin = Offset(size.width / (2 * scale), size.height / (2 * scale));
    AbsParticlePainter.paintKey(canvas, key, origin);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ParticleIconPainter oldDelegate) =>
      oldDelegate.key != key || oldDelegate.scale != scale;
}
