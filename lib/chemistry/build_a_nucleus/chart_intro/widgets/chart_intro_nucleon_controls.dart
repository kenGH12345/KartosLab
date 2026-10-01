/// Chart Intro 质子 / 中子加减箭头。
///
/// 视觉对齐 Decay footer 的静态箭头列，但不做生成器拖拽、不做双箭头。
/// [已确认] NucleonCreatorsNode：上/下箭头；enable 来自 State。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../controller/chart_intro_controller.dart';

class ChartIntroNucleonControls extends StatelessWidget {
  const ChartIntroNucleonControls({super.key, required this.controller});

  final ChartIntroController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.state;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowColumn(
          upKey: const ValueKey('chart_intro_add_proton'),
          downKey: const ValueKey('chart_intro_remove_proton'),
          color: const Color(BanConstants.protonColorValue),
          onUp: s.canAddProton ? controller.addProton : null,
          onDown: s.canRemoveProton ? controller.removeProton : null,
        ),
        const SizedBox(width: 16),
        _ArrowColumn(
          upKey: const ValueKey('chart_intro_add_neutron'),
          downKey: const ValueKey('chart_intro_remove_neutron'),
          color: const Color(BanConstants.neutronColorValue),
          onUp: s.canAddNeutron ? controller.addNeutron : null,
          onDown: s.canRemoveNeutron ? controller.removeNeutron : null,
        ),
      ],
    );
  }
}

class _ArrowColumn extends StatelessWidget {
  const _ArrowColumn({
    required this.upKey,
    required this.downKey,
    required this.color,
    required this.onUp,
    required this.onDown,
  });

  final Key upKey;
  final Key downKey;
  final Color color;
  final VoidCallback? onUp;
  final VoidCallback? onDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: upKey,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
          icon: Icon(Icons.arrow_drop_up, color: color),
          onPressed: onUp,
        ),
        const SizedBox(height: 7),
        IconButton(
          key: downKey,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
          icon: Icon(Icons.arrow_drop_down, color: color),
          onPressed: onDown,
        ),
      ],
    );
  }
}
