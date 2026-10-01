import 'package:flutter/material.dart';

import '../model/sound_particle.dart';
import '../waves_intro_constants.dart';

/// Draws sound particles in model coordinates mapped to the wave area.
class SoundParticlesPainter extends CustomPainter {
  SoundParticlesPainter({
    required this.particles,
    required this.waveAreaWidth,
  });

  final List<SoundParticle> particles;
  final double waveAreaWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (waveAreaWidth <= 0) return;
    final scale = size.width / waveAreaWidth;
    final paint = Paint()
      ..color = const Color(0xFFD2D2D2)
      ..style = PaintingStyle.fill;
    final r = 2.2 * (size.width / WavesIntroConstants.waveAreaViewSize);

    for (final p in particles) {
      final dx = p.x * scale;
      final dy = p.y * scale;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SoundParticlesPainter oldDelegate) => true;
}
