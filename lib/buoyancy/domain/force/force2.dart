import '../world/vec2.dart';

/// Force value object. Model space, +y up, Newtons.
///
/// View arrows must read these vectors; painters must not recompute direction.
class Force2 {
  const Force2(this.value);

  final BVec2 value;

  static const zero = Force2(BVec2.zero);

  double get magnitude => value.magnitude;
  double get x => value.x;
  double get y => value.y;
  bool get isFinite => value.isFinite;

  Force2 operator +(Force2 o) => Force2(value + o.value);
  Force2 operator -(Force2 o) => Force2(value - o.value);
  Force2 operator *(double s) => Force2(value * s);

  @override
  String toString() => 'Force2(${value.x}, ${value.y})';
}
