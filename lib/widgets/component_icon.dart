import 'package:flutter/material.dart';
import '../models/circuit_state.dart';

class ComponentIconWidget extends StatelessWidget {
  final ComponentType type;
  final double iconSize;
  final double fontSize;
  final bool showLabel;
  final double? fixedWidth;
  final double? fixedHeight;
  final bool isPowered;
  final bool isClosed;

  const ComponentIconWidget({
    super.key,
    required this.type,
    this.iconSize = 22,
    this.fontSize = 10,
    this.showLabel = true,
    this.fixedWidth,
    this.fixedHeight,
    this.isPowered = false,
    this.isClosed = true,
  });

  static const _styleMap = <ComponentType, _StyleData>{
    ComponentType.battery:   _StyleData(icon: Icons.battery_std, label:'电池', color:Color(0xFFF59E0B)),
    ComponentType.resistor:  _StyleData(icon:Icons.memory,      label:'电阻', color:Color(0xFF94A3B8)),
    ComponentType.lightBulb: _StyleData(icon:Icons.lightbulb_outline,label:'灯泡',color:Color(0xFFFFD84D)),
    ComponentType.switch_:   _StyleData(icon:Icons.toggle_off_outlined,label:'开关',color:Color(0xFFCBD5E1)),
    ComponentType.fuse:      _StyleData(icon:Icons.flash_on,     label:'保险丝',color:Color(0xFFEF4444)),
    ComponentType.ground:    _StyleData(icon:Icons.horizontal_rule,label:'接地', color:Color(0xFF64748B)),
    ComponentType.wire:      _StyleData(icon:Icons.linear_scale, label:'导线', color:Color(0xFF3B82F6)),
  };

  _StyleData get _s => _styleMap[type] ?? _styleMap[ComponentType.battery]!;

  IconData get _effectiveIcon {
    if (type == ComponentType.switch_) return isClosed ? Icons.toggle_on : Icons.toggle_off_outlined;
    if (type == ComponentType.lightBulb && isPowered) return Icons.lightbulb;
    return _s.icon;
  }

  Color get _effectiveColor {
    if (type == ComponentType.switch_ && isClosed) return const Color(0xFF22C55E);
    if (type == ComponentType.lightBulb && isPowered) return const Color(0xFFFFD700);
    if (isPowered && type != ComponentType.switch_) return _s.color;
    return _s.color;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _effectiveIcon;
    final color = _effectiveColor;

    final content = <Widget>[
      Container(
        constraints: BoxConstraints(minWidth: fixedWidth ?? 0, minHeight: fixedHeight ?? 0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isPowered ? 0.3 : 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: isPowered ? 0.8 : 0.4), width: isPowered ? 2.0 : 1.5),
        ),
        padding: EdgeInsets.symmetric(horizontal: fixedWidth != null ? 8 : 6, vertical: fixedHeight != null ? 6 : 4),
        child: Icon(icon, color: color, size: iconSize),
      ),
    ];

    if (showLabel) {
      content.add(const SizedBox(height: 3));
      content.add(Text(_s.label, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: fontSize, fontWeight: FontWeight.w600)));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: content);
  }

  static Widget dragFeedback(ComponentType type) {
    final s = _styleMap[type] ?? _styleMap[ComponentType.battery]!;
    return Material(color: Colors.transparent, elevation: 4, borderRadius: BorderRadius.circular(10),
      child: Container(width: 64, padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: s.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: s.color.withValues(alpha: 0.8), width: 2)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(s.icon, color: s.color, size: 30), const SizedBox(height: 2),
            Text(s.label, style: TextStyle(color: s.color.withValues(alpha: 1.0), fontSize: 11, fontWeight: FontWeight.w700)),
          ])));
  }
}

class _StyleData {
  final IconData icon; final String label; final Color color;
  const _StyleData({required this.icon, required this.label, required this.color});
}
