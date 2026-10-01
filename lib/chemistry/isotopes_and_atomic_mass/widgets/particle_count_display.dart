/// ParticleCountDisplay — proton / neutron / electron legend (shred subset).
library;

import 'package:flutter/material.dart';

import '../controller/make_isotopes_controller.dart';
import '../iaam_constants.dart';
import '../painters/nucleon_ball_painter.dart';

class ParticleCountDisplay extends StatelessWidget {
  const ParticleCountDisplay({super.key, required this.controller});

  final MakeIsotopesController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Transform.scale(
      scale: 1.1,
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CountChip(
            color: IaamConstants.proton,
            label: 'Protons:',
            count: m.protonCount,
          ),
          const SizedBox(width: 12),
          _CountChip(
            color: IaamConstants.neutron,
            label: 'Neutrons:',
            count: m.neutronCount,
          ),
          const SizedBox(width: 12),
          _CountChip(
            color: const Color(0xFF2196F3),
            label: 'Electrons:',
            count: m.electronCount,
            isElectron: true,
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.color,
    required this.label,
    required this.count,
    this.isElectron = false,
  });

  final Color color;
  final String label;
  final int count;
  final bool isElectron;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(18, 18),
          painter: _MiniParticlePainter(color: color, electron: isElectron),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MiniParticlePainter extends CustomPainter {
  _MiniParticlePainter({required this.color, required this.electron});

  final Color color;
  final bool electron;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;
    if (electron) {
      canvas.drawCircle(c, r * 0.7, Paint()..color = color);
    } else {
      NucleonBallPainter.paint(canvas, c, r, color);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniParticlePainter oldDelegate) =>
      oldDelegate.color != color;
}
