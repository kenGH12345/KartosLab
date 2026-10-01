import 'ball.dart';
import 'cl_vec.dart';

/// Center of mass of balls currently in the system — `js/common/model/CenterOfMass.js`
class CenterOfMass {
  CenterOfMass({
    required this.balls,
  });

  /// Balls currently in the system (not prepopulated).
  final List<Ball> balls;

  final CollisionLabPath path = CollisionLabPath();

  double get _totalMass {
    var m = 0.0;
    for (final b in balls) {
      m += b.mass;
    }
    return m;
  }

  ClVec get position {
    if (balls.isEmpty) return ClVec.zero;
    var sx = 0.0;
    var sy = 0.0;
    for (final b in balls) {
      sx += b.position.x * b.mass;
      sy += b.position.y * b.mass;
    }
    final m = _totalMass;
    return ClVec(sx / m, sy / m);
  }

  ClVec get velocity {
    if (balls.isEmpty) return ClVec.zero;
    var px = 0.0;
    var py = 0.0;
    for (final b in balls) {
      final mom = b.momentum;
      px += mom.x;
      py += mom.y;
    }
    final m = _totalMass;
    return ClVec(px / m, py / m);
  }

  double get speed => velocity.magnitude;

  void reset() {
    path.clear();
  }
}
