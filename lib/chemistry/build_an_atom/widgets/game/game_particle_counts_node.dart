import 'package:flutter/material.dart';

import '../../constants/baa_constants.dart';
import '../../model/baa_particle.dart';
import '../../model/number_atom.dart';
import '../../painters/particle_sphere_painter.dart';

/// PhET Game `ParticleCountsNode` — read-only p/n/e tallies for the prompt.
class GameParticleCountsNode extends StatelessWidget {
  const GameParticleCountsNode({super.key, required this.atom});

  final NumberAtom atom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(BAAConstants.displayPanelBackgroundValue),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black54),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Protons:', atom.protons, BaaParticleType.proton),
            const SizedBox(height: 6),
            _row('Neutrons:', atom.neutrons, BaaParticleType.neutron),
            const SizedBox(height: 6),
            _row('Electrons:', atom.electrons, BaaParticleType.electron),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int count, BaaParticleType type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        ...List.generate(count.clamp(0, 12), (_) {
          return Padding(
            padding: const EdgeInsets.only(right: 3),
            child: ParticleSphereWidget(type: type, scale: 0.45),
          );
        }),
      ],
    );
  }
}
