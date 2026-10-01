import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../curve_fitting_strings.dart';
import '../model/curve_fitting_model.dart';
import '../model/fit_type.dart';
import 'view_options_panel.dart';

/// Best / Adjustable + coefficient VSliders — PhET `FitPanel`.
class FitPanel extends StatelessWidget {
  const FitPanel({super.key, required this.model});

  final CurveFittingModel model;

  static const _sliderRanges = [
    (CurveFittingConstants.constantMin, CurveFittingConstants.constantMax),
    (CurveFittingConstants.linearMin, CurveFittingConstants.linearMax),
    (CurveFittingConstants.quadraticMin, CurveFittingConstants.quadraticMax),
    (CurveFittingConstants.cubicMin, CurveFittingConstants.cubicMax),
  ];

  static const _labelsAsc = [
    CurveFittingStrings.dSymbol,
    CurveFittingStrings.cSymbol,
    CurveFittingStrings.bSymbol,
    CurveFittingStrings.aSymbol,
  ];

  @override
  Widget build(BuildContext context) {
    if (!model.curveVisible) return const SizedBox.shrink();

    final descendingIndices = <int>[];
    for (var i = model.order; i >= 0; i--) {
      descendingIndices.add(i);
    }

    return CfPanelChrome(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _fitRow(FitType.best, CurveFittingStrings.bestFit),
          _fitRow(FitType.adjustable, CurveFittingStrings.adjustableFit),
          const SizedBox(height: 4),
          _SymbolicEquation(order: model.order),
          if (model.fitType == FitType.adjustable) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final i in descendingIndices)
                  _VerticalCoeffSlider(
                    label: _labelsAsc[i],
                    value: model.sliderValues[i],
                    min: _sliderRanges[i].$1,
                    max: _sliderRanges[i].$2,
                    onChanged: (v) => model.setSliderValue(i, v),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _fitRow(FitType type, String label) {
    final selected = model.fitType == type;
    return InkWell(
      onTap: () => model.setFitType(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? Colors.blue : Colors.black54,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymbolicEquation extends StatelessWidget {
  const _SymbolicEquation({required this.order});

  final int order;

  @override
  Widget build(BuildContext context) {
    final parts = <InlineSpan>[
      const TextSpan(
        text: 'y = ',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
    ];
    final terms = <(String, String)>[];
    if (order >= 3) terms.add(('a', 'x³'));
    if (order >= 2) terms.add(('b', 'x²'));
    if (order >= 1) terms.add(('c', 'x'));
    terms.add(('d', ''));

    for (var i = 0; i < terms.length; i++) {
      final (coeff, power) = terms[i];
      if (i > 0) {
        parts.add(const TextSpan(text: ' + ', style: TextStyle(fontSize: 14)));
      }
      parts.add(TextSpan(
        text: coeff,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: CurveFittingColors.blue,
        ),
      ));
      if (power.isNotEmpty) {
        parts.add(TextSpan(
          text: ' $power',
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ));
      }
    }

    return Text.rich(TextSpan(children: parts));
  }
}

class _VerticalCoeffSlider extends StatelessWidget {
  const _VerticalCoeffSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 140,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CurveFittingColors.blue,
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
