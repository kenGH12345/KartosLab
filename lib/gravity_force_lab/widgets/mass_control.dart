import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../a11y/gfl_a11y_strings.dart';
import '../a11y/gfl_keyboard_actions.dart';
import '../audio/gfl_audio.dart';
import '../gfl_colors.dart';
import '../gfl_strings.dart';
import '../model/gravity_force_constants.dart';
import '../model/gravity_force_lab_model.dart';

/// PhET `MassControl` / NumberControl — mass value AccessibleSlider (Full).
///
/// Full keyboard: Left/Right (±50), Shift+Left/Right (±10), Page (±100),
/// Home/End → min/max. (Basics uses Up/Down; Full uses Left/Right.)
class MassControlPanel extends StatelessWidget {
  const MassControlPanel({
    super.key,
    required this.model,
    required this.which,
    required this.title,
    required this.accent,
    this.audio,
    this.focusOrder,
  });

  final GravityForceLabModel model;
  final int which;
  final String title;
  final Color accent;
  final GflAudio? audio;
  final double? focusOrder;

  double get _value => which == 1 ? model.mass1.value : model.mass2.value;

  String get _a11yName =>
      which == 1 ? GflA11yStrings.mass1 : GflA11yStrings.mass2;

  void _setMass(double next) {
    final previous = _value;
    model.setMassValue(which, next);
    final after = _value;
    if (after != previous) {
      audio?.onMassValueChanged(which, after, previous);
    }
  }

  void _nudge({required bool increase, required bool page}) {
    final previous = _value;
    GflKeyboardActions.applyMassStep(
      model,
      which,
      increase: increase,
      page: page,
    );
    final after = _value;
    if (after != previous) {
      audio?.onMassValueChanged(which, after, previous);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    // Full MassControl: left/right (Basics uses up/down).
    if (key == LogicalKeyboardKey.arrowRight) {
      _nudge(increase: true, page: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _nudge(increase: false, page: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      _nudge(increase: true, page: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      _nudge(increase: false, page: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      final previous = _value;
      GflKeyboardActions.jumpMassMin(model, which);
      final after = _value;
      if (after != previous) {
        audio?.onMassValueChanged(which, after, previous);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      final previous = _value;
      GflKeyboardActions.jumpMassMax(model, which);
      final after = _value;
      if (after != previous) {
        audio?.onMassValueChanged(which, after, previous);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final v = _value;
    final panel = Focus(
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        label: _a11yName,
        value: GflA11yStrings.massAndUnit(v),
        increasedValue: GflA11yStrings.massAndUnit(
          (v + GravityForceConstants.massKeyboardStep).clamp(
            GravityForceConstants.massMin,
            GravityForceConstants.massMax,
          ),
        ),
        decreasedValue: GflA11yStrings.massAndUnit(
          (v - GravityForceConstants.massKeyboardStep).clamp(
            GravityForceConstants.massMin,
            GravityForceConstants.massMax,
          ),
        ),
        onIncrease: () => _nudge(increase: true, page: false),
        onDecrease: () => _nudge(increase: false, page: false),
        child: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Focus.of(context).requestFocus(),
              child: ExcludeSemantics(
                child: Container(
                  width: 168,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                  decoration: BoxDecoration(
                    color: GflColors.panelFill,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _ArrowStepButton(
                            key: ValueKey('mass${which}_dec'),
                            pointingRight: false,
                            onPressed: () => _setMass(v - 10),
                          ),
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.black38),
                              ),
                              child: Text(
                                '${v.round()} ${GflStrings.unitsKg}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          _ArrowStepButton(
                            key: ValueKey('mass${which}_inc'),
                            pointingRight: true,
                            onPressed: () => _setMass(v + 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 28,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2.5,
                            thumbShape: const _VerticalRectThumb(
                              width: 10,
                              height: 18,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12),
                            activeTrackColor: Colors.black87,
                            inactiveTrackColor: Colors.black87,
                            thumbColor:
                                Color.lerp(accent, Colors.white, 0.12),
                            trackShape: const RoundedRectSliderTrackShape(),
                          ),
                          child: Slider(
                            min: GravityForceConstants.massMin,
                            max: GravityForceConstants.massMax,
                            divisions: ((GravityForceConstants.massMax -
                                        GravityForceConstants.massMin) /
                                    GravityForceConstants
                                        .massSliderInterval)
                                .round(),
                            value: v.clamp(
                              GravityForceConstants.massMin,
                              GravityForceConstants.massMax,
                            ),
                            onChangeStart: (_) => audio
                                ?.setMassSliderDraggingViaPointer(true),
                            onChanged: _setMass,
                            onChangeEnd: (_) => audio
                                ?.setMassSliderDraggingViaPointer(false),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${GravityForceConstants.massMin.round()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            '${GravityForceConstants.massMax.round()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    if (focusOrder == null) return panel;
    return FocusTraversalOrder(
      order: NumericFocusOrder(focusOrder!),
      child: panel,
    );
  }
}

class _ArrowStepButton extends StatelessWidget {
  const _ArrowStepButton({
    super.key,
    required this.pointingRight,
    required this.onPressed,
  });

  final bool pointingRight;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: const Color(0xFFE8E8E8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.black38),
        ),
        child: InkWell(
          onTap: onPressed,
          child: CustomPaint(
            painter: _TrianglePainter(pointingRight: pointingRight),
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.pointingRight});

  final bool pointingRight;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const halfH = 6.0;
    const halfW = 5.0;
    final path = Path();
    if (pointingRight) {
      path
        ..moveTo(cx - halfW, cy - halfH)
        ..lineTo(cx + halfW, cy)
        ..lineTo(cx - halfW, cy + halfH)
        ..close();
    } else {
      path
        ..moveTo(cx + halfW, cy - halfH)
        ..lineTo(cx - halfW, cy)
        ..lineTo(cx + halfW, cy + halfH)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.pointingRight != pointingRight;
}

/// PhET NumberControl slider thumb ≈ vertical rounded rect (not Material circle).
class _VerticalRectThumb extends SliderComponentShape {
  const _VerticalRectThumb({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = sliderTheme.thumbColor ?? Colors.blue,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
