import 'dart:math' as math;

class BVec3 {
  const BVec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const zero = BVec3(0, 0, 0);

  BVec3 operator +(BVec3 o) => BVec3(x + o.x, y + o.y, z + o.z);
  BVec3 operator -(BVec3 o) => BVec3(x - o.x, y - o.y, z - o.z);
  BVec3 operator *(double s) => BVec3(x * s, y * s, z * s);
  BVec3 operator -() => BVec3(-x, -y, -z);

  double get length => math.sqrt(x * x + y * y + z * z);

  BVec3 normalized() {
    final l = length;
    if (l == 0) {
      return zero;
    }
    return this * (1 / l);
  }

  BVec3 cross(BVec3 o) => BVec3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double dot(BVec3 o) => x * o.x + y * o.y + z * o.z;

  @override
  String toString() => 'BVec3($x,$y,$z)';
}

class BuoyancyRay {
  const BuoyancyRay(this.origin, this.direction);
  final BVec3 origin;
  final BVec3 direction;

  BVec3 at(double t) => origin + direction * t;
}
