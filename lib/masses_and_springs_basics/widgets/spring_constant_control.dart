import 'package:flutter/material.dart';
import '../masb_strings.dart';

import '../controller/masb_controller.dart';
import '../masb_constants.dart';

/// PhET `SpringControlPanel` for spring constant (minimal M3 UI).
class SpringConstantControl extends StatelessWidget {
  const SpringConstantControl({super.key, required this.controller});

  final MasbController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final k = controller.model.spring.springConstant;
        return Material(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '劲度系数',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                Text(
                  '${k.toStringAsFixed(0)} N/m',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: const Color(0xFF00C4DF),
                    inactiveTrackColor: Colors.grey.shade400,
                    thumbColor: const Color(0xFF00C4DF),
                  ),
                  child: Slider(
                    value: k.clamp(
                      MasbConstants.springConstantMin,
                      MasbConstants.springConstantMax,
                    ),
                    min: MasbConstants.springConstantMin,
                    max: MasbConstants.springConstantMax,
                    divisions: 9, // 3..12 step 1 (PhET tick intervals)
                    label: k.round().toString(),
                    onChanged: controller.setSpringConstant,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(MasbStrings.small,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                    Text(MasbStrings.large,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
