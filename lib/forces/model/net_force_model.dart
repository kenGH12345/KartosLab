import 'famb_constants.dart';

enum PullerSize { small, medium, large }

enum PullerTeam { left, right }

/// Display color pair preference (PhET ForcesAndMotionBasicsPreferences).
enum PullerColorScheme { blueRed, purpleOrange }

class Puller {
  Puller({
    required this.id,
    required this.size,
    required this.team,
    this.knotIndex,
  });

  final String id;
  final PullerSize size;
  final PullerTeam team;

  /// Attached knot index 0..3 on that team's side; null = in toolbox.
  int? knotIndex;

  double get force {
    switch (size) {
      case PullerSize.small:
        return NetForceConstants.pullerForceSmall;
      case PullerSize.medium:
        return NetForceConstants.pullerForceMedium;
      case PullerSize.large:
        return NetForceConstants.pullerForceLarge;
    }
  }

  bool get isAttached => knotIndex != null;
}

/// Net Force tug-of-war model — PhET NetForceModel.ts
class NetForceModel {
  NetForceModel({this.colorScheme = PullerColorScheme.blueRed}) {
    _initPullers();
  }

  PullerColorScheme colorScheme;

  final List<Puller> pullers = [];

  double cartPosition = 0;
  double cartVelocity = 0;
  double speed = 0;
  double duration = 0;
  double time = 0;

  bool isRunning = false;
  bool hasStarted = false;
  bool isCompleted = false;

  /// 'left' | 'right' when completed
  String? winner;

  bool showSumOfForces = false;
  bool showValues = false;
  bool showSpeed = false;

  void _initPullers() {
    pullers.clear();
    // Left (blue): large, medium, small, small — PhET order
    pullers.addAll([
      Puller(id: 'largeLeft', size: PullerSize.large, team: PullerTeam.left),
      Puller(id: 'mediumLeft', size: PullerSize.medium, team: PullerTeam.left),
      Puller(id: 'smallLeft1', size: PullerSize.small, team: PullerTeam.left),
      Puller(id: 'smallLeft2', size: PullerSize.small, team: PullerTeam.left),
      Puller(id: 'smallRight1', size: PullerSize.small, team: PullerTeam.right),
      Puller(id: 'smallRight2', size: PullerSize.small, team: PullerTeam.right),
      Puller(id: 'mediumRight', size: PullerSize.medium, team: PullerTeam.right),
      Puller(id: 'largeRight', size: PullerSize.large, team: PullerTeam.right),
    ]);
  }

  List<Puller> get attachedLeft => pullers
      .where((p) => p.team == PullerTeam.left && p.isAttached)
      .toList();

  List<Puller> get attachedRight => pullers
      .where((p) => p.team == PullerTeam.right && p.isAttached)
      .toList();

  /// PhET: negative sum of left pullers.
  double get leftForce =>
      -attachedLeft.fold<double>(0, (s, p) => s + p.force);

  /// PhET: positive sum of right pullers.
  double get rightForce =>
      attachedRight.fold<double>(0, (s, p) => s + p.force);

  double get netForce => leftForce + rightForce;

  bool get hasAttachedPullers =>
      attachedLeft.isNotEmpty || attachedRight.isNotEmpty;

  /// Knot model x for side + index (before cart offset).
  static double knotInitX(PullerTeam team, int index) {
    final base = team == PullerTeam.left
        ? NetForceConstants.blueKnotOffset
        : NetForceConstants.redKnotOffset;
    return base + index * NetForceConstants.knotSpacing;
  }

  double knotX(PullerTeam team, int index) =>
      knotInitX(team, index) + cartPosition;

  /// Attach puller to knot; clears any other puller on that knot.
  void attachPuller(Puller puller, int knotIndex) {
    assert(knotIndex >= 0 && knotIndex < NetForceConstants.knotsPerSide);
    for (final p in pullers) {
      if (p.team == puller.team && p.knotIndex == knotIndex) {
        p.knotIndex = null;
      }
    }
    puller.knotIndex = knotIndex;
  }

  void detachPuller(Puller puller) {
    puller.knotIndex = null;
  }

  void go() {
    if (isCompleted) return;
    if (!hasAttachedPullers && !isRunning) return;
    isRunning = true;
    hasStarted = true;
  }

  void pause() {
    isRunning = false;
  }

  /// Return cart to center; keep pullers attached (PhET ReturnButton).
  void returnCart() {
    cartPosition = 0;
    cartVelocity = 0;
    speed = 0;
    duration = 0;
    isRunning = false;
    isCompleted = false;
    winner = null;
    // hasStarted stays true in PhET until Reset — actually Return sets hasStarted?
    // PhET: hasStartedProperty stays; Return enabled via hasStarted.
    // After return, user can Go again.
  }

  void resetAll() {
    returnCart();
    hasStarted = false;
    time = 0;
    showSumOfForces = false;
    showValues = false;
    showSpeed = false;
    for (final p in pullers) {
      p.knotIndex = null;
    }
  }

  /// PhET NetForceModel.step
  void step(double dt) {
    if (isRunning) {
      duration += dt;
      final newV =
          cartVelocity + netForce * dt * NetForceConstants.velocityCoeff;
      speed = newV.abs();

      final newX = cartPosition + newV * dt * NetForceConstants.positionCoeff;
      final limit = NetForceConstants.winThreshold;

      if (newX > limit || newX < -limit) {
        speed = 0;
        cartVelocity = 0;
        cartPosition = newX > limit ? limit : -limit;
        isRunning = false;
        isCompleted = true;
        winner = cartPosition < 0 ? 'left' : 'right';
      } else {
        cartVelocity = newV;
        cartPosition = newX;
      }
    }
    time += dt;
  }
}
