import 'package:flutter/material.dart';

import '../model/substance_type.dart';
import '../som_colors.dart';
import '../som_constants.dart';
import '../som_strings.dart';

/// Substance panel for Phase Changes — Neon / Argon / O2 / Water / Adjustable.
///
/// Row spacing kept dense to match PhET `PhaseChangesMoleculesControlPanel`
/// so Molecules + Interaction Potential + Phase Diagram fit in 834×504.
class PhaseChangesSubstancePanel extends StatelessWidget {
  const PhaseChangesSubstancePanel({
    super.key,
    required this.substance,
    required this.onChanged,
    required this.epsilon,
    required this.onEpsilonChanged,
    this.width = 170,
  });

  final SubstanceType substance;
  final ValueChanged<SubstanceType> onChanged;
  final double epsilon;
  final ValueChanged<double> onEpsilonChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final showSlider = substance == SubstanceType.adjustableAtom;
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
      decoration: BoxDecoration(
        color: SomColors.controlPanelBackground,
        border: Border.all(color: SomColors.controlPanelStroke, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            SomStrings.atomsAndMolecules,
            style: TextStyle(
              color: SomColors.controlPanelText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          _row(SomStrings.neon, SubstanceType.neon, SomConstants.neonColor),
          _row(SomStrings.argon, SubstanceType.argon, SomConstants.argonColor),
          _row(
            SomStrings.oxygen,
            SubstanceType.diatomicOxygen,
            SomConstants.oxygenColor,
          ),
          _row(
            SomStrings.water,
            SubstanceType.water,
            SomConstants.oxygenColor,
          ),
          _row(
            SomStrings.adjustableAttraction,
            SubstanceType.adjustableAtom,
            SomConstants.adjustableAttractionColor,
          ),
          if (showSlider) ...[
            const SizedBox(height: 4),
            const Text(
              SomStrings.interactionStrength,
              style: TextStyle(color: SomColors.controlPanelText, fontSize: 10),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: const Color(0xFF71EDFF),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFF71EDFF),
              ),
              child: SizedBox(
                height: 28,
                child: Slider(
                  value: epsilon.clamp(
                    SomConstants.minAdjustableEpsilon,
                    SomConstants.maxAdjustableEpsilon,
                  ),
                  min: SomConstants.minAdjustableEpsilon,
                  max: SomConstants.maxAdjustableEpsilon,
                  onChanged: onEpsilonChanged,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, SubstanceType type, Color swatch) {
    final selected = substance == type;
    return Material(
      color: selected ? const Color(0xFF3A3A5A) : Colors.transparent,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: () => onChanged(type),
        borderRadius: BorderRadius.circular(3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            children: [
              CustomPaint(
                size: const Size(12, 12),
                painter: _RadioDotPainter(selected: selected),
              ),
              const SizedBox(width: 6),
              Container(
                width: 14,
                height: 14,
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
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        ..strokeWidth = 1.2
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
