import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../a11y/gfl_a11y_strings.dart';
import '../a11y/gfl_keyboard_actions.dart';
import '../gfl_strings.dart';
import '../model/gravity_force_lab_model.dart';
import '../transform/math_coordinate_transform.dart';

/// Horizontal mass drag — PhET `ISLCObjectNode` AccessibleSlider / DragListener.
///
/// Pointer drag + keyboard (Left/Right, Shift fine 0.1 m, Page 1.0 m, Home/End).
class MassDragTarget extends StatelessWidget {
  const MassDragTarget({
    super.key,
    required this.model,
    required this.transform,
    required this.layoutKey,
    required this.which,
    required this.center,
    required this.radiusView,
    this.focusOrder,
  });

  final GravityForceLabModel model;
  final MathCoordinateTransform transform;
  final GlobalKey layoutKey;
  final int which;
  final Offset center;
  final double radiusView;
  final double? focusOrder;

  String get _label =>
      which == 1 ? GflStrings.mass1Label : GflStrings.mass2Label;

  double get _positionX =>
      which == 1 ? model.mass1.positionX : model.mass2.positionX;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      GflKeyboardActions.applyPositionStep(
        model,
        which,
        increase: true,
        page: false,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      GflKeyboardActions.applyPositionStep(
        model,
        which,
        increase: false,
        page: false,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      GflKeyboardActions.applyPositionStep(
        model,
        which,
        increase: true,
        page: true,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      GflKeyboardActions.applyPositionStep(
        model,
        which,
        increase: false,
        page: true,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      GflKeyboardActions.jumpPositionMin(model, which);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      GflKeyboardActions.jumpPositionMax(model, which);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final hit = radiusView + 24;
    final x = _positionX;
    final valueText = '${x.toStringAsFixed(1)} m';

    Widget child = Focus(
      onKeyEvent: _onKey,
      child: Builder(
        builder: (context) {
          return Semantics(
            container: true,
            slider: true,
            label: GflA11yStrings.moveObject(_label),
            value: valueText,
            increasedValue: '${(x + 0.5).toStringAsFixed(1)} m',
            decreasedValue: '${(x - 0.5).toStringAsFixed(1)} m',
            onIncrease: () => GflKeyboardActions.applyPositionStep(
              model,
              which,
              increase: true,
              page: false,
            ),
            onDecrease: () => GflKeyboardActions.applyPositionStep(
              model,
              which,
              increase: false,
              page: false,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Focus.of(context).requestFocus(),
              onPanStart: (_) {
                Focus.of(context).requestFocus();
                model.beginDrag(which);
              },
              onPanUpdate: (d) {
                final box =
                    layoutKey.currentContext?.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(d.globalPosition);
                final modelX = transform.viewToModelX(local.dx);
                model.setPositionWhileDragging(which, modelX);
              },
              onPanEnd: (_) => model.endDrag(which),
              onPanCancel: () => model.endDrag(which),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );

    if (focusOrder != null) {
      child = FocusTraversalOrder(
        order: NumericFocusOrder(focusOrder!),
        child: child,
      );
    }

    return Positioned(
      left: center.dx - hit,
      top: center.dy - hit,
      width: hit * 2,
      height: hit * 2,
      child: child,
    );
  }
}
