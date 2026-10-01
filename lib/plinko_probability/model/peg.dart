import 'dart:ui';

/// One peg on the Galton board.
class Peg {
  Peg({
    required this.rowNumber,
    required this.columnNumber,
    this.isVisible = false,
    this.position = Offset.zero,
  });

  final int rowNumber;
  final int columnNumber;
  bool isVisible;
  Offset position;
}

/// Direction chosen at a peg for the next hop.
enum PegDirection { left, right }

/// Precomputed hop entry in a ball's `pegHistory`.
class PegHop {
  const PegHop({
    required this.rowNumber,
    required this.positionX,
    required this.positionY,
    required this.direction,
  });

  final int rowNumber;
  final double positionX;
  final double positionY;
  final PegDirection direction;
}
