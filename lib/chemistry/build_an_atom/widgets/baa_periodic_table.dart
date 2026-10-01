import 'package:flutter/material.dart';

import 'baa_scaled_box.dart';

/// PhET `PeriodicTableAndSymbol` — full shred `PeriodicTableNode` + symbol chip.
///
/// Atom/Symbol screens use `interactiveMax: 0` (display-only highlight).
class BaaPeriodicTable extends StatelessWidget {
  const BaaPeriodicTable({
    super.key,
    required this.selectedZ,
    this.scale = 0.55,
    this.cellDimension = 25,
  });

  final int selectedZ;

  /// PhET `PeriodicTableAndSymbol` scale on Atom/Symbol screens.
  final double scale;

  /// shred `PeriodicTableCell` nominal length.
  final double cellDimension;

  /// shred `POPULATED_CELLS` (main table; lanthanides/actinides skipped).
  static const populatedCells = <List<int>>[
    [0, 17],
    [0, 1, 12, 13, 14, 15, 16, 17],
    [0, 1, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
  ];

  /// IUPAC symbols Z=1..118 (index 0 unused).
  static const symbols = <String>[
    '',
    'H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne',
    'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar', 'K', 'Ca',
    'Sc', 'Ti', 'V', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn',
    'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y', 'Zr',
    'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn',
    'Sb', 'Te', 'I', 'Xe', 'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd',
    'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb',
    'Lu', 'Hf', 'Ta', 'W', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg',
    'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th',
    'Pa', 'U', 'Np', 'Pu', 'Am', 'Cm', 'Bk', 'Cf', 'Es', 'Fm',
    'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds',
    'Rg', 'Cn', 'Nh', 'Fl', 'Mc', 'Lv', 'Ts', 'Og',
  ];

  static String symbolFor(int z) {
    if (z <= 0 || z >= symbols.length) return '—';
    return symbols[z];
  }

  /// Build (Z, col, row) for main-table cells (same skip as shred).
  static List<(int z, int col, int row)> buildCells() {
    final out = <(int, int, int)>[];
    var z = 1;
    for (var row = 0; row < populatedCells.length; row++) {
      for (final col in populatedCells[row]) {
        out.add((z, col, row));
        z++;
        if (z == 58) z = 72;
        if (z == 90) z = 104;
      }
    }
    return out;
  }

  static final _cells = buildCells();

  @override
  Widget build(BuildContext context) {
    // PhET PeriodicTableAndSymbol layout:
    // table width = 18 * cell; symbol = 0.2 * tableWidth; table overlaps under symbol.
    final tableW = 18 * cellDimension;
    final tableH = 7 * cellDimension;
    final symbolW = tableW * 0.2;
    final symbolH = symbolW;
    // periodicTable.top = symbol.bottom - (tableH / 7 * 2.5)
    final tableTop = symbolH - (tableH / 7 * 2.5);
    final intrinsicH = tableTop + tableH;
    final symbolCenterX = (7.5 / 18) * tableW;

    final symbolText = symbolFor(selectedZ);

    final intrinsic = SizedBox(
      width: tableW,
      height: intrinsicH,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 0,
            top: tableTop,
            width: tableW,
            height: tableH,
            child: Stack(
              children: [
                for (final c in _cells)
                  Positioned(
                    left: c.$2 * cellDimension,
                    top: c.$3 * cellDimension,
                    width: cellDimension,
                    height: cellDimension,
                    child: _Cell(
                      z: c.$1,
                      selected: c.$1 == selectedZ,
                      cell: cellDimension,
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: symbolCenterX - symbolW / 2,
            top: 0,
            width: symbolW,
            height: symbolH,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 2),
              ),
              child: Center(
                child: Text(
                  symbolText,
                  style: TextStyle(
                    fontSize: cellDimension * 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return BaaScaledBox(
      scale: scale,
      intrinsicWidth: tableW,
      intrinsicHeight: intrinsicH,
      child: intrinsic,
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.z,
    required this.selected,
    required this.cell,
  });

  final int z;
  final bool selected;
  final double cell;

  @override
  Widget build(BuildContext context) {
    // interactiveMax: 0 → all cells use disabled (white) unless selected.
    final bg = selected
        ? const Color(0xFFFA8072)
        : const Color(0xFFFFFFFF);
    final symbol = BaaPeriodicTable.symbolFor(z);
    final fontSize = (cell * 0.55).clamp(7.0, 14.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.black54, width: 0.5),
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1,
          ),
        ),
      ),
    );
  }
}
