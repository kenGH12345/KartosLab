import 'dart:math' as math;

import '../waves_intro_constants.dart';

/// Port of PhET `SoundParticle.ts` with seeded [math.Random].
///
/// [已确认] RANDOMNESS=14.75, FRICTION_SCALE=0.732, RESTORATION_FORCE_SCALE=0.5
class SoundParticle {
  SoundParticle({
    required this.i,
    required this.j,
    required this.x,
    required this.y,
  })  : initialX = x,
        initialY = y;

  final int i;
  final int j;
  final double initialX;
  final double initialY;
  double x;
  double y;
  double vx = 0;
  double vy = 0;

  static const double randomness = 14.75;
  static const double frictionScale = 0.732;
  static const double restorationForceScale = 0.5;

  void applyForce({
    required double fx,
    required double fy,
    required double dt,
    required double frequency,
    required double frequencyMin,
    required double frequencyMax,
    required math.Random random,
  }) {
    var forceX = fx + (random.nextDouble() - 0.5) * 2 * randomness;
    var forceY = fy + (random.nextDouble() - 0.5) * 2 * randomness;

    final restorationSpringConstant = WavesIntroConstants.linear(
          frequencyMin,
          frequencyMax,
          2 * 1.05,
          6.5 * 0.8,
          frequency,
        ) *
        restorationForceScale;
    final fSpringX = -restorationSpringConstant * (x - initialX);
    final fSpringY = -restorationSpringConstant * (y - initialY);
    vx += forceX + fSpringX;
    vy += forceY + fSpringY;
    vx *= frictionScale;
    vy *= frictionScale;
    x += vx * dt;
    y += vy * dt;
  }

  void resetPosition() {
    x = initialX;
    y = initialY;
    vx = 0;
    vy = 0;
  }
}
