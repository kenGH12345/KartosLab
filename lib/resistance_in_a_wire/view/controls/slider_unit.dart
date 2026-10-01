import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/resistance_in_a_wire_constants.dart';
import '../../model/resistance_in_a_wire_property.dart';
import '../../resistance_in_a_wire_view_constants.dart';

/// PhET `SliderUnit` — vertical PhET-style slider + keyboard.
class SliderUnit extends StatefulWidget {
  const SliderUnit({
    super.key,
    required this.property,
    required this.range,
    required this.symbol,
    required this.name,
    required this.unit,
    this.unitIsRichText = false,
    this.semanticLabel,
    this.keyboardStep = 1,
    this.shiftKeyboardStep = 0.01,
    this.focusNode,
    this.onKeyboardInteraction,
  });

  final NumberProperty property;
  final ResistanceInAWireRange range;
  final String symbol;
  final String name;

  /// Plain unit string, or RichText markup when [unitIsRichText] (e.g. cm²).
  final String unit;
  final bool unitIsRichText;
  final String? semanticLabel;

  /// Source `keyboardStep` (ρ: 0.05, L/A: 1).
  final double keyboardStep;

  /// Source `shiftKeyboardStep` (default 0.01).
  final double shiftKeyboardStep;

  final FocusNode? focusNode;

  /// Marks upcoming property write as keyboard-driven (audio bin contract).
  final VoidCallback? onKeyboardInteraction;

  @override
  State<SliderUnit> createState() => _SliderUnitState();
}

class _SliderUnitState extends State<SliderUnit> {
  bool _highlight = false;
  late final FocusNode _focus;
  late final bool _ownsFocus;

  static const int _decimals =
      ResistanceInAWireConstants.sliderReadoutDecimals;

  @override
  void initState() {
    super.initState();
    _ownsFocus = widget.focusNode == null;
    _focus = widget.focusNode ?? FocusNode(debugLabel: widget.semanticLabel);
  }

  @override
  void dispose() {
    if (_ownsFocus) {
      _focus.dispose();
    }
    super.dispose();
  }

  double get _fraction {
    final r = widget.range;
    return ((widget.property.value - r.min) / r.length).clamp(0.0, 1.0);
  }

  void _applyRaw(double raw) {
    widget.property.value = toFixedNumber(raw, _decimals);
  }

  void _setFromLocalY(double localY, double trackHeight) {
    final thumbH = ResistanceInAWireViewConstants.thumbSize.height;
    final usable = trackHeight - thumbH;
    final y = (localY - thumbH / 2).clamp(0.0, usable);
    final t = 1.0 - (usable <= 0 ? 0.0 : y / usable);
    final raw = widget.range.min + t * widget.range.length;
    _applyRaw(raw);
  }

