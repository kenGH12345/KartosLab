/// Index of TEMPORARY / BLOCKED stand-ins until `solar-system-common` lands.
///
/// Do not duplicate literals here — values live in [MySolarSystemConstants].
/// See `requirements/req-my-solar-system/PARAMETER_AUDIT.md`.
library;

/// Audit registry: symbol → implementation file (relative to `my_solar_system/`).
class TemporaryImplementations {
  TemporaryImplementations._();

  static const constrainDragPoint =
      'render/constrain_drag_point.dart · constrainDragPoint()';
  static const isOffscreen =
      'model/celestial_body.dart · CelestialBody.isOffscreen';
  static const preventCollision =
      'model/celestial_body.dart · CelestialBody.preventCollision';
  static const maxPathPoints =
      'my_solar_system_constants.dart · maxPathPoints';
  static const velocityOffscaleGeometry =
      'painters/velocity_vectors_painter.dart · _paintOffscaleIndicator';
  static const velocityOffscalePredicate =
      'render/velocity_vector.dart · isVelocityVectorOffscale';
  static const gravityOffscalePredicate =
      'controller/my_solar_system_controller.dart · isAnyGravityForceOffscale';
  static const centerOrbitOffset =
      'my_solar_system_constants.dart · centerOrbitOffsetX/Y (MVT ignores)';

  static const all = <String>[
    constrainDragPoint,
    isOffscreen,
    preventCollision,
    maxPathPoints,
    velocityOffscaleGeometry,
    velocityOffscalePredicate,
    gravityOffscalePredicate,
    centerOrbitOffset,
  ];
}
