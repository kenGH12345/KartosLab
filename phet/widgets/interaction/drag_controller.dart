/// Drag Controller — manages drag state for canvas objects.
///
/// Can be used by painters / hit-test systems to track which object is
/// being dragged and update its position.
library;

import 'package:flutter/material.dart';

/// Represents the state of a drag operation.
class DragState {
  final int? objectId;
  final Offset lastScreen;
  final Offset lastWorld;

  const DragState({
    this.objectId,
    required this.lastScreen,
    required this.lastWorld,
  });

  static const DragState none = DragState(lastScreen: Offset.zero, lastWorld: Offset.zero);

  bool get isActive => objectId != null;
}

/// Controller that manages drag state and notifies listeners.
class DragController extends ChangeNotifier {
  DragState _state = DragState.none;
  DragState get state => _state;

  void startDrag(int objectId, Offset screen, Offset world) {
    _state = DragState(objectId: objectId, lastScreen: screen, lastWorld: world);
    notifyListeners();
  }

  void updateDrag(Offset screen, Offset world) {
    if (!_state.isActive) return;
    _state = DragState(objectId: _state.objectId, lastScreen: screen, lastWorld: world);
    notifyListeners();
  }

  void endDrag() {
    _state = DragState.none;
    notifyListeners();
  }
}
