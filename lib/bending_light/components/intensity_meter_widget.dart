import 'package:flutter/material.dart';

import '../components/probe_glyph.dart';
import '../model/bl_vec2.dart';
import '../model/intensity_meter.dart';
import '../model/reading.dart';
import '../model/wire_geometry.dart';
import 'toolbox_icons.dart';
import '../screens/stage_scale.dart';
import '../transform/bl_mvt.dart';

/// Intensity body + probe + wire. Positions come from [IntensityMeter].
class IntensityMeterWidget extends StatelessWidget {
  const IntensityMeterWidget({
    super.key,
    required this.mvt,
    required this.meter,
    required this.onBodyDelta,
    required this.onProbeDelta,
    this.onBodyPanEnd,
  });

  final BlMvt mvt;
  final IntensityMeter meter;
  final void Function(Offset viewDelta) onBodyDelta;
  final void Function(Offset viewDelta) onProbeDelta;
  final VoidCallback? onBodyPanEnd;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final body = mvt.worldToScreen(meter.bodyPosition);
    final probeScreen = mvt.worldToScreen(meter.sensorPosition);
    final probeGlyph = ProbeGlyph(color: const Color(0xFF008541), scale: 0.6 * view);
    final label = meter.reading.isMiss
        ? '—'
        : '${meter.reading.displayPercent.toStringAsFixed(2)}%';
    const bodyScale = 0.6;
    final bodyW = 150.0 * bodyScale * view;
    final bodyH = 95.0 * bodyScale * view;
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: CubicWirePainter(
            wire: CubicWire.between(
              start: BlVec2(body.dx + bodyW, body.dy + bodyH - 12),
              startNormal: CubicWire.bodyNormal,
              end: BlVec2(
                probeScreen.dx,
                probeScreen.dy + probeGlyph.centerBottomDy,
              ),
              endNormal: CubicWire.sensorNormal,
            ),
          ),
        ),
        Positioned(
          left: body.dx,
          top: body.dy,
          child: GestureDetector(
            onPanUpdate: (d) => onBodyDelta(d.delta),
            onPanEnd: (_) => onBodyPanEnd?.call(),
            child: IntensityMeterBody(scale: bodyScale, reading: label),
          ),
        ),
        Positioned(
          left: probeScreen.dx - probeGlyph.sensorOrigin.dx,
          top: probeScreen.dy - probeGlyph.sensorOrigin.dy,
          child: GestureDetector(
            onPanUpdate: (d) => onProbeDelta(d.delta),
            child: probeGlyph,
          ),
        ),
      ],
    );
  }
}

class WaveWire extends StatelessWidget {
  const WaveWire({super.key, required this.wire, required this.color});

  final CubicWire wire;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CubicWirePainter(wire: wire, color: color),
      ),
    );
  }
}

class CubicWirePainter extends CustomPainter {
  CubicWirePainter({required this.wire, this.color = const Color(0xFF424242)});

  final CubicWire wire;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(wire.start.x, wire.start.y)
      ..cubicTo(
        wire.control1.x,
        wire.control1.y,
        wire.control2.x,
        wire.control2.y,
        wire.end.x,
        wire.end.y,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CubicWirePainter oldDelegate) =>
      oldDelegate.wire.start != wire.start ||
      oldDelegate.wire.end != wire.end ||
      oldDelegate.wire.control1 != wire.control1 ||
      oldDelegate.wire.control2 != wire.control2;
}

/// Toolbox icon slot. Source VBox sets `excludeInvisibleChildrenFromBounds: false`,
/// so a hidden icon still occupies its cell. The panel does not shrink, and the
/// tool can be dropped back into that blank cell.
class ToolboxSlot extends StatelessWidget {
  const ToolboxSlot({
    super.key,
    required this.inToolbox,
    required this.child,
  });

  final bool inToolbox;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: inToolbox,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: IgnorePointer(
        ignoring: !inToolbox,
        child: child,
      ),
    );
  }
}

class ToolboxChip extends StatefulWidget {
  const ToolboxChip({
    super.key,
    required this.semanticsLabel,
    required this.child,
    this.onPressed,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
  });

  /// Accessibility name. The visible child is the scenery node, not this string.
  final String semanticsLabel;
  final Widget child;
  final VoidCallback? onPressed;

  /// Pointer went down on the chip. When set, the chip does not draw its own ghost;
  /// the parent shows the dragged copy (prism icons follow the pointer immediately).
  final void Function(Offset global)? onDragStart;

  /// Latest global pointer position while the drag is active.
  final void Function(Offset global)? onDragUpdate;

  /// Global pointer position when the drag ends. Placement is decided by the parent.
  final void Function(Offset global)? onDragEnd;

  /// Arena lost before the pointer came up. Drop the in-progress copy.
  final VoidCallback? onDragCancel;

  @override
  State<ToolboxChip> createState() => _ToolboxChipState();
}

class _ToolboxChipState extends State<ToolboxChip> {
  OverlayEntry? _ghost;
  Offset _global = Offset.zero;

  void _show(Offset global) {
    _global = global;
    _hide();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final sx = StageScale.x(context);
    final sy = StageScale.y(context);
    _ghost = OverlayEntry(
      builder: (context) => Positioned(
        left: _global.dx + 6,
        top: _global.dy + 6,
        child: StageScale(
          scaleX: sx,
          scaleY: sy,
          child: IgnorePointer(child: widget.child),
        ),
      ),
    );
    overlay.insert(_ghost!);
  }

  void _hide() {
    _ghost?.remove();
    _ghost = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drag = widget.onDragEnd;
    final forward = widget.onDragStart != null;
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: GestureDetector(
        onTap: widget.onPressed,
        onPanDown: !forward
            ? null
            : (d) {
                _global = d.globalPosition;
                widget.onDragStart!(d.globalPosition);
              },
        onPanStart: drag == null
            ? null
            : (d) {
                _global = d.globalPosition;
                if (!forward) _show(d.globalPosition);
              },
        onPanUpdate: drag == null
            ? null
            : (d) {
                _global = d.globalPosition;
                if (forward) {
                  widget.onDragUpdate?.call(d.globalPosition);
                } else {
                  _ghost?.markNeedsBuild();
                }
              },
        onPanEnd: drag == null
            ? null
            : (d) {
                _hide();
                drag(d.globalPosition);
              },
        onPanCancel: () {
          _hide();
          if (forward) widget.onDragCancel?.call();
        },
        child: widget.child,
      ),
    );
  }
}

String intensityLabel(Reading reading) =>
    reading.isMiss ? '—' : '${reading.displayPercent.toStringAsFixed(2)}%';

BlVec2 clampWorld(BlVec2 p, {double limit = 0.00004}) => BlVec2(
      p.x.clamp(-limit, limit),
      p.y.clamp(-limit, limit),
    );
