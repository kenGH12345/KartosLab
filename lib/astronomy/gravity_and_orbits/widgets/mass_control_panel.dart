/// Horizontal mass sliders 0.5–2.0 × tickMass for mass-settable bodies.
library;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../model/gao_body.dart';
import 'bodies_layer.dart';

class MassControlPanel extends StatelessWidget {
  const MassControlPanel({super.key, required this.controller});

  final GaoController controller;

  @override
  Widget build(BuildContext context) {
    final bodies = [
      for (final b in controller.model.scene.bodies)
        if (b.massSettable) b,
    ];
    if (bodies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final body in bodies) ...[
          _MassSlider(controller: controller, body: body),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MassSlider extends StatelessWidget {
  const _MassSlider({required this.controller, required this.body});

  final GaoController controller;
  final GaoBody body;

  @override
  Widget build(BuildContext context) {
    final ratio = (body.mass / body.tickMass).clamp(0.5, 2.0);
    final title = massControlTitle(body.type);
    const labelStyle = TextStyle(color: GaoColors.foreground, fontSize: 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: GaoColors.foreground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: const Color(0xFF555555),
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
            trackHeight: 3,
          ),
          child: Slider(
            value: ratio,
            min: 0.5,
            max: 2.0,
            divisions: 30,
            onChanged: (v) => controller.setBodyMassRatio(body, v),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.5', style: labelStyle),
              Text('1.0', style: labelStyle),
              Text('1.5', style: labelStyle),
              Text('2.0', style: labelStyle),
            ],
          ),
        ),
      ],
    );
  }
}
