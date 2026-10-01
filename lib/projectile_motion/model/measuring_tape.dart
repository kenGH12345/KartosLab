import 'dart:ui';

/// PhET `ProjectileMotionMeasuringTape.ts`。
class PmMeasuringTape {
  Offset basePosition = Offset.zero;
  Offset tipPosition = const Offset(1, 0);
  bool isActive = false;

  void reset() {
    basePosition = Offset.zero;
    tipPosition = const Offset(1, 0);
    isActive = false;
  }
}
