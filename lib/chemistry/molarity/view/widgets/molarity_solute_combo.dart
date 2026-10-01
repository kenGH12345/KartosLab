import 'package:flutter/material.dart';

import '../../model/molarity_state.dart';
import '../../model/solute.dart';

/// Source `SoluteControl` — label + ComboBox with color swatch (not Material icons).
class MolaritySoluteCombo extends StatelessWidget {
  const MolaritySoluteCombo({
    super.key,
    required this.state,
    required this.onSelected,
  });

  final MolarityState state;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final current = state.solution.solute;
    return Semantics(
      label: '溶质',
      value: current.name,
      button: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '溶质:',
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black54),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Solute>(
                value: state.solutes.contains(current)
                    ? current
                    : state.solutes.first,
                isDense: true,
                borderRadius: BorderRadius.circular(8),
                items: [
                  for (final s in state.solutes)
                    DropdownMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: s.maxColor,
                              border: Border.all(
                                color: Color.lerp(
                                      s.maxColor, Colors.black, 0.35)!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(s.name, style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                ],
                onChanged: (s) {
                  if (s == null) return;
                  onSelected(state.solutes.indexOf(s));
                },
                selectedItemBuilder: (context) => [
                  for (final s in state.solutes)
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: s.maxColor,
                            border: Border.all(
                              color: Color.lerp(
                                    s.maxColor, Colors.black, 0.35)!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(s.name, style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
