import 'package:flutter/material.dart';

import '../../model/ph_scale_colors.dart';
import '../../model/ph_scale_constants.dart';
import '../../model/solution_derived_properties.dart';
import '../ph_scale_fonts.dart';
import '../scientific_notation.dart';
import 'molecule_icon.dart';

/// Particle Counts panel — PhET `ParticleCountsNode.ts`.
///
/// Shows **real** Avogadro-scale counts from [SolutionDerivedProperties],
/// **not** Ratio visual particle counts.
class ParticleCountsNode extends StatelessWidget {
  const ParticleCountsNode({
    super.key,
    required this.derived,
  });

  final SolutionDerivedProperties derived;

  static const double _xMargin = 10;
  static const double _yMargin = 5;
  static const double _xSpacing = 10;
  static const double _ySpacing = 6;
  static const TextStyle _valueStyle = TextStyle(
    fontFamily: PhScaleFonts.family,
    fontSize: 22,
    color: Colors.black,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle _formulaStyle = TextStyle(
    fontFamily: PhScaleFonts.family,
    fontSize: 22,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    final h3o = ScientificNotation.from(
      derived.particleCountH3O,
      mantissaDecimalPlaces: 2,
    );
    final oh = ScientificNotation.from(
      derived.particleCountOH,
      mantissaDecimalPlaces: 2,
    );
    // H₂O uses fixed exponent 25 — ParticleCountsNode.ts L76–77
    final h2o = ScientificNotation.from(
      derived.particleCountH2O,
      mantissaDecimalPlaces: 2,
      fixedExponent: 25,
    );

    Widget row({
      required String count,
      required List<InlineSpan> formula,
      required MoleculeKind icon,
      required Color bg,
    }) {
      return Container(
        margin: EdgeInsets.only(bottom: _ySpacing),
        padding: const EdgeInsets.symmetric(
          horizontal: _xMargin,
          vertical: _yMargin,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color.fromARGB(255, 200, 200, 200)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                count,
                textAlign: TextAlign.right,
                style: _valueStyle,
              ),
            ),
            SizedBox(width: _xSpacing),
            Text.rich(TextSpan(style: _formulaStyle, children: formula)),
            SizedBox(width: _xSpacing),
            MoleculeIcon(kind: icon),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        row(
          count: h3o.display,
          formula: const [
            TextSpan(text: 'H'),
            TextSpan(text: '₃', style: TextStyle(fontSize: 16, height: 1.8)),
            TextSpan(text: 'O'),
            TextSpan(text: '⁺', style: TextStyle(fontSize: 16, height: 0.8)),
          ],
          icon: MoleculeKind.h3o,
          bg: PhScaleColors.acidic,
        ),
        row(
          count: oh.display,
          formula: const [
            TextSpan(text: 'OH'),
            TextSpan(text: '⁻', style: TextStyle(fontSize: 16, height: 0.8)),
          ],
          icon: MoleculeKind.oh,
          bg: PhScaleColors.basic,
        ),
        row(
          count: h2o.display,
          formula: const [
            TextSpan(text: 'H'),
            TextSpan(text: '₂', style: TextStyle(fontSize: 16, height: 1.8)),
            TextSpan(text: 'O'),
          ],
          icon: MoleculeKind.h2o,
          bg: PhScaleColors.h2oBackground,
        ),
      ],
    );
  }
}

/// Checkbox panel below beaker — PhET `BeakerControlPanel.ts`.
class BeakerControlPanel extends StatelessWidget {
  const BeakerControlPanel({
    super.key,
    required this.ratioVisible,
    required this.particleCountsVisible,
    required this.onRatioChanged,
    required this.onParticleCountsChanged,
  });

  final bool ratioVisible;
  final bool particleCountsVisible;
  final ValueChanged<bool> onRatioChanged;
  final ValueChanged<bool> onParticleCountsChanged;

  @override
  Widget build(BuildContext context) {
    final font = PhScaleFonts.controlPanel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: PhScaleColors.panelFill,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CheckRow(
            value: ratioVisible,
            onChanged: onRatioChanged,
            child: Text.rich(
              TextSpan(
                style: font,
                children: [
                  TextSpan(
                    text: PhScaleConstants.h3oFormulaPlain,
                    style: font.copyWith(color: PhScaleColors.h3oParticles),
                  ),
                  const TextSpan(text: ' / '),
                  TextSpan(
                    text: PhScaleConstants.ohFormulaPlain,
                    style: font.copyWith(color: PhScaleColors.ohParticles),
                  ),
                  const TextSpan(text: ' Ratio'),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, thickness: 1, color: Colors.black54),
          ),
          _CheckRow(
            value: particleCountsVisible,
            onChanged: onParticleCountsChanged,
            child: Text('Particle Counts', style: font),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.value,
    required this.onChanged,
    required this.child,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: PhScaleConstants.checkboxWidth.toDouble(),
            height: PhScaleConstants.checkboxWidth.toDouble(),
            child: CustomPaint(
              painter: _CheckboxPainter(checked: value),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  _CheckboxPainter({required this.checked});

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (checked) {
      final p = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(size.width * 0.22, size.height * 0.55)
        ..lineTo(size.width * 0.42, size.height * 0.75)
        ..lineTo(size.width * 0.78, size.height * 0.28);
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckboxPainter oldDelegate) =>
      oldDelegate.checked != checked;
}
