import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// PhET `BeakerSteamCanvasNode` — steam column above liquid surface.
///
/// Local coords: beaker Size(w,h) with Y-down; fluid top at `h*(1-fluidProportion)`.
/// Steam rises (decreasing y). Overflow above beaker is intentional (`Clip.none`).
class BeakerSteamOverlay extends StatefulWidget {
  const BeakerSteamOverlay({
    super.key,
    required this.beaker,
    required this.width,
    required this.height,
  });

  final Beaker beaker;
  final double width;
  final double height;

  @override
  State<BeakerSteamOverlay> createState() => _BeakerSteamOverlayState();
}

class _SteamBubble {
  _SteamBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });

  double x;
  double y;
  double radius;
  double opacity;
}

class _BeakerSteamOverlayState extends State<BeakerSteamOverlay>
    with SingleTickerProviderStateMixin {
  static const double steamingRange = 10;
  static const double bubbleSpeedMin = 100;
  static const double bubbleSpeedMax = 125;
  static const double bubbleDiaMin = 20;
  static const double bubbleDiaMax = 50;
  static const double maxSteamHeight = 300;
  static const double bubbleRateMin = 20;
  static const double bubbleRateMax = 40;
  static const double bubbleGrowthRate = 0.2;
  static const double maxOpacity = 0.7;

  final List<_SteamBubble> _bubbles = [];
  double _remainder = 0;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  final math.Random _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _preload();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant BeakerSteamOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beaker.temperature <
            oldWidget.beaker.fluidBoilingPoint - steamingRange &&
        widget.beaker.temperature >=
            widget.beaker.fluidBoilingPoint - steamingRange) {
      _preload();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _steamOriginY {
    // PhET: steamOrigin = containerOutlineRect.minY * fluidProportion
    // with minY = -h → Flutter fluidTop = h * (1 - fluidProportion)
    return widget.height * (1 - widget.beaker.fluidProportion);
  }

  void _preload() {
    _bubbles.clear();
    _remainder = 0;
    if (widget.beaker.temperature <
        widget.beaker.fluidBoilingPoint - steamingRange) {
      return;
    }
    // BeakerSteamCanvasNode.preloadSteam — run until a bubble exits.
    final dt = 1 / EfacConstants.framesPerSecond;
    var guard = 0;
    var complete = false;
    while (!complete && guard++ < 600) {
      complete = _step(dt, markCompleteOnExit: true);
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = _last == Duration.zero
        ? 1 / EfacConstants.framesPerSecond
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.25) return;
    final before = _bubbles.length;
    _step(dt.clamp(0.0, 0.05));
    if (_bubbles.isNotEmpty || before > 0) {
      setState(() {});
    }
  }

  /// Returns true when a bubble exited (preloadComplete signal).
  bool _step(double dt, {bool markCompleteOnExit = false}) {
    final boiling = widget.beaker.fluidBoilingPoint;
    final temp = widget.beaker.temperature;
    var steamingProportion = 0.0;
    var exited = false;

    if (boiling - temp < steamingRange) {
      steamingProportion =
          (1 - (boiling - temp) / steamingRange).clamp(0.0, 1.0);
      final rate = bubbleRateMin +
          (bubbleRateMax - bubbleRateMin) * steamingProportion;
      var toProduce = (rate * dt).floor();
      _remainder += rate * dt - toProduce;
      if (_remainder >= 1) {
        toProduce += _remainder.floor();
        _remainder -= _remainder.floor();
      }
      final originY = _steamOriginY;
      for (var i = 0; i < toProduce; i++) {
        final dia =
            bubbleDiaMin + _rng.nextDouble() * (bubbleDiaMax - bubbleDiaMin);
        final x = widget.width / 2 +
            (_rng.nextDouble() - 0.5) * (widget.width - dia);
        _bubbles.add(_SteamBubble(
          x: x,
          y: originY,
          radius: dia / 2,
          opacity: 0,
        ));
      }
    }

    final speed = bubbleSpeedMin +
        steamingProportion * (bubbleSpeedMax - bubbleSpeedMin);
    final unfilledBeakerHeight =
        widget.height * (1 - widget.beaker.fluidProportion);

    for (var i = _bubbles.length - 1; i >= 0; i--) {
      final b = _bubbles[i];
      b.y -= dt * speed;
      if (b.y < 0) {
        b.radius = b.radius * (1 + bubbleGrowthRate * dt);
        final distFromCenterX = b.x - widget.width / 2;
        b.x += distFromCenterX * 0.2 * dt;
        final heightFraction = ((0 - b.y) / maxSteamHeight).clamp(0.0, 1.0);
        b.opacity = (1 - heightFraction) * maxOpacity;
      } else {
        final distanceFromWater = _steamOriginY - b.y;
        final opacityFraction = (distanceFromWater /
                (unfilledBeakerHeight / 4).clamp(1e-6, double.infinity))
            .clamp(0.0, 1.0);
        b.opacity = opacityFraction * maxOpacity;
      }
      if (0 - b.y > maxSteamHeight) {
        _bubbles.removeAt(i);
        exited = true;
      }
    }
    return markCompleteOnExit ? exited : false;
  }

  Color get _steamColor => widget.beaker.beakerType == BeakerType.water
      ? EfacColors.waterSteam
      : EfacColors.oliveOilSteam;

  @override
  Widget build(BuildContext context) {
    if (_bubbles.isEmpty &&
        widget.beaker.temperature <
            widget.beaker.fluidBoilingPoint - steamingRange) {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: _SteamPainter(bubbles: List.of(_bubbles), color: _steamColor),
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter({required this.bubbles, required this.color});

  final List<_SteamBubble> bubbles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      if (b.opacity <= 0) continue;
      canvas.drawCircle(
        Offset(b.x, b.y),
        b.radius,
        Paint()..color = color.withValues(alpha: b.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SteamPainter oldDelegate) => true;
}
