import 'dart:math' as math;

/// PhET `dot/Vector3` subset used by Molecule Shapes. Immutable.
class Vec3 {
  const Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const zero = Vec3(0, 0, 0);
  static const xUnit = Vec3(1, 0, 0);
  static const yUnit = Vec3(0, 1, 0);
  static const zUnit = Vec3(0, 0, 1);

  double get magnitude => math.sqrt(x * x + y * y + z * z);

  Vec3 plus(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);

  Vec3 minus(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);

  Vec3 times(double s) => Vec3(x * s, y * s, z * s);

  Vec3 negated() => Vec3(-x, -y, -z);

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;

  Vec3 cross(Vec3 o) => Vec3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  Vec3 normalized() {
    final m = magnitude;
    if (m == 0) {
      return zero;
    }
    return times(1 / m);
  }

  /// `Vector3.setMagnitude`.
  Vec3 withMagnitude(double m) => normalized().times(m);

  double distance(Vec3 o) => minus(o).magnitude;

  bool almostEquals(Vec3 o, [double epsilon = 1e-9]) =>
      (x - o.x).abs() < epsilon &&
      (y - o.y).abs() < epsilon &&
      (z - o.z).abs() < epsilon;

  @override
  String toString() => 'Vec3($x, $y, $z)';
}

/// THREE.Quaternion subset. Hamilton product matches `Quaternion.multiply`.
class Quat {
  const Quat(this.x, this.y, this.z, this.w);

  final double x;
  final double y;
  final double z;
  final double w;

  static const identity = Quat(0, 0, 0, 1);

  double get magnitude => math.sqrt(x * x + y * y + z * z + w * w);

  Quat normalized() {
    final m = magnitude;
    if (m == 0) {
      return identity;
    }
    return Quat(x / m, y / m, z / m, w / m);
  }

  /// `this * q` (THREE `this.multiply(q)`).
  Quat multiplied(Quat q) => Quat(
        w * q.x + x * q.w + y * q.z - z * q.y,
        w * q.y - x * q.z + y * q.w + z * q.x,
        w * q.z + x * q.y - y * q.x + z * q.w,
        w * q.w - x * q.x - y * q.y - z * q.z,
      );

  Vec3 rotate(Vec3 v) {
    final tx = 2 * (y * v.z - z * v.y);
    final ty = 2 * (z * v.x - x * v.z);
    final tz = 2 * (x * v.y - y * v.x);
    return Vec3(
      v.x + w * tx + (y * tz - z * ty),
      v.y + w * ty + (z * tx - x * tz),
      v.z + w * tz + (x * ty - y * tx),
    );
  }

  /// THREE `Quaternion.setFromEuler` with order XYZ.
  static Quat fromEulerXyz(double ex, double ey, double ez) {
    final c1 = math.cos(ex / 2);
    final c2 = math.cos(ey / 2);
    final c3 = math.cos(ez / 2);
    final s1 = math.sin(ex / 2);
    final s2 = math.sin(ey / 2);
    final s3 = math.sin(ez / 2);
    return Quat(
      s1 * c2 * c3 + c1 * s2 * s3,
      c1 * s2 * c3 - s1 * c2 * s3,
      c1 * c2 * s3 + s1 * s2 * c3,
      c1 * c2 * c3 - s1 * s2 * s3,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Quat && other.x == x && other.y == y && other.z == z && other.w == w;

  @override
  int get hashCode => Object.hash(x, y, z, w);

  /// Shortest rotation taking unit direction [a] onto [b].
  static Quat rotateAToB(Vec3 a, Vec3 b) {
    final an = a.normalized();
    final bn = b.normalized();
    final d = an.dot(bn).clamp(-1.0, 1.0);
    if (d > 0.999999) {
      return identity;
    }
    if (d < -0.999999) {
      var axis = const Vec3(1, 0, 0).cross(an);
      if (axis.magnitude < 1e-6) {
        axis = const Vec3(0, 1, 0).cross(an);
      }
      axis = axis.normalized();
      return Quat(axis.x, axis.y, axis.z, 0);
    }
    final c = an.cross(bn);
    return Quat(c.x, c.y, c.z, 1 + d).normalized();
  }
}

/// Row-major 3×3. Used to seat real-molecule lone pairs into the bond frame.
class Mat3 {
  const Mat3(this.m);

  final List<double> m;

  static const identity = Mat3([1, 0, 0, 0, 1, 0, 0, 0, 1]);

  static Mat3 columns(Vec3 x, Vec3 y, Vec3 z) => Mat3([
        x.x,
        y.x,
        z.x,
        x.y,
        y.y,
        z.y,
        x.z,
        y.z,
        z.z,
      ]);

  Mat3 transposed() => Mat3([
        m[0],
        m[3],
        m[6],
        m[1],
        m[4],
        m[7],
        m[2],
        m[5],
        m[8],
      ]);

  Vec3 times(Vec3 v) => Vec3(
        m[0] * v.x + m[1] * v.y + m[2] * v.z,
        m[3] * v.x + m[4] * v.y + m[5] * v.z,
        m[6] * v.x + m[7] * v.y + m[8] * v.z,
      );

  Mat3 timesMat(Mat3 o) {
    final a = m;
    final b = o.m;
    final out = List<double>.filled(9, 0);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        out[r * 3 + c] = a[r * 3] * b[c] +
            a[r * 3 + 1] * b[3 + c] +
            a[r * 3 + 2] * b[6 + c];
      }
    }
    return Mat3(out);
  }

  /// Maps the plane of [fromA],[fromB] onto the plane of [toA],[toB].
  static Mat3 alignPair(Vec3 fromA, Vec3 fromB, Vec3 toA, Vec3 toB) {
    return _frame(toA, toB).timesMat(_frame(fromA, fromB).transposed());
  }

  static Mat3 _frame(Vec3 a, Vec3 b) {
    final x = a.normalized();
    var z = a.cross(b);
    if (z.magnitude < 1e-8) {
      final axis = x.x.abs() < 0.9 ? const Vec3(1, 0, 0) : const Vec3(0, 1, 0);
      z = x.cross(axis);
    }
    z = z.normalized();
    final y = z.cross(x).normalized();
    return Mat3.columns(x, y, z);
  }
}
