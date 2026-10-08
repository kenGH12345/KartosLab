/// Identical Coins selector -?10 / 100 / 10000.
library;

import 'package:flutter/material.dart';

import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../coins/model/coin_set.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class CoinCountSelector extends StatelessWidget {
  const CoinCountSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.visible = true,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          QmStrings.identicalCoins,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final n in multiCoinExperimentQuantities)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onChanged(n),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RadioDot(selected: value == n),
                  const SizedBox(width: 8),
                  Text('$n', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: QuantumMeasurementColors.selectorButtonSelectedStroke,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: QuantumMeasurementColors.selectorButtonSelectedStroke,
              ),
            )
          : null,
    );
  }
}
