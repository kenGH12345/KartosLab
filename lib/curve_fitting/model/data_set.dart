import 'data_point.dart';

/// Collection of [DataPoint]s — PhET `createPoints` observable array helpers.
class DataSet {
  final List<DataPoint> points = [];

  /// Points inside the graph that are not animating (used for all fits / stats).
  List<DataPoint> getRelevantPoints() => points
      .where((p) => p.isInsideGraph && !p.animationActive)
      .toList(growable: false);

  /// Count of unique x positions among relevant points.
  int getNumberUniquePositionX() {
    final xs = <double>{};
    for (final p in getRelevantPoints()) {
      xs.add(p.x);
    }
    return xs.length;
  }

  void add(DataPoint point) => points.add(point);

  bool remove(DataPoint point) => points.remove(point);

  void clear() => points.clear();

  int get length => points.length;
}
