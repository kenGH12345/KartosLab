import 'package:flutter/material.dart';

import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/data.dart';

/// Interactive periodic table for Game element challenges (Z selectable).
class GameInteractivePeriodicTable extends StatelessWidget {
  const GameInteractivePeriodicTable({
    super.key,
    required this.selectedZ,
    required this.onSelected,
    this.enabled = true,
    this.maxZ = 18,
  });

  final int selectedZ;
  final ValueChanged<int> onSelected;
  final bool enabled;
  final int maxZ;

  static const _cell = 28.0;

  // Simplified layout rows for Z=1..18 (H-He, Li-Ne, Na-Ar style columns).
  static const _positions = <(int z, int col, int row)>[
    (1, 0, 0),
    (2, 17, 0),
    (3, 0, 1),
    (4, 1, 1),
    (5, 12, 1),
    (6, 13, 1),
    (7, 14, 1),
    (8, 15, 1),
    (9, 16, 1),
    (10, 17, 1),
    (11, 0, 2),
    (12, 1, 2),
    (13, 12, 2),
    (14, 13, 2),
    (15, 14, 2),
    (16, 15, 2),
    (17, 16, 2),
    (18, 17, 2),
  ];

  @override
  Widget build(BuildContext context) {
    final elements = ElementRepository.instance;
    final cells = <Widget>[];
    for (final p in _positions) {
      if (p.$1 > maxZ) continue;
      final el = elements.getByAtomicNumber(p.$1);
      if (el == null) continue;
      final selected = p.$1 == selectedZ;
      cells.add(Positioned(
        left: p.$2 * _cell,
        top: p.$3 * _cell,
        child: GestureDetector(
          onTap: enabled ? () => onSelected(p.$1) : null,
          child: Container(
            width: _cell - 2,
            height: _cell - 2,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFFFFF00)
                  : const Color(0xFFF0F0F0),
              border: Border.all(color: Colors.black87, width: 0.8),
              gradient: selected
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFF0F0F0)],
                    ),
            ),
            child: Text(
              el.symbol,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ));
    }

    // Intrinsic PT is ~504×84; Game answer pane is ~half of 768 — scale to fit
    // so He / C / Ne remain tappable without horizontal overflow (Phase 6 UX).
    const intrinsicW = 18 * _cell;
    const intrinsicH = 3 * _cell;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : intrinsicW;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: intrinsicW,
              height: intrinsicH,
              child: Stack(children: cells),
            ),
          ),
        );
      },
    );
  }
}
