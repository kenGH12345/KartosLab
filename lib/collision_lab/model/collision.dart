/// Potential collision — `js/common/model/Collision.js`
class Collision {
  Collision(this.body1, this.body2, this.time);

  Object? body1;
  Object? body2;

  /// Elapsed time of contact, or null if bodies will not collide.
  double? time;

  bool includes(Object body) => identical(body1, body) || identical(body2, body);

  bool includesBodies(Object a, Object b) => includes(a) && includes(b);

  /// True if [time] lies between [time1] and [time2] (order-independent).
  bool inRange(double time1, double time2) {
    final t = time;
    if (t == null || !t.isFinite) return false;
    if (time2 >= time1) {
      return t >= time1 && t <= time2;
    }
    return t >= time2 && t <= time1;
  }

  @override
  String toString() => 'Collision($body1, $body2, t=$time)';
}
