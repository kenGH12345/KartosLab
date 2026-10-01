/// ExpandedPeriodicTableNode (shred) — interactive cells for Z≤[interactiveMax].
library;

import 'package:flutter/material.dart';

import '../iaam_constants.dart';
import '../model/data/data.dart';

/// Shared periodic table for Make (max=10) and Mix (max=18).
class ExpandedPeriodicTable extends StatelessWidget {
  const ExpandedPeriodicTable({
    super.key,
    required this.selectedZ,
    required this.onSelect,
    this.interactiveMax = 10,
  });

  final int selectedZ;
  final ValueChanged<int> onSelect;
  final int interactiveMax;

  static const _buttonSize = 50.0;

  /// POPULATED_CELLS-style columns for periods 1–3 (gap at col 2).
  static const _row0 = [0, 8];
  static const _row1 = [0, 1, 3, 4, 5, 6, 7, 8];
  static const _row2 = [0, 1, 3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    final elements = ElementRepository.instance;
    final maxZ = interactiveMax.clamp(1, 18);

    Widget cell(int z, int col, int row) {
      final el = elements.getByAtomicNumber(z)!;
      final selected = z == selectedZ;
      return Positioned(
        left: col * _buttonSize,
        top: row * _buttonSize,
        width: _buttonSize,
        height: _buttonSize,
        child: Material(
          color: selected
              ? IaamConstants.selectedCell
              : IaamConstants.panelBackground,
          child: InkWell(
            onTap: () => onSelect(z),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 0.5),
              ),
              child: Text(
                el.symbol,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final cells = <Widget>[];
    var z = 1;
    for (final col in _row0) {
      if (z > maxZ) break;
      cells.add(cell(z++, col, 0));
    }
    for (final col in _row1) {
      if (z > maxZ) break;
      cells.add(cell(z++, col, 1));
    }
    if (maxZ > 10) {
      for (final col in _row2) {
        if (z > maxZ) break;
        cells.add(cell(z++, col, 2));
      }
    }

    final rows = maxZ > 10 ? 3 : 2;
    final mini = _MiniPeriodicTable(
      selectedZ: selectedZ,
      interactiveMax: maxZ,
    );

    const expandedW = 9 * _buttonSize;
    final expandedH = rows * _buttonSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Periodic Table',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: expandedW,
          child: Column(
            children: [
              Align(alignment: Alignment.center, child: mini),
              CustomPaint(
                size: const Size(expandedW, 20),
                painter: _ConnectingLinesPainter(),
              ),
              SizedBox(
                width: expandedW,
                height: expandedH,
                child: Stack(children: cells),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniPeriodicTable extends StatelessWidget {
  const _MiniPeriodicTable({
    required this.selectedZ,
    required this.interactiveMax,
  });

  final int selectedZ;
  final int interactiveMax;

  static const cell = 12.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18 * cell * 0.55,
      height: 3 * cell,
      child: CustomPaint(
        painter: _MiniTablePainter(
          selectedZ: selectedZ,
          interactiveMax: interactiveMax,
          cell: cell,
        ),
      ),
    );
  }
}

class _MiniTablePainter extends CustomPainter {
  _MiniTablePainter({
    required this.selectedZ,
    required this.interactiveMax,
    required this.cell,
  });

  final int selectedZ;
  final int interactiveMax;
  final double cell;

  static (int col, int row) posFor(int z) {
    const map = <int, (int, int)>{
      1: (0, 0),
      2: (17, 0),
      3: (0, 1),
      4: (1, 1),
      5: (12, 1),
      6: (13, 1),
      7: (14, 1),
      8: (15, 1),
      9: (16, 1),
      10: (17, 1),
      11: (0, 2),
      12: (1, 2),
      13: (12, 2),
      14: (13, 2),
      15: (14, 2),
      16: (15, 2),
      17: (16, 2),
      18: (17, 2),
    };
    return map[z] ?? (0, 0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade600
      ..strokeWidth = 0.5;
    for (var z = 1; z <= interactiveMax; z++) {
      final (c, r) = posFor(z);
      final rect = Rect.fromLTWH(c * cell * 0.55, r * cell, cell * 0.55, cell);
      final fill = Paint()
        ..color = z == selectedZ
            ? IaamConstants.selectedCell
            : IaamConstants.panelBackground;
      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniTablePainter oldDelegate) =>
      oldDelegate.selectedZ != selectedZ ||
      oldDelegate.interactiveMax != interactiveMax;
}

class _ConnectingLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
