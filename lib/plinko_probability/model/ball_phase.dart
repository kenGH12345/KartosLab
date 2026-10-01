/// Ball journey phases — `BallPhase.js`.
enum BallPhase {
  /// Ball has left the hopper.
  initial,

  /// Falling within board bounds.
  falling,

  /// Exited lower board bounds; entering a bin.
  exited,

  /// Landed in final position.
  collected,
}
