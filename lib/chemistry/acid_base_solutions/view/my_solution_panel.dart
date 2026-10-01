import 'package:flutter/material.dart';

import '../model/abs_colors.dart';
import '../model/abs_constants.dart';
import '../model/abs_math.dart';
import '../model/my_solution_model.dart';
import 'abs_ab_switch.dart';
import 'abs_log_slider.dart';

/// My Solution panel — PhET `MySolutionPanel.ts`.
class MySolutionPanel extends StatelessWidget {
  const MySolutionPanel({
    super.key,
    required this.model,
    required this.onAcidChanged,
    required this.onWeakChanged,
    required this.onConcentrationChanged,
    required this.onConcentrationNudge,
    required this.onStrengthChanged,
  });

  final MySolutionModel model;
  final ValueChanged<bool> onAcidChanged;
  final ValueChanged<bool> onWeakChanged;
  final ValueChanged<double> onConcentrationChanged;
  final ValueChanged<int> onConcentrationNudge;
  final ValueChanged<double> onStrengthChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
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
          const SizedBox(height: 6),
          Center(
            child: AbsAbSwitch(
              value: model.isAcid,
              onChanged: onAcidChanged,
              leftLabel: 'Acid',
              rightLabel: 'Base',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: Color(0xFF8890C0)),
          ),
          const Text(
            'Initial Concentration (mol/L):',
            style: TextStyle(fontFamily: 'Arial', fontSize: 12),
          ),
          const SizedBox(height: 6),
          Center(child: _ConcentrationSpinner(
            value: model.concentration,
            onNudge: onConcentrationNudge,
          )),
          const SizedBox(height: 4),
          Center(
            child: AbsLogSlider(
              value: model.concentration,
              range: AbsConstants.concentrationRange,
              onChanged: onConcentrationChanged,
              majorTicks: const [0.001, 0.01, 0.1, 1],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: Color(0xFF8890C0)),
          ),
          const Text(
            'Strength:',
            style: TextStyle(fontFamily: 'Arial', fontSize: 12),
          ),
          const SizedBox(height: 6),
          Center(
            child: AbsAbSwitch(
              value: model.isWeak,
              onChanged: onWeakChanged,
              leftLabel: 'weak',
              rightLabel: 'strong',
            ),
          ),
          // Keep space when strong (source sliderWrapper excludeInvisibleChildrenFromBounds: false)
          SizedBox(
            height: model.isWeak ? null : 56,
            child: model.isWeak
                ? Center(
                    child: AbsLogSlider(
                      value: model.strength,
                      range: AbsConstants.weakStrengthRange,
                      onChanged: onStrengthChanged,
                      majorTicks: [
                        AbsConstants.weakStrengthRange.min,
                        AbsConstants.weakStrengthRange.max,
                      ],
                      tickBuilder: (v) => Text(
                        v == AbsConstants.weakStrengthRange.min
                            ? 'weaker'
                            : 'stronger',
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ConcentrationSpinner extends StatelessWidget {
  const _ConcentrationSpinner({
    required this.value,
    required this.onNudge,
  });

  final double value;
  final ValueChanged<int> onNudge;

  @override
  Widget build(BuildContext context) {
    final display = AbsMath.toFixedNumber(
      value,
      AbsConstants.concentrationDecimals,
    ).toStringAsFixed(AbsConstants.concentrationDecimals);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowButton(left: true, onTap: () => onNudge(-1)),
        const SizedBox(width: 8),
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black45),
          ),
          alignment: Alignment.center,
          child: Text(
            display,
            style: const TextStyle(fontFamily: 'Arial', fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        _ArrowButton(left: false, onTap: () => onNudge(1)),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.left, required this.onTap});

  final bool left;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black38),
        ),
        child: Text(
          left ? '◀' : '▶',
          style: const TextStyle(fontSize: 12, height: 1),
        ),
      ),
    );
  }
}
