import 'package:flutter/material.dart';

import '../model/electron_model.dart';

/// PhET `ElectronModelControl` — Shells / Cloud radio group.
class ElectronModelControl extends StatelessWidget {
  const ElectronModelControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ElectronModelType value;
  final ValueChanged<ElectronModelType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Model:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        _radio('Shells', ElectronModelType.shells),
        _radio('Cloud', ElectronModelType.cloud),
      ],
    );
  }

  Widget _radio(String label, ElectronModelType type) {
    final selected = value == type;
    return InkWell(
      onTap: () => onChanged(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 1.5),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1565C0),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
