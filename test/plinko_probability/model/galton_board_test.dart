import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/model/galton_board.dart';
import 'package:kratos/plinko_probability/plinko_constants.dart';

void main() {
  group('GaltonBoard', () {
    test('pegSpacing = boardWidth / (nRows+1)', () {
      expect(GaltonBoard.getPegSpacing(12), closeTo(1 / 13, 1e-12));
      expect(GaltonBoard.getPegSpacing(1), closeTo(0.5, 1e-12));
    });

    test('top peg at origin row/col formula', () {
      final p = GaltonBoard.pegPosition(0, 0, 12);
      expect(p.dx, closeTo(0, 1e-12));
      expect(
        p.dy,
        closeTo((-2 * PlinkoConstants.pegHeightFractionOffset) / 13, 1e-12),
      );
    });

    test('visible pegs = n(n+1)/2 for n rows', () {
      final board = GaltonBoard(12);
      expect(board.visiblePegs.length, 12 * 13 ~/ 2);
      board.updateForRows(5);
      expect(board.visiblePegs.length, 5 * 6 ~/ 2);
      expect(
        board.pegs.where((p) => p.rowNumber == 5).every((p) => !p.isVisible),
        isTrue,
      );
    });
  });
}
