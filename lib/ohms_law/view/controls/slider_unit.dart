import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/ohms_law_constants.dart';
import '../../model/ohms_law_property.dart';
import '../../ohms_law_view_constants.dart';

/// PhET `SliderUnit` — vertical PhET-style slider + keyboard (source VSlider).
///
/// Header matches source packing: name sits under the symbol (`name.centerY ≈
/// symbol.y + 18`), not a tall Column — keeps ControlPanel short enough that
/// Units (aligned to wireBox.centerY) do not collide with slider readouts.
class SliderUnit extends StatefulWidget {
  const SliderUnit({
    super.key,
    required this.property,
    required this.range,
    required this.symbol,
    required this.name,
    required this.unit,
    required this.decimalPlaces,
    this.semanticLabel,
    this.keyboardStep = 1,
    this.shiftKeyboardStep = 0.1,
    this.focusNode,
  });

  final NumberProperty property;
  final OhmsLawRange range;
  final String symbol;
  final String name;
  final String unit;
  final int decimalPlaces;
  final String? semanticLabel;

  /// Source `keyboardStep` (V: 0.5, R: 20).
  final double keyboardStep;

  /// Source `shiftKeyboardStep` (V default 0.1, R: 1).
  final double shiftKeyboardStep;

  final FocusNode? focusNode;

  @override
  State<SliderUnit> createState() => _SliderUnitState();
}

class _SliderUnitState extends State<SliderUnit> {
  bool _highlight = false;
  late final FocusNode _focus;
  late final bool _ownsFocus;

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
    widget.property.value = toFixedNumber(raw, widget.decimalPlaces);
  }

  void _setFromLocalY(double localY, double trackHeight) {
    final thumbH = OhmsLawViewConstants.thumbSize.height;
    final usable = trackHeight - thumbH;
    final y = (localY - thumbH / 2).clamp(0.0, usable);
    final t = 1.0 - (usable <= 0 ? 0.0 : y / usable);
    final raw = widget.range.min + t * widget.range.length;
    _applyRaw(raw);
  }

  void _nudge(double delta) {
    _applyRaw(widget.property.value + delta);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final step =
        shift ? widget.shiftKeyboardStep : widget.keyboardStep;
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
      _applyRaw(widget.range.min);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _applyRaw(widget.range.max);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final valueText = toFixed(widget.property.value, widget.decimalPlaces);
    final label = widget.semanticLabel ?? widget.name;
    // Source SliderUnit column width ≈ SLIDER_WIDTH (89); thumb is 45.
    const columnW = OhmsLawViewConstants.sliderWidth;

    return SizedBox(
      width: columnW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Source: nameText.center = (symbol.centerX, symbol.y + 18)
          SizedBox(
            width: columnW,
            height: OhmsLawViewConstants.sliderHeaderHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Text(
                  widget.symbol,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: OhmsLawViewConstants.fontFamily,
                    fontSize: OhmsLawViewConstants.symbolFontSize,
                    color: OhmsLawViewConstants.blue,
                    height: 1,
                  ),
                ),
                Positioned(
                  top: OhmsLawViewConstants.sliderNameTop,
                  left: 0,
                  right: 0,
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: OhmsLawViewConstants.uiFontFamily,
                      fontSize: OhmsLawViewConstants.nameFontSize,
                      color: OhmsLawViewConstants.blue,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: OhmsLawViewConstants.sliderHeight,
            width: OhmsLawViewConstants.thumbSize.width + 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackH = constraints.maxHeight;
                final thumbH = OhmsLawViewConstants.thumbSize.height;
                final usable = trackH - thumbH;
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
                      widget.decimalPlaces,
                    ),
                    decreasedValue: toFixed(
                      (widget.property.value - widget.keyboardStep)
                          .clamp(widget.range.min, widget.range.max),
                      widget.decimalPlaces,
                    ),
                    onIncrease: () => _nudge(widget.keyboardStep),
                    onDecrease: () => _nudge(-widget.keyboardStep),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) {
                        _focus.requestFocus();
                        setState(() => _highlight = true);
                        _setFromLocalY(d.localPosition.dy, trackH);
                      },
                      onTapUp: (_) => setState(() => _highlight = false),
                      onTapCancel: () => setState(() => _highlight = false),
                      onVerticalDragStart: (d) {
                        _focus.requestFocus();
                        setState(() => _highlight = true);
                        _setFromLocalY(d.localPosition.dy, trackH);
                      },
                      onVerticalDragUpdate: (d) {
                        _setFromLocalY(d.localPosition.dy, trackH);
                      },
                      onVerticalDragEnd: (_) =>
                          setState(() => _highlight = false),
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, trackH),
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
          const SizedBox(height: 5),
          // Source UNIT_MAX_WIDTH 45 — keep value+unit inside columnW.
          SizedBox(
            width: columnW,
            height: OhmsLawViewConstants.readoutFontSize,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    valueText,
                    style: TextStyle(
                      fontFamily: OhmsLawViewConstants.uiFontFamily,
                      fontSize: OhmsLawViewConstants.readoutFontSize,
                      color: OhmsLawViewConstants.black,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: OhmsLawViewConstants.unitMaxWidth,
                    ),
                    child: Text(
                      widget.unit,
                      style: TextStyle(
                        fontFamily: OhmsLawViewConstants.uiFontFamily,
                        fontSize: OhmsLawViewConstants.unitFontSize,
                        color: OhmsLawViewConstants.blue,
                        height: 1,
                      ),
                    ),
                  ),
                ],
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
    final trackW = OhmsLawViewConstants.trackSize.width;
    final thumbW = OhmsLawViewConstants.thumbSize.width;
    final thumbH = OhmsLawViewConstants.thumbSize.height;

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
            ? OhmsLawViewConstants.thumbFillHighlighted
            : OhmsLawViewConstants.thumbFill,
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