  void _nudge(double delta) {
    widget.onKeyboardInteraction?.call();
    _applyRaw(widget.property.value + delta);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final step = shift ? widget.shiftKeyboardStep : widget.keyboardStep;
    final page = widget.keyboardStep * 10;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowRight) {
      _nudge(step);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft) {
      _nudge(-step);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      _nudge(page);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      _nudge(-page);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      widget.onKeyboardInteraction?.call();
      _applyRaw(widget.range.min);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      widget.onKeyboardInteraction?.call();
      _applyRaw(widget.range.max);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final valueText = toFixed(widget.property.value, _decimals);
    final label = widget.semanticLabel ?? widget.name;
    const columnW = ResistanceInAWireViewConstants.sliderWidth;
    final trackH = ResistanceInAWireViewConstants.trackSize.height;

    return SizedBox(
      width: columnW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: columnW,
            height: ResistanceInAWireViewConstants.sliderHeaderHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Text(
                  widget.symbol,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ResistanceInAWireViewConstants.fontFamily,
                    fontSize: ResistanceInAWireViewConstants.symbolFontSize,
                    color: ResistanceInAWireViewConstants.blue,
                    height: 1,
                  ),
                ),
                Positioned(
                  top: ResistanceInAWireViewConstants.sliderNameTop,
                  left: 0,
                  right: 0,
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ResistanceInAWireViewConstants.uiFontFamily,
                      fontSize: ResistanceInAWireViewConstants.nameFontSize,
                      color: ResistanceInAWireViewConstants.blue,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: trackH,
            width: ResistanceInAWireViewConstants.thumbSize.width + 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final thumbH = ResistanceInAWireViewConstants.thumbSize.height;
                final usable = h - thumbH;
                final thumbTop = (1.0 - _fraction) * usable;

                return Focus(
                  focusNode: _focus,
                  onKeyEvent: _onKey,
                  child: Semantics(
                    label: label,
                    value: '$valueText ${widget.unit}',
                    slider: true,
                    increasedValue: toFixed(
                      (widget.property.value + widget.keyboardStep)
                          .clamp(widget.range.min, widget.range.max),
                      _decimals,
                    ),
                    decreasedValue: toFixed(
                      (widget.property.value - widget.keyboardStep)
                          .clamp(widget.range.min, widget.range.max),
                      _decimals,
                    ),
                    onIncrease: () => _nudge(widget.keyboardStep),
                    onDecrease: () => _nudge(-widget.keyboardStep),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) {
                        _focus.requestFocus();
                        setState(() => _highlight = true);
                        _setFromLocalY(d.localPosition.dy, h);
                      },
                      onTapUp: (_) => setState(() => _highlight = false),
                      onTapCancel: () => setState(() => _highlight = false),
                      onVerticalDragStart: (d) {
                        _focus.requestFocus();
                        setState(() => _highlight = true);
                        _setFromLocalY(d.localPosition.dy, h);
                      },
                      onVerticalDragUpdate: (d) {
                        _setFromLocalY(d.localPosition.dy, h);
                      },
                      onVerticalDragEnd: (_) =>
                          setState(() => _highlight = false),
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, h),
                        painter: _SliderTrackPainter(
                          thumbTop: thumbTop,
                          highlight: _highlight || _focus.hasFocus,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // PhET Text maxWidth = SLIDER_WIDTH → scale down, never wrap
          // (fixes "10.00" breaking into 10.0 / 0 / cm).
          SizedBox(
            width: columnW,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valueText,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: ResistanceInAWireViewConstants.uiFontFamily,
                  fontSize: ResistanceInAWireViewConstants.readoutFontSize,
                  color: ResistanceInAWireViewConstants.black,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: columnW,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: widget.unitIsRichText
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: widget.unit.replaceAll('²', ''),
                            style: TextStyle(
                              fontFamily:
                                  ResistanceInAWireViewConstants.uiFontFamily,
                              fontSize:
                                  ResistanceInAWireViewConstants.unitFontSize,
                              color: ResistanceInAWireViewConstants.blue,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: '²',
                            style: TextStyle(
                              fontFamily:
                                  ResistanceInAWireViewConstants.uiFontFamily,
                              fontSize: ResistanceInAWireViewConstants
                                      .unitFontSize *
                                  0.7,
                              color: ResistanceInAWireViewConstants.blue,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      widget.unit,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily:
                            ResistanceInAWireViewConstants.uiFontFamily,
                        fontSize:
                            ResistanceInAWireViewConstants.unitFontSize,
                        color: ResistanceInAWireViewConstants.blue,
                        height: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTrackPainter extends CustomPainter {
  _SliderTrackPainter({required this.thumbTop, required this.highlight});

  final double thumbTop;
  final bool highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final trackW = ResistanceInAWireViewConstants.trackSize.width;
    final thumbW = ResistanceInAWireViewConstants.thumbSize.width;
    final thumbH = ResistanceInAWireViewConstants.thumbSize.height;

    final track = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, size.height / 2),
        width: trackW,
        height: size.height,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(track, Paint()..color = Colors.black);

    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - thumbW / 2, thumbTop, thumbW, thumbH),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..color = highlight
            ? ResistanceInAWireViewConstants.thumbFillHighlighted
            : ResistanceInAWireViewConstants.thumbFill,
    );
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF666666)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _SliderTrackPainter oldDelegate) =>
      oldDelegate.thumbTop != thumbTop || oldDelegate.highlight != highlight;
}
