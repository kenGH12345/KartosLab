import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../a11y/gfl_a11y_strings.dart';
import '../a11y/gfl_keyboard_actions.dart';
import '../audio/gfl_audio.dart';
import '../model/gravity_force_constants.dart';
import '../model/gravity_force_lab_model.dart';
import '../painters/ruler_painter.dart';
import '../render/gfl_render_data.dart';
import '../transform/math_coordinate_transform.dart';

/// Draggable Full ruler — ISLCRulerNode GrabDrag + KeyboardDragListener.
class RulerWidget extends StatefulWidget {
  const RulerWidget({
    super.key,
    required this.model,
    required this.render,
    required this.transform,
    required this.layoutKey,
    this.audio,
    this.focusOrder,
  });

  final GravityForceLabModel model;
  final GflRenderData render;
  final MathCoordinateTransform transform;
  final GlobalKey layoutKey;
  final GflAudio? audio;
  final double? focusOrder;

  @override
  State<RulerWidget> createState() => _RulerWidgetState();
}

class _RulerWidgetState extends State<RulerWidget> {
  bool _grabbed = false;
  bool _jDown = false;

  GravityForceLabModel get model => widget.model;
  GflAudio? get audio => widget.audio;

  void _toggleGrab() {
    setState(() => _grabbed = !_grabbed);
    if (_grabbed) {
      model.ruler.isDragging = true;
      audio?.onRulerGrab();
    } else {
      model.ruler.endDrag();
      audio?.onRulerRelease();
    }
  }

  void _nudge(double dx, double dy) {
    if (!_grabbed) return;
    final step = GflKeyboardActions.rulerDelta(
      fine: GflKeyboardActions.shiftDown,
    );
    GflKeyboardActions.nudgeRuler(
      model,
      dx: dx * step,
      dy: dy * step,
    );
    audio?.onRulerMove();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        _jDown = false;
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyJ) {
      _jDown = true;
      return KeyEventResult.handled;
    }

    // J+H / J+C — ISLCRulerNode hotkeys (work when focused).
    if (_jDown && key == LogicalKeyboardKey.keyH) {
      model.jumpRulerHome();
      if (_grabbed) {
        setState(() => _grabbed = false);
        audio?.onRulerRelease();
      }
      return KeyEventResult.handled;
    }
    if (_jDown && key == LogicalKeyboardKey.keyC) {
      model.jumpRulerZeroToMass1Center();
      return KeyEventResult.handled;
    }

    // Grab / release — GrabDragInteraction Enter/Space.
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      _toggleGrab();
      return KeyEventResult.handled;
    }

    if (!_grabbed) return KeyEventResult.ignored;

    // Arrows + WASD — KeyboardDragListener.
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _nudge(-1, 0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      _nudge(1, 0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      _nudge(0, 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      _nudge(0, -1);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.render.rulerCenterView;
    final w = widget.render.rulerWidthView;
    final h = widget.render.rulerHeightView;
    final valueText =
        '(${model.ruler.positionX.toStringAsFixed(1)}, ${model.ruler.positionY.toStringAsFixed(1)}) m';

    Widget hit = Focus(
      onKeyEvent: _onKey,
      child: Builder(
        builder: (context) {
          return Semantics(
            container: true,
            button: true,
            label: GflA11yStrings.measureDistanceRuler,
            value: _grabbed
                ? '${GflA11yStrings.rulerGrabbed}, $valueText'
                : valueText,
            hint: _grabbed
                ? '使用方向键或 WASD 移动。按 Enter 释放。'
                : '按 Enter 或空格键抓取。',
            onTap: () {
              Focus.of(context).requestFocus();
              _toggleGrab();
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Focus.of(context).requestFocus(),
              onPanStart: (_) {
                Focus.of(context).requestFocus();
                if (!_grabbed) {
                  setState(() => _grabbed = true);
                }
                model.ruler.isDragging = true;
                audio?.onRulerGrab();
              },
              onPanUpdate: (d) {
                final box = widget.layoutKey.currentContext?.findRenderObject()
                    as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(d.globalPosition);
                final modelPos = widget.transform.viewToModel(local);
                model.setRulerPosition(modelPos.dx, modelPos.dy);
                audio?.onRulerMove();
              },
              onPanEnd: (_) {
                model.ruler.endDrag();
                model.setRulerPosition(
                  model.ruler.positionX,
                  model.ruler.positionY,
                );
                if (_grabbed) {
                  setState(() => _grabbed = false);
                }
                audio?.onRulerRelease();
              },
              onPanCancel: () {
                model.ruler.endDrag();
                model.setRulerPosition(
                  model.ruler.positionX,
                  model.ruler.positionY,
                );
                if (_grabbed) {
                  setState(() => _grabbed = false);
                }
                audio?.onRulerRelease();
              },
              child: MouseRegion(
                cursor: _grabbed
                    ? SystemMouseCursors.grabbing
                    : SystemMouseCursors.grab,
                child: ColoredBox(
                  color: _grabbed
                      ? const Color(0x220096FF)
                      : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.focusOrder != null) {
      hit = FocusTraversalOrder(
        order: NumericFocusOrder(widget.focusOrder!),
        child: hit,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ExcludeSemantics(
          child: IgnorePointer(
            child: CustomPaint(
              size: widget.render.layoutSize,
              painter: RulerPainter(render: widget.render),
            ),
          ),
        ),
        Positioned(
          left: c.dx - w / 2,
          top: c.dy - h / 2,
          width: w,
          height: h,
          child: hit,
        ),
      ],
    );
  }
}

/// Screen-level J+H / J+C (Phase 3 contract; skipTraversal, no autofocus).
class RulerKeyboardShortcuts extends StatefulWidget {
  const RulerKeyboardShortcuts({
    super.key,
    required this.model,
    required this.child,
  });

  final GravityForceLabModel model;
  final Widget child;

  @override
  State<RulerKeyboardShortcuts> createState() => _RulerKeyboardShortcutsState();
}

class _RulerKeyboardShortcutsState extends State<RulerKeyboardShortcuts> {
  bool _jDown = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'gfl_ruler_hotkeys');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        _jDown = true;
        return KeyEventResult.handled;
      }
      if (_jDown && event.logicalKey == LogicalKeyboardKey.keyH) {
        widget.model.jumpRulerHome();
        return KeyEventResult.handled;
      }
      if (_jDown && event.logicalKey == LogicalKeyboardKey.keyC) {
        widget.model.jumpRulerZeroToMass1Center();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        _jDown = false;
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      key: const ValueKey('gfl_ruler_hotkeys'),
      focusNode: _focusNode,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: widget.child,
    );
  }
}

/// Expose ruler keyboard step constants for tests.
class GflRulerKeyboard {
  GflRulerKeyboard._();
  static double get step => GravityForceConstants.rulerKeyboardStep;
  static double get fineStep => GravityForceConstants.rulerShiftKeyboardStep;
}
