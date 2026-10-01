/// PhET Interactive Object — an object with drag and rotation support.
///
/// Combines [PhetObject] with drag controller for canvas-based interaction.
library;

import 'package:flutter/material.dart';
import '../objects/phet_object.dart';
import '../interaction/drag_controller.dart';

class PhetInteractiveObject extends PhetObject {
  final DragController? dragController;
  final int? id;

  PhetInteractiveObject({
    this.dragController,
    this.id,
    super.position,
    super.velocity,
    super.rotation,
    super.scale,
    super.visible,
    super.enabled,
    super.selected,
  });

  /// Check if a screen point hits this object (subclass override).
  bool hitTest(Offset screenPoint) => false;

  /// Start dragging this object.
  void startDrag(Offset screen, Offset world) {
    if (dragController != null && id != null) {
      dragController!.startDrag(id!, screen, world);
      selected = true;
    }
  }

  /// End dragging.
  void endDrag() {
    if (dragController != null) {
      dragController!.endDrag();
      selected = false;
    }
  }
}

/// A rotatable object adds angle-based interaction.
class PhetRotatableObject extends PhetInteractiveObject {
  double angularVelocity;

  PhetRotatableObject({
    this.angularVelocity = 0,
    super.dragController,
    super.id,
    super.position,
    super.velocity,
    super.rotation,
    super.scale,
    super.visible,
    super.enabled,
    super.selected,
  });

  @override
  void update(double dt) {
    super.update(dt);
    rotation += angularVelocity * dt;
  }
}
