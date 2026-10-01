/// Prep-area: Bloch (scale ~0.75) → equations → +Z/+X/−Z radios.
/// Mirrors `SpinStatePreparationArea.ts` child order.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../bloch_sphere/components/bloch_sphere_view.dart';
import '../model/spin_model.dart';

class SpinPrepControls extends StatelessWidget {
  const SpinPrepControls({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final SpinModel model;
  final VoidCallback onChanged;

  ({double polar, double azimuthal}) get _angles {
    if (model.isCustom) {
      final polar = math.pi * (1 - model.alphaSquared);
      return (polar: polar, azimuthal: 0.0);
    }
    switch (model.spinState) {
      case SpinDirection.zPlus:
        return (polar: 0.0, azimuthal: 0.0);
      case SpinDirection.zMinus:
        return (polar: math.pi, azimuthal: 0.0);
      case SpinDirection.xPlus:
        return (polar: math.pi / 2, azimuthal: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _angles;
    final alpha = math.sqrt(model.alphaSquared);
    final beta = math.sqrt(model.betaSquared);
    final (double aCoeff, double bCoeff) = model.isCustom
        ? (alpha, beta)
        : switch (model.spinState) {
            SpinDirection.zPlus => (1.0, 0.0),
            SpinDirection.zMinus => (0.0, 1.0),
            SpinDirection.xPlus => (math.sqrt(0.5), math.sqrt(0.5)),
          };

    // Fit prep column (~270px); LayoutSpec prep scale 0.9 is too wide for Flutter VBox.
    const blochScale = 0.72;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bloch first (matches PhET prep VBox visual weight)
        BlochSphereView(
          center: Offset.zero,
          polar: a.polar,
          azimuthal: a.azimuthal,
          scale: blochScale,
          drawKets: true,
          drawAngleIndicators: false,
          drawAxesLabels: true,
        ),
        const SizedBox(height: 8),
        const Text(
          'Spin State to Prepare',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          'α|↑⟩z + β|↓⟩z',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
        ),
        Text(
          '${aCoeff.toStringAsFixed(3)}|↑⟩z + ${bCoeff.toStringAsFixed(3)}|↓⟩z',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (!model.isCustom)
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final d in SpinDirection.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        model.spinState = d;
                        switch (d) {
                          case SpinDirection.zPlus:
                            model.setAlphaSquared(1.0);
                          case SpinDirection.zMinus:
                            model.setAlphaSquared(0.0);
                          case SpinDirection.xPlus:
                            model.setAlphaSquared(0.5);
                        }
                        onChanged();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RadioDot(selected: model.spinState == d),
                          const SizedBox(width: 8),
                          Text(
                            _dirLabel(d),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          )
        else ...[
          Text('α² = ${model.alphaSquared.toStringAsFixed(2)}'),
          Slider(
            value: model.alphaSquared,
            onChanged: (v) {
              model.setAlphaSquared(v);
              onChanged();
            },
          ),
          Text('β² = ${model.betaSquared.toStringAsFixed(2)}'),
        ],
      ],
    );
  }

  String _dirLabel(SpinDirection d) {
    switch (d) {
      case SpinDirection.zPlus:
        return '+Z';
      case SpinDirection.xPlus:
        return '+X';
      case SpinDirection.zMinus:
        return '−Z';
    }
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0094BD), width: 2),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0094BD),
              ),
            )
          : null,
    );
  }
}
