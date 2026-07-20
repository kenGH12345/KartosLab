import 'package:flutter/material.dart';

/// 施力滑块：-500 ~ 500 N，双向
class AppliedForceSlider extends StatelessWidget {
  const AppliedForceSlider({super.key, required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    _arrowButton(Icons.remove, -50),
    const SizedBox(width: 4),
    SizedBox(width: 200, child: SliderTheme(
      data: SliderThemeData(trackHeight: 8, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        activeTrackColor: value < 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
        inactiveTrackColor: const Color(0xFFE2E8F0), thumbColor: const Color(0xFF1E293B)),
      child: Slider(value: value, min: -500, max: 500, divisions: 20, onChanged: onChanged),
    )),
    const SizedBox(width: 4),
    _arrowButton(Icons.add, 50),
    const SizedBox(width: 12),
    Text('${value.abs().toStringAsFixed(0)} N', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
  ]);

  Widget _arrowButton(IconData icon, double delta) => InkWell(
    onTap: () => onChanged((value + delta).clamp(-500, 500)),
    child: Container(width: 32, height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF1F5F9), border: Border.all(color: const Color(0xFFCBD5E1))),
      child: Icon(icon, size: 18, color: const Color(0xFF475569)),
    ),
  );
}
