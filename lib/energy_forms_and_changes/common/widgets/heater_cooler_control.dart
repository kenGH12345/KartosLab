import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';

/// Which part of scenery-phet HeaterCooler to paint.
///
/// PhET splits layers so stand / beakerBack / blocks can sit between:
/// - [HeaterCoolerPaintLayer.back] — opening ellipse (`HeaterCoolerBack`)
/// - [HeaterCoolerPaintLayer.front] — stove body + VSlider + flame/ice composite
///
/// Flame/ice follow `HeaterCoolerBack` translation math but paint on front so the
/// opaque Flutter body Path cannot cover them (PhET Path leaves the bowl open).
enum HeaterCoolerPaintLayer { back, front }

/// scenery-phet `HeaterCoolerBack` + `HeaterCoolerFront` geometry.
///
/// Heat (>0) → flame rises; Cool (<0) → ice rises — both from the opening (PhET).
/// Pixel fidelity of flame/ice assets remains `[BLOCKED D]`.
class HeaterCoolerNode extends StatelessWidget {
  const HeaterCoolerNode({
    super.key,
    required this.value,
    required this.onChanged,
    this.stoveWidth = 120,
    this.snapToZero = true,
    this.coolEnabled = true,
    this.layer = HeaterCoolerPaintLayer.front,
  });

  /// HeatCool level in [-1, 1], or [0, 1] when [coolEnabled] is false.
  final double value;
  final ValueChanged<double> onChanged;

  /// Screen-coord width; EFAC uses burnerStand.width / 1.5 (node scale).
  final double stoveWidth;
  final bool snapToZero;

  /// When false (TeaKettle): slider 0..1, Heat label only, flame never ice.
  final bool coolEnabled;
  final HeaterCoolerPaintLayer layer;

  static const Color defaultBaseColor = Color.fromARGB(255, 159, 182, 205);
  static const double openingHeightScale = 0.1;
  static const double defaultWidth = 120;

  double get _openingH => stoveWidth * openingHeightScale;
  double get _bodyH => stoveWidth * 0.75;
  double get _bottomW => stoveWidth * 0.80;
  double get _frontPaintH => _bodyH + _openingH;
  double get _totalH => _bodyH + _openingH + 8;
  double get _s => stoveWidth / defaultWidth;

  /// Left-center of stove opening — `HeaterCoolerBack.getHeaterFrontPosition`.
  Offset get heaterFrontLocalOrigin => Offset(0, _openingH / 2);

