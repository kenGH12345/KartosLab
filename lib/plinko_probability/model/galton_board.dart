import 'dart:ui';

import '../plinko_constants.dart';
import 'peg.dart';

/// Triangular lattice of pegs — `GaltonBoard.js`.
class GaltonBoard {
  GaltonBoard(this.numberOfRows) {
    for (var row = 0; row <= PlinkoConstants.rowsMax; row++) {
      for (var col = 0; col <= row; col++) {
        pegs.add(Peg(rowNumber: row, columnNumber: col));
      }
    }
    updateForRows(numberOfRows);
  }

  int numberOfRows;
  final List<Peg> pegs = [];

  static double getPegSpacing(int numberOfRows) =>
      PlinkoConstants.boardWidth / (numberOfRows + 1);

  static Offset pegPosition(int rowNumber, int columnNumber, int numberOfRows) {
    final scale = numberOfRows + 1;
    return Offset(
      (-rowNumber / 2 + columnNumber) / scale,
      (-rowNumber - 2 * PlinkoConstants.pegHeightFractionOffset) / scale,
    );
  }

  static bool isPegVisible(int rowNumber, int numberOfRows) =>
      rowNumber < numberOfRows;

  void updateForRows(int rows) {
    numberOfRows = rows;
    for (final peg in pegs) {
      peg.isVisible = isPegVisible(peg.rowNumber, rows);
      if (peg.isVisible) {
        peg.position =
            pegPosition(peg.rowNumber, peg.columnNumber, rows);
      }
    }
  }

  List<Peg> get visiblePegs =>
      pegs.where((p) => p.isVisible).toList(growable: false);
}
