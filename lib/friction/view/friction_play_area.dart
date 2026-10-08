import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../audio/friction_audio.dart';
import '../friction_constants.dart';
import '../friction_strings.dart';
import '../model/friction_model.dart';
import 'painters/book_cover_painter.dart';
import 'painters/friction_thermometer.dart';
import 'painters/magnifier_painters.dart';

/// Design-coordinate play area for Friction (768×504), scaled with FittedBox.
///
/// Macro Chemistry book and magnifier top layer share [FrictionModel.topBookPosition]
/// — dragging either drives the same friction / temperature / atom motion.
class FrictionPlayArea extends StatefulWidget {
  const FrictionPlayArea({
    super.key,
    required this.model,
    this.autoStartClock = true,
    this.enableAudio = true,
  });

  final FrictionModel model;
  final bool autoStartClock;
  final bool enableAudio;

  @override
  State<FrictionPlayArea> createState() => FrictionPlayAreaState();
}

class FrictionPlayAreaState extends State<FrictionPlayArea>
    with SingleTickerProviderStateMixin {
  late final FrictionModel _model;
  FrictionAudio? _audio;
  late final AnimationController _ticker;
  late final FocusNode _focusNode;

  DateTime? _lastTick;
  bool _macroDragging = false;
  bool _magDragging = false;

  final Set<LogicalKeyboardKey> _keysDown = {};

  @override
  void initState() {
    super.initState();
    _model = widget.model;
    _focusNode = FocusNode(debugLabel: 'frictionPlayArea');

    // Create audio only when enabled — avoids audioplayers plugin init in
    // golden / muted tests without changing production audio semantics.
    if (widget.enableAudio) {
      _audio = FrictionAudio();
      _model.onContactStarted = () => _audio?.playContact();
      _model.onShearedOff = () => _audio?.onShearedOff();
    }

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick);

    if (widget.autoStartClock) {
      _ticker.repeat();
    }

    _model.addListener(_onModel);
  }

  void _onModel() {
    if (mounted) setState(() {});
  }

  void _onTick() {
    final now = DateTime.now();
    final last = _lastTick ?? now;
    _lastTick = now;
    var dt = now.difference(last).inMicroseconds / 1e6;
    if (dt <= 0 || dt > 0.1) dt = 1 / 60;

    _applyKeyboardMotion(dt);
    _model.step(dt);
  }

  void _applyKeyboardMotion(double dt) {
    if (!_focusNode.hasFocus || _keysDown.isEmpty) return;

    final shift = HardwareKeyboard.instance.isShiftPressed;
    final speed = shift
        ? FrictionConstants.keyboardShiftDragSpeed
        : FrictionConstants.keyboardDragSpeed;

    var dx = 0.0;
    var dy = 0.0;
    if (_keysDown.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysDown.contains(LogicalKeyboardKey.keyA)) {
      dx -= 1;
    }
    if (_keysDown.contains(LogicalKeyboardKey.arrowRight) ||
        _keysDown.contains(LogicalKeyboardKey.keyD)) {
      dx += 1;
    }
    if (_keysDown.contains(LogicalKeyboardKey.arrowUp) ||
        _keysDown.contains(LogicalKeyboardKey.keyW)) {
      dy -= 1;
    }
    if (_keysDown.contains(LogicalKeyboardKey.arrowDown) ||
        _keysDown.contains(LogicalKeyboardKey.keyS)) {
      dy += 1;
    }
    if (dx == 0 && dy == 0) return;

    final len = math.sqrt(dx * dx + dy * dy);
    _model.moveTopBookBy(Offset(dx / len * speed * dt, dy / len * speed * dt));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _model.removeListener(_onModel);
    _model.onContactStarted = null;
    _model.onShearedOff = null;
    _focusNode.dispose();
    _audio?.dispose();
    super.dispose();
  }

  void _reset() {
    _model.reset();
    _audio?.reset();
    _keysDown.clear();
  }

  // Macro book: particles follow finger 1:1 (small motion). Heating uses
  // PhET ×(1/scale) distance so rapid temperature / shear-off stay intact.
  // On-screen book still only shifts by ×bookDraggingScaleFactor in [build].
  void _onMacroDragStart(DragStartDetails d) {
    _focusNode.requestFocus();
    _macroDragging = true;
    _model.hideHint();
    if (widget.enableAudio) _audio?.playSimplePickup();
  }

  void _onMacroDragUpdate(DragUpdateDetails d) {
    if (!_macroDragging) return;
    final scale = _model.bookDraggingScaleFactor;
    _model.moveTopBookBy(
      d.delta,
      heatingDistanceX: d.delta.dx.abs() / scale,
    );
  }

  void _onMacroDragEnd(DragEndDetails d) {
    if (_macroDragging && widget.enableAudio) _audio?.playSimpleDrop();
    _macroDragging = false;
  }

  // Magnifier: 1:1 model coordinates (same property as macro book).
  void _onMagDragStart(DragStartDetails d) {
    _focusNode.requestFocus();
    _magDragging = true;
    _model.hideHint();
    if (widget.enableAudio) _audio?.playHarpPickup();
  }

  void _onMagDragUpdate(DragUpdateDetails d) {
    if (!_magDragging) return;
    _model.moveTopBookBy(d.delta);
  }

  void _onMagDragEnd(DragEndDetails d) {
    if (_magDragging && widget.enableAudio) _audio?.playHarpDrop();
    _magDragging = false;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    final tracked = {
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyD,
    };
    if (!tracked.contains(key)) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      _keysDown.add(key);
      return KeyEventResult.handled;
    }
    if (event is KeyUpEvent) {
      _keysDown.remove(key);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final bookPos = _model.topBookPosition;
    final scale = _model.bookDraggingScaleFactor;
    final topBookView = FrictionConstants.topBookOrigin +
        Offset(bookPos.dx * scale, bookPos.dy * scale);

    final thermoSize = FrictionThermometerPainter.intrinsicSize;
    final bulb = FrictionConstants.thermometerBulbCenter;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sx = constraints.maxWidth / FrictionConstants.layoutWidth;
          final sy = constraints.maxHeight / FrictionConstants.layoutHeight;
          final s = math.min(sx, sy);

          return Center(
            child: SizedBox(
              width: FrictionConstants.layoutWidth * s,
              height: FrictionConstants.layoutHeight * s,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: FrictionConstants.layoutWidth,
                  height: FrictionConstants.layoutHeight,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Magnifier (drag top microscopic layer)
                        Positioned(
                          left: FrictionConstants.magnifierOrigin.dx,
                          top: FrictionConstants.magnifierOrigin.dy,
                          child: _MagnifierWindow(
                            model: _model,
                            onPanStart: _onMagDragStart,
                            onPanUpdate: _onMagDragUpdate,
                            onPanEnd: _onMagDragEnd,
                          ),
                        ),

                        // Zoom dashed lines
                        Positioned(
                          left: FrictionConstants.magnifierOrigin.dx,
                          top: FrictionConstants.magnifierOrigin.dy,
                          child: IgnorePointer(
                            child: CustomPaint(
                              size: Size(
                                FrictionConstants.magnifierWindowWidth,
                                FrictionConstants.layoutHeight -
                                    FrictionConstants.magnifierOrigin.dy,
                              ),
                              painter: MagnifierTargetPainter(
                                targetX: FrictionConstants.magnifierTargetX -
                                    FrictionConstants.magnifierOrigin.dx,
                                targetY: FrictionConstants.magnifierTargetY -
                                    FrictionConstants.magnifierOrigin.dy,
                              ),
                            ),
                          ),
                        ),

                        // Thermometer
                        Positioned(
                          left: bulb.dx - thermoSize.width / 2,
                          top: bulb.dy -
                              (FrictionConstants.thermometerTubeHeight +
                                  FrictionConstants.thermometerBulbDiameter /
                                      2),
                          child: IgnorePointer(
                            child: FrictionThermometer(
                              temperature: _model.vibrationAmplitude,
                            ),
                          ),
                        ),

                        // Physics book (fixed)
                        Positioned(
                          left: FrictionConstants.bottomBookOrigin.dx,
                          top: FrictionConstants.bottomBookOrigin.dy -
                              BookCoverPainter.topExtent,
                          child: PhysicsBookCover(),
                        ),

                        // Chemistry book — same model as magnifier drag
                        Positioned(
                          left: topBookView.dx,
                          top: topBookView.dy - BookCoverPainter.topExtent,
                          child: Semantics(
                            label: FrictionStrings.chemistryBook,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: _onMacroDragStart,
                              onPanUpdate: _onMacroDragUpdate,
                              onPanEnd: _onMacroDragEnd,
                              onPanCancel: () => _macroDragging = false,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: ChemistryBookCover(),
                              ),
                            ),
                          ),
                        ),

                        // Reset All
                        Positioned(
                          left: FrictionConstants.layoutWidth * 0.94 -
                              FrictionConstants.resetAllRadius,
                          top: FrictionConstants.layoutHeight * 0.9 -
                              FrictionConstants.resetAllRadius,
                          child: KratosResetAllButton(
                            onPressed: _reset,
                            radius: FrictionConstants.resetAllRadius,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MagnifierWindow extends StatelessWidget {
  const _MagnifierWindow({
    required this.model,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final FrictionModel model;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  static const double w = FrictionConstants.magnifierWindowWidth;
  static const double h = FrictionConstants.magnifierWindowHeight;
  static const double round = FrictionConstants.magnifierCornerRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: FrictionStrings.zoomedInChemistryBook,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(round),
                  child: CustomPaint(
                    size: const Size(w, h),
                    painter: MagnifierContentPainter(model: model),
                  ),
                ),
                // Hint arrows (top center)
                if (model.hint)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 8,
                    height: 50,
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: MagnifierHintArrowsPainter(),
                      ),
                    ),
                  ),
                IgnorePointer(
                  child: Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(round),
                      border: Border.all(color: Colors.black, width: 5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
