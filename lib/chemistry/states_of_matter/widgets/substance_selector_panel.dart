import 'package:flutter/material.dart';

import '../model/substance_type.dart';
import '../som_colors.dart';
import '../som_constants.dart';
import '../som_strings.dart';

/// Substance selector — Neon / Argon / Oxygen / Water (States screen).
class SubstanceSelectorPanel extends StatelessWidget {
  const SubstanceSelectorPanel({
    super.key,
    required this.substance,
    required this.onChanged,
    this.width = 175,
  });

  final SubstanceType substance;
  final ValueChanged<SubstanceType> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: SomColors.controlPanelBackground,
        border: Border.all(color: SomColors.controlPanelStroke, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            SomStrings.atomsAndMolecules,
            style: const TextStyle(
              color: SomColors.controlPanelText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _SubstanceRow(
            label: SomStrings.neon,
            selected: substance == SubstanceType.neon,
            swatch: SomConstants.neonColor,
            onTap: () => onChanged(SubstanceType.neon),
          ),
          const SizedBox(height: 6),
          _SubstanceRow(
            label: SomStrings.argon,
            selected: substance == SubstanceType.argon,
            swatch: SomConstants.argonColor,
            onTap: () => onChanged(SubstanceType.argon),
          ),
          const SizedBox(height: 6),
          _SubstanceRow(
            label: SomStrings.oxygen,
            selected: substance == SubstanceType.diatomicOxygen,
            swatch: SomConstants.oxygenColor,
            onTap: () => onChanged(SubstanceType.diatomicOxygen),
          ),
          const SizedBox(height: 6),
          _SubstanceRow(
            label: SomStrings.water,
            selected: substance == SubstanceType.water,
            swatch: SomConstants.oxygenColor,
            onTap: () => onChanged(SubstanceType.water),
          ),
        ],
      ),
    );
  }
}

class _SubstanceRow extends StatelessWidget {
  const _SubstanceRow({
    required this.label,
    required this.selected,
    required this.swatch,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color swatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF3A3A5A) : const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              // PhET-style radio indicator (not Material Icons)
              CustomPaint(
                size: const Size(16, 16),
                painter: _RadioDotPainter(selected: selected),
              ),
              const SizedBox(width: 8),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.35),
                    colors: [
                      Color.lerp(swatch, Colors.white, 0.55)!,
                      swatch,
                      Color.lerp(swatch, Colors.black, 0.35)!,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDotPainter extends CustomPainter {
  _RadioDotPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white70,
    );
    if (selected) {
      canvas.drawCircle(c, r * 0.45, Paint()..color = const Color(0xFF71EDFF));
    }
  }

  @override
  bool shouldRepaint(covariant _RadioDotPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
