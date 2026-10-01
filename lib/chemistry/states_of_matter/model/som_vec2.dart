import 'dart:math' as math;

/// Mutable 2D vector used throughout the SOM model (PhET Vector2 subset).
class SomVec2 {
  SomVec2([this.x = 0, this.y = 0]);

  double x;
  double y;

  void setXY(double newX, double newY) {
    x = newX;
    y = newY;
  }

  void set(SomVec2 other) {
    x = other.x;
    y = other.y;
  }

  void addXY(double dx, double dy) {
    x += dx;
    y += dy;
  }

  void subtractXY(double dx, double dy) {
    x -= dx;
    y -= dy;
  }

  void add(SomVec2 other) {
    x += other.x;
    y += other.y;
  }

  double get magnitude => math.sqrt(x * x + y * y);

  void setMagnitude(double m) {
    final mag = magnitude;
    if (mag == 0) {
      return;
    }
    final scale = m / mag;
    x *= scale;
    y *= scale;
  }

  void setPolar(double magnitude, double angle) {
    x = magnitude * math.cos(angle);
    y = magnitude * math.sin(angle);
  }

  double distanceXY(double otherX, double otherY) {
    final dx = x - otherX;
    final dy = y - otherY;
    return math.sqrt(dx * dx + dy * dy);
  }

  SomVec2 copy() => SomVec2(x, y);

  @override
  String toString() => 'SomVec2($x, $y)';
}
