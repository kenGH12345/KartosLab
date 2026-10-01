/// 质子 / 中子读数。对标 `NucleonNumberPanel`，无翻页动画。
library;

import 'package:flutter/material.dart';

import '../chart_intro_visuals.dart';
import '../model/chart_intro_state.dart';

class ChartIntroCountPanel extends StatelessWidget {
  const ChartIntroCountPanel({super.key, required this.state});

  final ChartIntroState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ChartIntroVisuals.panelBackground,
        border: Border.all(color: ChartIntroVisuals.panelStroke),
        borderRadius: BorderRadius.circular(ChartIntroVisuals.panelCornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ChartIntroVisuals.panelXMargin,
          vertical: ChartIntroVisuals.panelYMargin,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(
              key: 'chart_intro_proton_count',
              color: ChartIntroVisuals.proton,
              label: '质子',
              value: state.protonCount,
            ),
            const SizedBox(
              height: ChartIntroVisuals.nucleonNumberMinVerticalSpacing -
                  ChartIntroVisuals.nucleonNumberParticleRadius * 2,
            ),
            _row(
              key: 'chart_intro_neutron_count',
              color: ChartIntroVisuals.neutron,
              label: '中子',
              value: state.neutronCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required String key,
    required Color color,
    required String label,
    required int value,
  }) {
    final d = ChartIntroVisuals.nucleonNumberParticleRadius * 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.4),
              radius: 1.6,
              colors: [Colors.white, color],
            ),
            border: Border.all(color: color, width: 0.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: $value',
          key: ValueKey(key),
          style: const TextStyle(
            fontSize: ChartIntroVisuals.buttonsAndLegendFontSize,
          ),
        ),
      ],
    );
  }
}
