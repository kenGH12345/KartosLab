import 'package:flutter/material.dart';

import '../constants/baa_constants.dart';
import '../model/baa_model.dart';
import '../model/baa_particle.dart';
import '../painters/particle_sphere_painter.dart';

/// shred `ParticleCountDisplay` — labels + particle icon bars.
class ParticleCountPanel extends StatelessWidget {
  const ParticleCountPanel({super.key, required this.model});

  final BAAModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(BAAConstants.displayPanelBackgroundValue),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black54),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _row('Protons:', model.protonCount, BaaParticleType.proton),
                const SizedBox(height: 4),
                _row('Neutrons:', model.neutronCount, BaaParticleType.neutron),
                const SizedBox(height: 4),
                _row('Electrons:', model.electronCount, BaaParticleType.electron),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, int count, BaaParticleType type) {
    final r = type == BaaParticleType.electron ? 3.0 : 5.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 5),
        ...List.generate(count.clamp(0, 13), (i) {
          return Padding(
            padding: const EdgeInsets.only(right: 5),
            child: CustomPaint(
              size: Size(r * 2, r * 2),
              painter: _MiniSphere(ParticleSpherePainter.colorFor(type)),
            ),
          );
        }),
      ],
    );
  }
}

class _MiniSphere extends CustomPainter {
  _MiniSphere(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    ParticleSpherePainter.paint(
      canvas,
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      color,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniSphere oldDelegate) =>
      oldDelegate.color != color;
}
