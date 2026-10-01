import '../caf_constants.dart';
import 'vec2.dart';

/// Draggable model element that can animate back to its toolbox origin.
class CafModelElement {
  CafModelElement(this.initialPosition) : _position = initialPosition;

  CafVec2 _position;
  final CafVec2 initialPosition;

  CafVec2 get position => _position;
  set position(CafVec2 value) {
    _position = value;
    onPositionChanged();
    notify();
  }

  /// Hook for subclasses (e.g. sensors that recompute on move).
  void onPositionChanged() {}

  bool isUserControlled = false;
  bool isActive = false;
  bool isInteractive = true;

  bool isAnimating = false;
  void Function()? onReturnedToOrigin;
  void Function()? onChanged;

  void notify() => onChanged?.call();

  CafVec2? _animStart;
  double? _animTotalTime;

  void beginReturnAnimation() {
    if (isAnimating) return;
    _animStart = _position;
    final distance = _position.distance(initialPosition);
    _animTotalTime = distance / CafConstants.animationVelocity;
    if (_animTotalTime! <= 0) {
      _position = initialPosition;
      onReturnedToOrigin?.call();
      return;
    }
    _animElapsed = 0;
    isAnimating = true;
  }

  double _animElapsed = 0;

  /// Returns true when animation finished this step.
  bool stepAnimation(double dt) {
    if (!isAnimating || _animStart == null || _animTotalTime == null) {
      return false;
    }
    _animElapsed += dt;
    final t = (_animElapsed / _animTotalTime!).clamp(0.0, 1.0);
    final eased = _cubicInOut(t);
    _position = _lerp(_animStart!, initialPosition, eased);
    notify();
    if (t >= 1.0) {
      _position = initialPosition;
      isAnimating = false;
      _animStart = null;
      _animTotalTime = null;
      onReturnedToOrigin?.call();
      return true;
    }
    return false;
  }

  static double _cubicInOut(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - ((-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2)) / 2;
  }

  static CafVec2 _lerp(CafVec2 a, CafVec2 b, double t) =>
      CafVec2(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);

  void dispose() {
    isAnimating = false;
    onReturnedToOrigin = null;
    onChanged = null;
  }
}
