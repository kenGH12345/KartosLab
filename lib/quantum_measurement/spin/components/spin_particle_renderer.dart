/// Shaded-sphere style spin particles (programmatic, not asset substitution).
library;

import 'package:flutter/material.dart';

import '../animation/spin_particle_simulation.dart';
import '../transform/spin_view_transform.dart';

class SpinParticleRenderer extends StatelessWidget {
  const SpinParticleRenderer({
    super.key,
    required this.particles,
    required this.transform,
  });

  final List<SpinParticle> particles;
  final SpinViewTransform transform;

  static const radius = 6.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final p in particles)
          if (p.visible)
            Builder(
              builder: (context) {
                final v = transform.physicsToView(p.position);
                return Positioned(
                  left: v.dx - radius,
                  top: v.dy - radius,
                  width: radius * 2,
                  height: radius * 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFF4488CC), Color(0xFF224488)],
                        stops: [0.0, 0.55, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(blurRadius: 2, color: Colors.black26),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}

class SpinBlockerView extends StatelessWidget {
  const SpinBlockerView({
    super.key,
    required this.center,
    required this.blockUp,
  });

  final Offset center;
  final bool blockUp;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - 2,
      top: center.dy - 18,
      child: Transform.rotate(
        angle: blockUp ? -0.175 : 0.175, // ±10°
        child: Container(
          width: 4,
          height: 35,
          color: Colors.black,
        ),
      ),
    );
  }
}
