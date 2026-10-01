import 'dart:ui' show Offset;

/// Cardinal direction with unit vector. Ported from Direction.ts.
class BamDirection {
  BamDirection._(this.vector, this.id);

  final Offset vector;
  final String id;

  late BamDirection opposite;

  static final BamDirection north = BamDirection._(const Offset(0, 1), 'NORTH');
  static final BamDirection south = BamDirection._(const Offset(0, -1), 'SOUTH');
  static final BamDirection east = BamDirection._(const Offset(1, 0), 'EAST');
  static final BamDirection west = BamDirection._(const Offset(-1, 0), 'WEST');

  static final List<BamDirection> values = [north, south, east, west];

  static bool _oppositesWired = false;

  /// Idempotent opposite wiring.
  static void ensureOpposites() {
    if (_oppositesWired) return;
    north.opposite = south;
    south.opposite = north;
    east.opposite = west;
    west.opposite = east;
    _oppositesWired = true;
  }
}
