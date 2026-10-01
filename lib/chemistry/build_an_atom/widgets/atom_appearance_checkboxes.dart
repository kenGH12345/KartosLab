import 'package:flutter/material.dart';

import '../view/atom_view_state.dart';

/// PhET `AtomAppearanceCheckboxGroup`.
class AtomAppearanceCheckboxes extends StatelessWidget {
  const AtomAppearanceCheckboxes({super.key, required this.viewState});

  final AtomViewState viewState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewState,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _box(
              'Element Name',
              viewState.elementNameVisible,
              viewState.setElementNameVisible,
            ),
            _box(
              'Neutral Atom or Ion',
              viewState.neutralAtomOrIonVisible,
              viewState.setNeutralAtomOrIonVisible,
            ),
            _box(
              'Nuclear Stability',
              viewState.nuclearStabilityVisible,
              viewState.setNuclearStabilityVisible,
            ),
          ],
        );
      },
    );
  }

  Widget _box(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF1565C0) : Colors.white,
                border: Border.all(color: Colors.black87, width: 1.2),
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: value
                  ? const Text(
                      '✓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
