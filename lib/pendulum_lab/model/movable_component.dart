import 'pl_vector2.dart';

/// Source: `MovableComponent.js`.
class MovableComponent {
  MovableComponent({required this.initiallyVisible})
      : isVisible = initiallyVisible;

  bool isVisible;
  final bool initiallyVisible;

  /// View-space position. Ruler/PeriodTimer = center; Stopwatch = top-left.
  PlVector2? position;
  PlVector2? initialPosition;

  void setInitialPosition(PlVector2 value) {
    initialPosition = value;
    position = value;
  }

  void reset() {
    position = initialPosition;
    isVisible = initiallyVisible;
  }
}
