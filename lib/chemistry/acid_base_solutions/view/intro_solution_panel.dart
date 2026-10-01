import 'package:flutter/material.dart';

import '../model/abs_colors.dart';
import '../model/intro_model.dart';
import '../model/particle_key.dart';
import '../model/solutions/aqueous_solution.dart';
import 'abs_particle_painter.dart';

/// Intro Solution panel — PhET `IntroSolutionPanel.ts` (AquaRadioButtonGroup).
class IntroSolutionPanel extends StatelessWidget {
  const IntroSolutionPanel({
    super.key,
    required this.model,
    required this.onSelected,
  });

  final IntroModel model;
  final ValueChanged<AqueousSolution> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <({AqueousSolution value, String label, ParticleKey icon})>[
      (value: model.water, label: 'Water (H₂O)', icon: ParticleKey.h2o),
      (
        value: model.strongAcid,
        label: 'Strong Acid (HA)',
        icon: ParticleKey.ha
      ),
      (value: model.weakAcid, label: 'Weak Acid (HA)', icon: ParticleKey.ha),
      (
        value: model.strongBase,
        label: 'Strong Base (MOH)',
        icon: ParticleKey.moh
      ),
      (value: model.weakBase, label: 'Weak Base (B)', icon: ParticleKey.b),
    ];

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AbsColors.controlPanelFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF5A6BB0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Solution',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onSelected(item.value),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    _AquaRadio(
                      selected: identical(model.solution, item.value),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    AbsParticleIcon(item.icon, scale: 0.65),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AquaRadio extends StatelessWidget {
  const _AquaRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 1.5),
        color: Colors.white,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3376C4),
                ),
              ),
            )
          : null,
    );
  }
}
