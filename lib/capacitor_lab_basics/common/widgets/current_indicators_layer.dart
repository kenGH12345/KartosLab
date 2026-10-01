import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../clb_colors.dart';
import '../model/circuit_state.dart';
import '../model/clb_model.dart';
import '../render/circuit_render_data.dart';

/// Current flow arrows — `CurrentIndicatorNode.js`
///
/// Tip at origin; default points left. Top startingOrientation=0,
/// bottom = π. Electrons when orientation=0; conventional (proton+) when π.
class CurrentIndicatorsLayer extends StatefulWidget {
  const CurrentIndicatorsLayer({
    super.key,
    required this.model,
    required this.data,
  });

  final ClbModel model;
  final CircuitRenderData data;

  static const double arrowLength = 88;
  static const double headWidth = 30;
  static const double headHeight = 25;
  static const double tailWidth = 0.4 * headWidth;
  static const double indicatorOffset = 7 / 2;
  static const double fadeSeconds = 1.5;

  @override
  State<CurrentIndicatorsLayer> createState() => _CurrentIndicatorsLayerState();
}

class _CurrentIndicatorsLayerState extends State<CurrentIndicatorsLayer>
    with SingleTickerProviderStateMixin {
  double _opacity = 0;
  double _lastNonzeroAmp = 0;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double? _fadeElapsed;

  ClbModel get model => widget.model;
  CircuitRenderData get data => widget.data;

  @override
  void initState() {
    super.initState();
    model.circuit.addListener(_onCurrent);
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    model.circuit.removeListener(_onCurrent);
    _ticker.dispose();
    super.dispose();
  }

  void _onCurrent() {
    final amp = model.circuit.currentAmplitude;
    if (amp != 0) {
      _lastNonzeroAmp = amp;
      _fadeElapsed = 0;
      _opacity = 0.75;
      if (mounted) setState(() {});
    }
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.1) return;
    // PhET: animation.step(dt) only via stepEmitter, which CLBModel emits
    // only when isPlaying || isManual — Pause freezes fade opacity.
    if (!TickerMode.valuesOf(context).enabled) return;
    if (!model.isPlaying) return;
    if (_fadeElapsed == null) return;
    _fadeElapsed = _fadeElapsed! + dt;
    // Quartic in: t^4 from 0.75 → 0 over 1.5s
    final t = (_fadeElapsed! / CurrentIndicatorsLayer.fadeSeconds).clamp(0.0, 1.0);
    final next = 0.75 * (1 - math.pow(t, 4));
    if ((next - _opacity).abs() > 0.01 || t >= 1) {
      setState(() {
        _opacity = next;
        if (t >= 1) {
          _opacity = 0;
          _fadeElapsed = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!model.currentVisible || _opacity <= 0.01) {
      return const SizedBox.shrink();
    }

    final conn = model.circuit.circuitConnection;
    final showBattery = conn == CircuitState.batteryConnected;
    final showBulb = conn == CircuitState.lightBulbConnected &&
        model.circuit.lightBulb != null;
    if (!showBattery && !showBulb) {
      return const SizedBox.shrink();
    }

    final electrons = model.currentOrientation == 0;
    final color = electrons
        ? ClbColors.currentElectronsArrow
        : ClbColors.currentConventionalArrow;

    final children = <Widget>[];
    if (showBattery) {
      children.addAll(_pair(
        top: _batteryTopPos(),
        bottom: _batteryBottomPos(),
        color: color,
        electrons: electrons,
      ));
    }
    if (showBulb) {
      children.addAll(_pair(
        top: _bulbTopPos(),
        bottom: _bulbBottomPos(),
        color: color,
        electrons: electrons,
      ));
    }

    return IgnorePointer(
      child: Opacity(
        key: const ValueKey('clb_current_indicator_opacity'),
        opacity: _opacity.clamp(0.0, 1.0),
        child: Stack(children: children),
      ),
    );
  }

  List<Widget> _pair({
    required Offset top,
    required Offset bottom,
    required Color color,
    required bool electrons,
  }) {
    final flip = _lastNonzeroAmp < 0;
    final orient = model.currentOrientation;
    return [
      _arrowAt(top, starting: 0, orient: orient, flip: flip, color: color, electrons: electrons),
      _arrowAt(bottom, starting: math.pi, orient: orient, flip: flip, color: color, electrons: electrons),
    ];
  }

  Widget _arrowAt(
    Offset center, {
    required double starting,
    required double orient,
    required bool flip,
    required Color color,
    required bool electrons,
  }) {
    final rotation = starting + orient + (flip ? math.pi : 0);
    return Positioned(
      left: center.dx - CurrentIndicatorsLayer.arrowLength / 2,
      top: center.dy - CurrentIndicatorsLayer.headWidth / 2,
      width: CurrentIndicatorsLayer.arrowLength,
      height: CurrentIndicatorsLayer.headWidth,
      child: Transform.rotate(
        angle: rotation,
        child: CustomPaint(
          painter: _CurrentArrowPainter(color: color, electrons: electrons),
        ),
      ),
    );
  }

  Offset _batteryTopPos() {
    final segs = data.topWireSegments;
    final horiz = segs.length > 1 ? segs[1] : segs.first;
    return Offset(
      (horiz.start.dx + horiz.end.dx) / 2,
      math.min(horiz.start.dy, horiz.end.dy) +
          CurrentIndicatorsLayer.indicatorOffset,
    );
  }

  Offset _batteryBottomPos() {
    final segs = data.bottomWireSegments;
    final horiz = segs.length > 1 ? segs[1] : segs.first;
    return Offset(
      (horiz.start.dx + horiz.end.dx) / 2,
      math.max(horiz.start.dy, horiz.end.dy) -
          CurrentIndicatorsLayer.indicatorOffset,
    );
  }

  Offset _bulbTopPos() {
    // Light bulb top wires are last two of topWireSegments when hasLightBulb
    final segs = data.topWireSegments;
    final horiz = segs.length >= 6 ? segs[5] : segs.last;
    return Offset(
      (horiz.start.dx + horiz.end.dx) / 2,
      math.min(horiz.start.dy, horiz.end.dy) +
          CurrentIndicatorsLayer.indicatorOffset,
    );
  }

  Offset _bulbBottomPos() {
    final segs = data.bottomWireSegments;
    final horiz = segs.length >= 6 ? segs[5] : segs.last;
    return Offset(
      (horiz.start.dx + horiz.end.dx) / 2,
      math.max(horiz.start.dy, horiz.end.dy) -
          CurrentIndicatorsLayer.indicatorOffset,
    );
  }
}

class _CurrentArrowPainter extends CustomPainter {
  _CurrentArrowPainter({required this.color, required this.electrons});

  final Color color;
  final bool electrons;

  @override
  void paint(Canvas canvas, Size size) {
    // Arrow tip at left (x=0), tail at right — matches ArrowNode tip/tail
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(CurrentIndicatorsLayer.headHeight, size.height / 2 - CurrentIndicatorsLayer.headWidth / 2)
      ..lineTo(CurrentIndicatorsLayer.headHeight, size.height / 2 - CurrentIndicatorsLayer.tailWidth / 2)
      ..lineTo(CurrentIndicatorsLayer.arrowLength, size.height / 2 - CurrentIndicatorsLayer.tailWidth / 2)
      ..lineTo(CurrentIndicatorsLayer.arrowLength, size.height / 2 + CurrentIndicatorsLayer.tailWidth / 2)
      ..lineTo(CurrentIndicatorsLayer.headHeight, size.height / 2 + CurrentIndicatorsLayer.tailWidth / 2)
      ..lineTo(CurrentIndicatorsLayer.headHeight, size.height / 2 + CurrentIndicatorsLayer.headWidth / 2)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Charge sphere on tail
    final chargeD = 0.8 * CurrentIndicatorsLayer.tailWidth;
    final cx = CurrentIndicatorsLayer.arrowLength -
        0.6 * (CurrentIndicatorsLayer.arrowLength - CurrentIndicatorsLayer.headHeight);
    final cy = size.height / 2;
    final chargeColor = electrons ? color : ClbColors.redColorblind;
    canvas.drawCircle(
      Offset(cx, cy),
      chargeD / 2,
      Paint()..color = chargeColor,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      chargeD / 2,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final symbolPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final sw = 0.6 * chargeD;
    if (electrons) {
      canvas.drawLine(Offset(cx - sw / 2, cy), Offset(cx + sw / 2, cy), symbolPaint);
    } else {
      canvas.drawLine(Offset(cx - sw / 2, cy), Offset(cx + sw / 2, cy), symbolPaint);
      canvas.drawLine(Offset(cx, cy - sw / 2), Offset(cx, cy + sw / 2), symbolPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CurrentArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.electrons != electrons;
}
