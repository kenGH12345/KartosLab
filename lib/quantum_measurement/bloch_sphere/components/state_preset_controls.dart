/// Preparation presets + θ/φ sliders (BlochSpherePreparationArea).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

const _controlFont = TextStyle(fontSize: 14, color: Colors.black);
const _sliderStep = math.pi / 12;

class StatePresetControls extends StatelessWidget {
  const StatePresetControls({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final BlochSphereModel model;
  final VoidCallback onChanged;

  static const _presets = <(BlochStateDirection, String)>[
    (BlochStateDirection.xPlus, '+X'),
    (BlochStateDirection.xMinus, '−X'),
    (BlochStateDirection.yPlus, '+Y'),
    (BlochStateDirection.yMinus, '−Y'),
    (BlochStateDirection.zPlus, '+Z'),
    (BlochStateDirection.zMinus, '−Z'),
    (BlochStateDirection.custom, QmStrings.custom),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF777777)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<BlochStateDirection>(
            isExpanded: true,
            value: model.spinState,
            style: _controlFont,
            items: [
              for (final (d, label) in _presets)
                DropdownMenuItem(value: d, child: Text(label, style: _controlFont)),
            ],
            onChanged: (d) {
              if (d == null) return;
              if (d == BlochStateDirection.custom) {
                model.spinState = BlochStateDirection.custom;
              } else {
                model.setSpinState(d);
              }
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          Text(QmStrings.polarAngle, style: _controlFont),
          Slider(
            value: model.preparation.polarAngle.clamp(0, math.pi),
            min: 0,
            max: math.pi,
            divisions: 12,
            label: model.preparation.polarAngle.toStringAsFixed(2),
            onChanged: (v) {
              final snapped = (v / _sliderStep).round() * _sliderStep;
              model.setAngles(snapped, model.preparation.azimuthalAngle);
              onChanged();
            },
          ),
          Text(QmStrings.azimuthalAngle, style: _controlFont),
          Slider(
            value: model.preparation.azimuthalAngle.clamp(0, 2 * math.pi),
            min: 0,
            max: 2 * math.pi,
            divisions: 24,
            label: model.preparation.azimuthalAngle.toStringAsFixed(2),
            onChanged: (v) {
              final snapped = (v / _sliderStep).round() * _sliderStep;
              model.setAngles(model.preparation.polarAngle, snapped);
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
