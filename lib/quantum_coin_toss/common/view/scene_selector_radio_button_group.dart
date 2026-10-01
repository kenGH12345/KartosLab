// Copyright 2024-2026, University of Colorado Boulder
/// Two-option scene selector (Classical Coin / Quantum 'Coin').
///
/// Corresponds to `js/common/view/SceneSelectorRadioButtonGroup.ts`.
library;

import 'package:flutter/material.dart';

import '../quantum_measurement_colors.dart';
import '../quantum_measurement_constants.dart';

const _deselectedOpacity = 0.3;

class SceneSelectorRadioButtonGroup<T> extends StatelessWidget {
  const SceneSelectorRadioButtonGroup({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<(T, String)> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    assert(items.length == 2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          _SceneButton(
            label: items[i].$2,
            selected: items[i].$1 == selectedValue,
            onTap: () => onChanged(items[i].$1),
          ),
        ],
      ],
    );
  }
}

class _SceneButton extends StatelessWidget {
  const _SceneButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected
        ? QuantumMeasurementColors.selectorButtonSelected
        : QuantumMeasurementColors.selectorButtonDeselected;
    final stroke = selected
        ? QuantumMeasurementColors.selectorButtonSelectedStroke
        : QuantumMeasurementColors.selectorButtonDeselectedStroke;
    final opacity = selected ? 1.0 : _deselectedOpacity;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: stroke, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: QuantumMeasurementConstants.sceneSelectorFontSize,
                  fontWeight: FontWeight.bold,
                  color: QuantumMeasurementColors.classicalSceneText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
