import 'dart:ui';

/// Axis-aligned bounds in model meters (PhET ThermalContactArea / Bounds2 subset).
class ModelRect {
  const ModelRect(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
  Offset get center => Offset((minX + maxX) / 2, (minY + maxY) / 2);

  bool containsPoint(Offset p) =>
      p.dx >= minX && p.dx <= maxX && p.dy >= minY && p.dy <= maxY;

  bool intersects(ModelRect other) =>
      minX < other.maxX &&
      maxX > other.minX &&
      minY < other.maxY &&
      maxY > other.minY;

  ModelRect translated(Offset delta) => ModelRect(
        minX + delta.dx,
        minY + delta.dy,
        maxX + delta.dx,
        maxY + delta.dy,
      );
}
