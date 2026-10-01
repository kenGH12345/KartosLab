import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/hookes_law_numbers.dart';
import '../../model/robotic_arm.dart';
import '../../model/robotic_arm_drag.dart';
import '../../model/spring.dart';

/// Pointer drag shared by the series arm and the parallel arm.
///
/// Each system view has its own mixin state, so the two arms do not share
/// a gesture. Snap is only `applyRoboticArmPointerLeft`.
mixin SystemsArmDrag<T extends StatefulWidget> on State<T> {
  int openGestures = 0;
  bool _armDrag = false;
  double _dragStartLeft = 0;
  double _dragStartGlobalX = 0;
  final List<VoidCallback> detach = [];

  void bindNumber(void Function(void Function(double)) add, void Function(void Function(double)) remove) {
    void listener(double _) {
      if (mounted) {
        setState(() {});
      }
    }

    add(listener);
    detach.add(() => remove(listener));
  }

  void bindSpring(Spring spring) {
    bindNumber(spring.appliedForceProperty.addListener, spring.appliedForceProperty.removeListener);
    bindNumber(spring.springConstantProperty.addListener, spring.springConstantProperty.removeListener);
    bindNumber(spring.displacementProperty.addListener, spring.displacementProperty.removeListener);
    bindNumber(spring.rightProperty.addListener, spring.rightProperty.removeListener);
  }

  void unbindAll() {
    for (final undo in detach) {
      undo();
    }
    detach.clear();
  }

  void cancelGestures() {
    _armDrag = false;
    openGestures = 0;
  }

  void gestureStart() => setState(() => openGestures++);

  void gestureEnd() => setState(() => openGestures = math.max(0, openGestures - 1));

  bool grippersOpenFor(Spring equivalent) {
    final fixed = HookesLawNumbers.toFixedNumber(
      equivalent.displacement,
      HookesLawConstants.displacementDecimalPlaces,
    );
    return openGestures == 0 && fixed == 0;
  }

  double _pixelsPerLayout() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) {
      return 1;
    }
    final origin = box.localToGlobal(Offset.zero);
    final step = box.localToGlobal(const Offset(1, 0));
    final scale = (step - origin).distance;
    return scale == 0 ? 1 : scale;
  }

  void startArmDrag(DragStartDetails details, RoboticArm arm) {
    _armDrag = true;
    _dragStartLeft = arm.left;
    _dragStartGlobalX = details.globalPosition.dx;
    gestureStart();
  }

  void updateArmDrag(DragUpdateDetails details, RoboticArm arm, Spring equivalent) {
    if (!_armDrag) {
      return;
    }
    final dx = (details.globalPosition.dx - _dragStartGlobalX) / _pixelsPerLayout();
    applyRoboticArmPointerLeft(
      arm: arm,
      springRightRange: equivalent.rightRange,
      proposedLeft: _dragStartLeft + dx / HookesLawConstants.unitDisplacementX,
    );
  }

  void endArmDrag() {
    if (!_armDrag) {
      return;
    }
    _armDrag = false;
    gestureEnd();
  }
}
