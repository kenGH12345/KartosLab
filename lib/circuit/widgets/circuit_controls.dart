import 'package:flutter/material.dart';
import '../models/circuit_state.dart';
import '../../common/controls/kratos_slider.dart';

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

    // 画布内浮层样式（圆角 + 阴影）：临时 UI 悬浮在选中元件上方，
    // 不再作为底部横条。内容高 = Slider 48 + border 2 ≈ 50px，由外层 Positioned 限高。
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB8D8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // compact 滑块（无 label 行）：适配 NineGridLayout 顶部窄条高度，
      // 避免 KratosSlider 自然高（~67px）超出顶部行导致 RenderFlex overflow（既有 bug）。
      child: Row(children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline, size: 22), onPressed: () => onValueChanged(sel.value - (sel.type.valueStep)),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        const SizedBox(width: 4),
        Expanded(
          child: KratosSlider(
            label: sel.type.label,
            unit: sel.type.unit,
            min: sel.type.valueMin,
            max: sel.type.valueMax,
            step: sel.type.valueStep,
            value: sel.value,
            onChanged: onValueChanged,
            compact: true,
          ),
        ),
        const SizedBox(width: 4),
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
