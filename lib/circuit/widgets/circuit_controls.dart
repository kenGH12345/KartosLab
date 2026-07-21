import 'package:flutter/material.dart';
import '../models/circuit_state.dart';

class CircuitControls extends StatelessWidget {
  final CircuitState state;
  final SolvedCircuit solved;
  final Function(double value) onValueChanged;

  const CircuitControls({super.key, required this.state, required this.solved, required this.onValueChanged});

  @override
  Widget build(BuildContext context) {
    final sel = state.selected;
    if (sel == null) return const SizedBox.shrink();
    final isAdjustable = sel.type == ComponentType.battery || sel.type == ComponentType.resistor;
    if (!isAdjustable) {
      // Show read-only info for bulb/switch/wire
      if (sel.type == ComponentType.lightBulb) {
        final b = solved.brightnessFor(sel.id);
        return _bar('灯泡: 亮度 ${(b * 100).toInt()}%');
      }
      if (sel.type == ComponentType.switch_) {
        return _bar('开关: ${sel.isClosed ? "闭合" : "断开"}');
      }
      return _bar('${sel.type.label} (不可调)');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFE2F5FB),
        border: Border(top: BorderSide(color: Color(0xFFB8D8E8))),
      ),
      child: Row(children: [
        Text('${sel.type.label}:', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B2B3D))),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.remove_circle_outline, size: 22), onPressed: () => onValueChanged(sel.value - (sel.type.valueStep)),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        Expanded(
          child: Slider(
            value: sel.value, min: sel.type.valueMin, max: sel.type.valueMax,
            divisions: ((sel.type.valueMax - sel.type.valueMin) / sel.type.valueStep).round(),
            activeColor: const Color(0xFF1177AA),
            onChanged: onValueChanged,
          ),
        ),
        Text('${sel.value.toInt()} ${sel.type.unit}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B2B3D))),
        IconButton(icon: const Icon(Icons.add_circle_outline, size: 22), onPressed: () => onValueChanged(sel.value + sel.type.valueStep),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
      ]),
    );
  }

  Widget _bar(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: const BoxDecoration(color: Color(0xFFE2F5FB), border: Border(top: BorderSide(color: Color(0xFFB8D8E8)))),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B2B3D))),
  );
}
