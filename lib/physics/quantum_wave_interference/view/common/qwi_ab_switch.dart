import 'package:flutter/material.dart';

/// PhET `ABSwitch` — Screen / Graph toggle (size 37×17 from DetectorScreenControls).
class QwiAbSwitch extends StatelessWidget {
  const QwiAbSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.leftLabel,
    required this.rightLabel,
  });

  /// `true` selects left (A).
  final bool value;
  final ValueChanged<bool> onChanged;
  final String leftLabel;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            leftLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            key: const Key('qwi_ab_switch'),
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 37,
              height: 17,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF3376C4) : const Color(0xFF888888),
                borderRadius: BorderRadius.circular(8.5),
                border: Border.all(color: Colors.black54, width: 0.5),
              ),
              alignment: value ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            rightLabel,
            textAlign: TextAlign.left,
            style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
