/// PhET Graph Data — data structures for graph plotting.
library;

import 'package:flutter/material.dart';

class DataPoint {
  final double x;
  final double y;
  const DataPoint(this.x, this.y);
}

class DataSeries {
  final String name;
  final Color color;
  final List<DataPoint> points;

  const DataSeries({
    required this.name,
    required this.color,
    required this.points,
  });

  /// Append a point (maintains order).
  void addPoint(double x, double y) => points.add(DataPoint(x, y));

  /// Remove old points beyond maxCount (sliding window).
  void trim(int maxCount) {
    while (points.length > maxCount) {
      points.removeAt(0);
    }
  }

  /// Clear all points.
  void clear() => points.clear();
}
