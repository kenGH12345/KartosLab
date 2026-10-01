// Copyright 2024-2026, University of Colorado Boulder
/// Slider + arrow buttons for a 0–1 probability (ProbabilityValueControl.ts).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _sliderStep = 0.05;
/// Arrow buttons step by one slider division (0.05). A smaller delta would be
/// rounded away by [constrainValue] and appear "broken".
const _arrowDelta = _sliderStep;

class ProbabilityValueControl extends StatelessWidget {
  const ProbabilityValueControl({
    super.key,
    required this.title,
    required this.valueListenable,
    required this.onChanged,
  });

  final Widget title;
  final ValueListenable<double> valueListenable;
  final ValueChanged<double> onChanged;

  static double constrainValue(double value) {
    final clamped = value.clamp(0.0, 1.0);
    return (clamped / _sliderStep).round() * _sliderStep;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: valueListenable,
      builder: (context, value, _) {
        final constrained = constrainValue(value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ArrowButton(
                  label: '◀',
                  onPressed: constrained > 0
                      ? () => onChanged(
                            constrainValue(constrained - _arrowDelta),
                          )
                      : null,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      tickMarkShape: const RoundSliderTickMarkShape(),
                      activeTickMarkColor: Colors.black54,
                      inactiveTickMarkColor: Colors.black26,
                    ),
                    child: Slider(
                      value: constrained,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      label: constrained.toStringAsFixed(2),
                      onChanged: (v) => onChanged(constrainValue(v)),
                    ),
                  ),
                ),
                _ArrowButton(
                  label: '▶',
                  onPressed: constrained < 1
                      ? () => onChanged(
                            constrainValue(constrained + _arrowDelta),
                          )
                      : null,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('0', style: TextStyle(fontSize: 14)),
                  Text('1', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8E8E8),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: onPressed != null ? Colors.black : Colors.black38,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
