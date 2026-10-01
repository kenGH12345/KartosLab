import '../model/va_vec.dart';
import '../model/vector.dart';
import '../vector_addition_constants.dart';

/// Linear return-to-toolbox animation — mirrors PhET `Vector.animateToPoint`.
///
/// Animates [VaVector.tailPosition] and [VaVector.xyComponents] toward the
/// toolbox icon (center − finalXy/2). Speed = [VectorAdditionConstants.animationSpeed]
/// model units / second.
class VaReturnAnimation {
  VaReturnAnimation({
    required this.vector,
    required VaVec iconCenterModel,
    required VaVec finalXy,
    this.speed = VectorAdditionConstants.animationSpeed,
  })  : startTail = vector.tailPosition,
        startXy = vector.xyComponents,
        endXy = finalXy,
        endTail = iconCenterModel - finalXy * 0.5 {
    final dist = startTail.distance(endTail);
    duration = dist / speed;
    if (duration < 1e-6) duration = 1e-6;
    vector.isAnimating = true;
    vector.animateToToolbox = true;
  }

  final VaVector vector;
  final VaVec startTail;
  final VaVec endTail;
  final VaVec startXy;
  final VaVec endXy;
  final double speed;
  late final double duration;

  double elapsed = 0;

  /// Advance by [dt] seconds. Returns `true` when finished.
  bool tick(double dt) {
    elapsed += dt;
    final t = (elapsed / duration).clamp(0.0, 1.0);
    vector.tailPosition = VaVec(
      startTail.x + (endTail.x - startTail.x) * t,
      startTail.y + (endTail.y - startTail.y) * t,
    );
    vector.xyComponents = VaVec(
      startXy.x + (endXy.x - startXy.x) * t,
      startXy.y + (endXy.y - startXy.y) * t,
    );
    return t >= 1.0;
  }
}