  @override
  Widget build(BuildContext context) {
    final height = layer == HeaterCoolerPaintLayer.back ? _openingH : _totalH;
    return SizedBox(
      width: stoveWidth,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (layer == HeaterCoolerPaintLayer.back) ..._backChildren(),
          if (layer == HeaterCoolerPaintLayer.front) ..._frontChildren(),
        ],
      ),
    );
  }

  /// Native PNG sizes (scenery-phet images).
  static const double _flameNativeW = 88;
  static const double _flameNativeH = 84;
  static const double _iceNativeW = 99;
  static const double _iceNativeH = 79;

  List<Widget> _heatCoolEffects({required double yOffset}) {
    // HeaterCoolerBack.ts setTranslation after top=stoveInterior.bottom:
    //   heat: y = -amount * flameH * 0.85
    //   cool: y =  amount * iceH * 0.85  (negative → rises from opening)
    final flameH = _flameNativeH * _s;
    final flameW = _flameNativeW * _s;
    final iceH = _iceNativeH * _s;
    final iceW = _iceNativeW * _s;
    final heatAmount = coolEnabled ? value : value.clamp(0.0, 1.0);
    return [
      if (heatAmount > 0.02)
        Positioned(
          left: (stoveWidth - flameW) / 2,
          top: yOffset - heatAmount * flameH * 0.85,
          width: flameW,
          height: flameH,
          child: Image.asset(
            EfacAssets.flame,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
        ),
      if (coolEnabled && value < -0.02)
        Positioned(
          left: (stoveWidth - iceW) / 2,
          top: yOffset + value * iceH * 0.85,
          width: iceW,
          height: iceH,
          child: Image.asset(
            EfacAssets.iceCubeStack,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
        ),
    ];
  }

  List<Widget> _backChildren() {
    // Opening ellipse only on back (flame/ice composited on front so opaque
    // body Path cannot cover them — Flutter Path fill has no hollow top).
    return [
      Positioned(
        left: 0,
        top: 0,
        child: CustomPaint(
          size: Size(stoveWidth, _openingH),
          painter: _StoveOpeningPainter(base: defaultBaseColor),
        ),
      ),
    ];
  }

  List<Widget> _frontChildren() {
    // HeaterCoolerFront.ts — body + VSlider at centerY: body.centerY,
    // right: body.right - width/8. EFAC thumbSize 36×18.
    final bodyCenterY = _frontPaintH / 2;
    final effectY0 = -_openingH / 2;
    final trackH = stoveWidth / 2;
    final thumbW = 36.0 * _s;
    final thumbH = 18.0 * _s;
    final labelW = 35.0 * _s;
    final tickLen = 15.0 * _s;
    final sliderW = labelW + tickLen + math.max(thumbW, 10.0 * _s) + 4;
    final sliderH = trackH + thumbH;

    return [
      Positioned(
        left: 0,
        top: 0,
        child: CustomPaint(
          size: Size(stoveWidth, _frontPaintH),
          painter: _StoveBodyPainter(
            base: defaultBaseColor,
            stoveWidth: stoveWidth,
            bodyHeight: _bodyH,
            bottomWidth: _bottomW,
            openingH: _openingH,
          ),
        ),
      ),
      ..._heatCoolEffects(yOffset: effectY0),
      Positioned(
        left: stoveWidth - stoveWidth / 8 - sliderW,
        top: bodyCenterY - sliderH / 2,
        width: sliderW,
        height: sliderH,
        child: _HeaterCoolerVSlider(
          value: coolEnabled ? value.clamp(-1.0, 1.0) : value.clamp(0.0, 1.0),
          onChanged: onChanged,
          snapToZero: snapToZero,
          coolEnabled: coolEnabled,
          scale: _s,
          trackHeight: trackH,
          thumbSize: Size(thumbW, thumbH),
          labelWidth: labelW,
          tickLength: tickLen,
        ),
      ),
    ];
  }
}

/// PhET `VSlider` stand-in for HeaterCoolerFront (gradient track + cyan thumb).
///
/// Evidence `HeaterCoolerFront.ts` defaults:
/// - trackFillEnabled: LinearGradient cool `#0A00F0` → heat `#EF000F`
/// - trackSize: 10 × (width/2); thumbFill `#71edff`; thumbCenterLineStroke black
class _HeaterCoolerVSlider extends StatefulWidget {
  const _HeaterCoolerVSlider({
    required this.value,
    required this.onChanged,
    required this.snapToZero,
    required this.coolEnabled,
    required this.scale,
    required this.trackHeight,
    required this.thumbSize,
    required this.labelWidth,
    required this.tickLength,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final bool snapToZero;
  final bool coolEnabled;
  final double scale;
  final double trackHeight;
  final Size thumbSize;
  final double labelWidth;
  final double tickLength;

  static const Color _cool = Color(0xFF0A00F0);
  static const Color _heat = Color(0xFFEF000F);
  static const Color _thumb = Color(0xFF71EDFF);

  @override
  State<_HeaterCoolerVSlider> createState() => _HeaterCoolerVSliderState();
}

class _HeaterCoolerVSliderState extends State<_HeaterCoolerVSlider> {
  late double _live;

  @override
  void initState() {
    super.initState();
    _live = widget.value;
  }

  @override
  void didUpdateWidget(covariant _HeaterCoolerVSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _live = widget.value;
  }

  double get _trackW => (10 * widget.scale).clamp(8, 12);

  /// coolEnabled: top=+1 Heat, bottom=−1 Cool.
  /// heat-only: top=1 Heat, bottom=0.
  double _valueFromLocalY(double localY) {
    final t =
        ((localY - widget.thumbSize.height / 2) / widget.trackHeight)
            .clamp(0.0, 1.0);
    if (widget.coolEnabled) return 1.0 - 2.0 * t;
    return 1.0 - t;
  }

  double _thumbCenterY() {
    if (widget.coolEnabled) {
      return widget.thumbSize.height / 2 +
          (1.0 - _live) / 2.0 * widget.trackHeight;
    }
    return widget.thumbSize.height / 2 + (1.0 - _live) * widget.trackHeight;
  }

  void _applyLocalY(double localY) {
    final v = _valueFromLocalY(localY);
    setState(() => _live = v);
    widget.onChanged(v);
  }

  void _endDrag() {
    if (widget.snapToZero && _live.abs() < 0.1) {
      setState(() => _live = 0);
      widget.onChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: (14 * widget.scale).clamp(10, 14),
      color: Colors.black,
      height: 1,
    );
    final totalH = widget.trackHeight + widget.thumbSize.height;
    final trackLeft = widget.labelWidth + widget.tickLength;
    final trackCenterX = trackLeft + widget.thumbSize.width / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragDown: (d) => _applyLocalY(d.localPosition.dy),
      onVerticalDragUpdate: (d) => _applyLocalY(d.localPosition.dy),
      onVerticalDragEnd: (_) => _endDrag(),
      onTapUp: (d) {
        _applyLocalY(d.localPosition.dy);
        _endDrag();
      },
      child: SizedBox(
        width: trackLeft + widget.thumbSize.width,
        height: totalH,
        child: CustomPaint(
          painter: _HeaterCoolerVSliderPainter(
            value: _live,
            coolEnabled: widget.coolEnabled,
            trackHeight: widget.trackHeight,
            trackWidth: _trackW,
            thumbSize: widget.thumbSize,
            labelWidth: widget.labelWidth,
            tickLength: widget.tickLength,
            trackCenterX: trackCenterX,
            thumbCenterY: _thumbCenterY(),
            labelStyle: labelStyle,
          ),
        ),
      ),
    );
  }
}

class _HeaterCoolerVSliderPainter extends CustomPainter {
  _HeaterCoolerVSliderPainter({
    required this.value,
    required this.coolEnabled,
    required this.trackHeight,
    required this.trackWidth,
    required this.thumbSize,
    required this.labelWidth,
    required this.tickLength,
    required this.trackCenterX,
    required this.thumbCenterY,
    required this.labelStyle,
  });

  final double value;
  final bool coolEnabled;
  final double trackHeight;
  final double trackWidth;
  final Size thumbSize;
  final double labelWidth;
  final double tickLength;
  final double trackCenterX;
  final double thumbCenterY;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final trackTop = thumbSize.height / 2;
    final trackBottom = trackTop + trackHeight;
    final trackRect = Rect.fromCenter(
      center: Offset(trackCenterX, (trackTop + trackBottom) / 2),
      width: trackWidth,
      height: trackHeight,
    );

    // coolEnabled: red(top)→blue(bottom); heat-only: red→lighter red.
    final trackR = RRect.fromRectAndRadius(trackRect, const Radius.circular(2));
    final colors = coolEnabled
        ? const [
            _HeaterCoolerVSlider._heat,
            _HeaterCoolerVSlider._cool,
          ]
        : const [
            _HeaterCoolerVSlider._heat,
            Color(0xFFFFAAAA),
          ];
    canvas.drawRRect(
      trackR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(trackRect),
    );
    canvas.drawRRect(
      trackR,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Major ticks + Heat [/ Cool] labels (left of track).
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.2;
    final heatTp = TextPainter(
      text: TextSpan(text: 'Heat', style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: labelWidth);
    heatTp.paint(canvas, Offset(0, trackTop - heatTp.height / 2));

    if (coolEnabled) {
      final coolTp = TextPainter(
        text: TextSpan(text: 'Cool', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: labelWidth);
      coolTp.paint(canvas, Offset(0, trackBottom - coolTp.height / 2));
    }

    final tickX0 = labelWidth;
    final tickX1 = trackRect.left;
    canvas.drawLine(Offset(tickX0, trackTop), Offset(tickX1, trackTop), tickPaint);
    canvas.drawLine(
      Offset(tickX0, trackBottom),
      Offset(tickX1, trackBottom),
      tickPaint,
    );
    if (coolEnabled) {
      // Zero minor tick (PhET addMinorTick(0)).
      final midY = (trackTop + trackBottom) / 2;
      canvas.drawLine(
        Offset(tickX1 - tickLength * 0.75, midY),
        Offset(tickX1, midY),
        tickPaint,
      );
    }

    // Cyan capsule thumb + center hairline (thumbCenterLineStroke).
    final thumbRect = Rect.fromCenter(
      center: Offset(trackCenterX, thumbCenterY),
      width: thumbSize.width,
      height: thumbSize.height,
    );
    final thumbRRect =
        RRect.fromRectAndRadius(thumbRect, const Radius.circular(4));
    canvas.drawRRect(
      thumbRRect,
      Paint()..color = _HeaterCoolerVSlider._thumb,
    );
    canvas.drawRRect(
      thumbRRect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      Offset(thumbRect.left + 3, thumbCenterY),
      Offset(thumbRect.right - 3, thumbCenterY),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _HeaterCoolerVSliderPainter old) =>
      old.value != value ||
      old.coolEnabled != coolEnabled ||
      old.trackHeight != trackHeight ||
      old.thumbCenterY != thumbCenterY;
}

class _StoveOpeningPainter extends CustomPainter {
  _StoveOpeningPainter({required this.base});
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 4),
      width: size.width,
      height: size.height,
    );
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(base, Colors.black, 0.5)!,
          Color.lerp(base, Colors.white, 0.5)!,
        ],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoveBodyPainter extends CustomPainter {
  _StoveBodyPainter({
    required this.base,
    required this.stoveWidth,
    required this.bodyHeight,
    required this.bottomWidth,
    required this.openingH,
  });

  final Color base;
  final double stoveWidth;
  final double bodyHeight;
  final double bottomWidth;
  final double openingH;

  @override
  void paint(Canvas canvas, Size size) {
    final w = stoveWidth;
    final h = bodyHeight;
    final oh = openingH;
    final bw = bottomWidth;

    final path = Path()
      ..moveTo(w, oh / 4)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(w / 2, oh / 4),
          width: w,
          height: oh,
        ),
        0,
        math.pi,
        false,
      )
      ..lineTo((w - bw) / 2, h + oh / 2)
      // HeaterCoolerFront.ts: ellipticalArc(..., bottomWidth/2, burnerOpeningHeight, ...)
      // → ellipse height = openingH (not 2×).
      ..arcTo(
        Rect.fromCenter(
          center: Offset(w / 2, h + oh / 4),
          width: bw,
          height: oh,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..lineTo(w, oh / 2)
      ..close();

    final bounds = Rect.fromLTWH(0, 0, w, h + oh);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(base, Colors.white, 0.5)!,
            Color.lerp(base, Colors.black, 0.5)!,
          ],
        ).createShader(bounds),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _StoveBodyPainter oldDelegate) =>
      oldDelegate.stoveWidth != stoveWidth ||
      oldDelegate.bodyHeight != bodyHeight ||
      oldDelegate.bottomWidth != bottomWidth ||
      oldDelegate.openingH != openingH;
}

typedef HeaterCoolerControl = HeaterCoolerNode;
