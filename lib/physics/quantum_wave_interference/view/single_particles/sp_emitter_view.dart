import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../assets/qwi_assets.dart';
import '../layout/single_particles_layout_spec.dart';
import '../single_particles/single_particles_controller.dart';

/// PhET `SingleParticleEmitterNode` — SVG body + red sticky fire button.
class SpEmitterView extends StatelessWidget {
  const SpEmitterView({super.key, required this.controller, required this.bounds});

  final SingleParticlesController controller;
  final Size bounds;

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    final enabled = !scene.isMaxHitsReached && !scene.isPacketActive;
    final lit = scene.isPacketActive;
    final r = SingleParticlesLayoutConstants.emitterButtonRadius;

    return SizedBox(
      width: bounds.width,
      height: bounds.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              QwiAssets.singleParticleEmitter,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
            ),
          ),
          // Red button ~32% from left, vertically centered (PhET layout).
          Positioned(
            left: bounds.width * 0.32 - r,
            top: bounds.height * 0.5 - r,
            width: r * 2,
            height: r * 2,
            child: GestureDetector(
              key: const Key('sp_fire_button'),
              onTap: enabled ? controller.fireOnce : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lit
                      ? const Color(0xFFE53935)
                      : enabled
                          ? const Color(0xFFC62828)
                          : const Color(0xFFAAAAAA),
                  border: Border.all(color: Colors.black87),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.35),
                      offset: Offset(-r * 0.2, -r * 0.2),
                      blurRadius: r * 0.3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
