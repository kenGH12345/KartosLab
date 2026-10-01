import 'package:flutter/material.dart';

/// PhET `ABSwitch` / toggle — size 40×20 from `ABSConstants.AB_SWITCH_OPTIONS`.
class AbsAbSwitch extends StatelessWidget {
  const AbsAbSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.leftLabel,
    required this.rightLabel,
  });

  /// `true` selects left (A), `false` selects right (B).
  final bool value;
  final ValueChanged<bool> onChanged;
  final String leftLabel;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            leftLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 40,
            height: 20,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFF3376C4)
                  : const Color(0xFF888888),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black54, width: 0.5),
            ),
            alignment: value ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            rightLabel,
            textAlign: TextAlign.left,
            style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
