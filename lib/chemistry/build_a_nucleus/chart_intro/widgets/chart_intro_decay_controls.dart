/// Chart Intro 单个 Decay 按钮 + Undo。不是 Decay Screen 五键。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../../widgets/ban_undo_button.dart';
import '../chart_intro_visuals.dart';
import '../controller/chart_intro_controller.dart';

class ChartIntroDecayControls extends StatelessWidget {
  const ChartIntroDecayControls({super.key, required this.controller});

  final ChartIntroController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.canUndoDecay)
          BanUndoButton(
            key: const ValueKey('chart_intro_undo_decay'),
            onPressed: controller.undoDecay,
            radius: 16,
          ),
        const SizedBox(width: 5),
        FilledButton(
          key: const ValueKey('chart_intro_decay_button'),
          onPressed: controller.canDecay ? controller.decay : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(BanConstants.decayButtonColorValue),
            foregroundColor: Colors.black,
            disabledBackgroundColor:
                const Color(BanConstants.decayButtonColorValue).withValues(alpha: 0.4),
            minimumSize: const Size(80, 32),
            textStyle: const TextStyle(fontSize: 14),
          ),
          child: const Text(ChartIntroVisuals.decayButtonLabel),
        ),
      ],
    );
  }
}
