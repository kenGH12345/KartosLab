/// Shared drag state machine for Gas Properties scene interactions.
enum SceneDragKind {
  idle,
  lid,
  wall,
  pump,
  heater,
}

class SceneDragState {
  SceneDragKind kind = SceneDragKind.idle;

  /// Model-space offset recorded at pointerDown (pm), for lid/wall.
  double modelOffsetX = 0;

  /// Pump visual lift 0..1 and downward stroke accumulator (view px).
  double pumpLift = 0;
  double pumpDownAccum = 0;

  /// Heater factor −1..1 while dragging.
  double heatFactor = 0;

  bool get isDragging => kind != SceneDragKind.idle;

  void clear() {
    kind = SceneDragKind.idle;
    modelOffsetX = 0;
    pumpLift = 0;
    pumpDownAccum = 0;
    heatFactor = 0;
  }
}
