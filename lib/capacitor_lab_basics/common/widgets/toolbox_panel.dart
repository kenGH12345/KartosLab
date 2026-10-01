import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../../clb_strings.dart';
import '../model/clb_model.dart';
import '../transform/yaw_pitch_mvt.dart';
import 'stopwatch_interaction.dart';
import 'voltmeter_drag_layer.dart';

/// Voltmeter toolbox — `ToolboxPanel.js` (Capacitance: no timer).
///
/// Icon matches `VoltmeterIconNode` (body + probes + Voltage/?).
/// Layout uses explicit sized images — **never** [Transform.scale] alone
/// (that keeps full PNG layout size and blows up the panel).
class ToolboxPanel extends StatefulWidget {
  const ToolboxPanel({
    super.key,
    required this.model,
    required this.onBounds,
    this.mvt,
    this.includeTimer = false,
  });

  final ClbModel model;
  final void Function(Size size) onBounds;
  final YawPitchMvt? mvt;
  final bool includeTimer;

  @override
  State<ToolboxPanel> createState() => _ToolboxPanelState();
}

class _ToolboxPanelState extends State<ToolboxPanel> {
  final GlobalKey _key = GlobalKey();
  /// Keeps toolbox pan gesture alive after icon hides (PhET forwards to body drag).
  bool _draggingOut = false;
  bool _draggingStopwatchOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportBounds());
  }

  @override
  void didUpdateWidget(covariant ToolboxPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportBounds());
  }

  void _reportBounds() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    widget.onBounds(box.size);
  }

  Rect? _toolboxCanvasRect() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    RenderBox? canvas;
    var p = context.findRenderObject();
    while (p != null) {
      if (p is RenderBox &&
          p.hasSize &&
          (p.size.width - ClbConstants.canvasWidth).abs() < 1 &&
          (p.size.height - ClbConstants.canvasHeight).abs() < 1) {
        canvas = p;
        break;
      }
      p = p.parent;
    }
    if (canvas == null) return null;
    final topLeft = canvas.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  void _moveBodyOnly(Offset viewDelta) {
    final mvt = widget.mvt ?? YawPitchMvt();
    final delta = mvt.viewToModelDeltaXY(viewDelta.dx, viewDelta.dy);
    // PhET body dragListener — probes stay at absolute positions.
    final vm = widget.model.voltmeter;
    vm.bodyX += delta.dx;
    vm.bodyY += delta.dy;
    widget.model.notifyViewChanged();
  }

  /// Toolbox extract — `ToolboxPanel.js` forwarding listener.
  /// Body center under pointer; probes untouched.
  void _extractAtPointer(Offset localInSlot) {
    final mvt = widget.mvt ?? YawPitchMvt();
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    RenderBox? canvas;
    var p = context.findRenderObject();
    while (p != null) {
      if (p is RenderBox &&
          p.hasSize &&
          (p.size.width - ClbConstants.canvasWidth).abs() < 1 &&
          (p.size.height - ClbConstants.canvasHeight).abs() < 1) {
        canvas = p;
        break;
      }
      p = p.parent;
    }
    canvas ??= box;

    final pointerCanvas =
        canvas.globalToLocal(box.localToGlobal(localInSlot));
    placeVoltmeterFromToolbox(
      voltmeter: widget.model.voltmeter,
      mvt: mvt,
      bodyTopLeftView: voltmeterBodyTopLeftCenteredOn(pointerCanvas),
    );
    widget.model.setVoltmeterVisible(true);
  }

  void _endToolboxDrag() {
    setState(() => _draggingOut = false);
    widget.model.voltmeter.isDragged = false;
    final dock = _toolboxCanvasRect();
    if (dock != null) {
      maybeReturnVoltmeterToToolbox(
        model: widget.model,
        mvt: widget.mvt ?? YawPitchMvt(),
        toolboxBounds: dock,
      );
    }
    widget.model.notifyViewChanged();
  }

  Widget _stopwatchSlot() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) {
        setState(() => _draggingStopwatchOut = true);
        _extractStopwatchAtPointer(d.localPosition);
      },
      onPanUpdate: (d) {
        if (!widget.model.stopwatchVisible) return;
        widget.model.stopwatchX += d.delta.dx;
        widget.model.stopwatchY += d.delta.dy;
        widget.model.notifyViewChanged();
      },
      onPanEnd: (_) {
        setState(() => _draggingStopwatchOut = false);
        final dock = _toolboxCanvasRect();
        if (dock != null) {
          maybeReturnStopwatchToToolbox(
            model: widget.model,
            toolboxBounds: dock,
          );
        }
        widget.model.notifyViewChanged();
      },
      onPanCancel: () => setState(() => _draggingStopwatchOut = false),
      onTap: () {
        // Tap → place left of toolbox (no snap animation).
        final dock = _toolboxCanvasRect();
        final tl = dock != null
            ? Offset(
                (dock.left - ClbStopwatchLayout.width - 14)
                    .clamp(8.0, ClbConstants.canvasWidth - ClbStopwatchLayout.width),
                dock.top.clamp(
                  8.0,
                  ClbConstants.canvasHeight - ClbStopwatchLayout.height,
                ),
              )
            : Offset(40, ClbConstants.canvasHeight - 188);
        widget.model.placeStopwatchAt(tl);
      },
      child: const _StopwatchToolboxIcon(),
    );
  }

  void _extractStopwatchAtPointer(Offset localInSlot) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    RenderBox? canvas;
    var p = context.findRenderObject();
    while (p != null) {
      if (p is RenderBox &&
          p.hasSize &&
          (p.size.width - ClbConstants.canvasWidth).abs() < 1 &&
          (p.size.height - ClbConstants.canvasHeight).abs() < 1) {
        canvas = p;
        break;
      }
      p = p.parent;
    }
    canvas ??= box;
    final pointerCanvas =
        canvas.globalToLocal(box.localToGlobal(localInSlot));
    // PhET: center under pointer
    widget.model.placeStopwatchAt(
      ClbStopwatchLayout.topLeftCenteredOn(pointerCanvas),
    );
  }

  Widget _voltmeterSlot({required bool showIcon}) {
    final scale = widget.includeTimer
        ? ClbConstants.voltmeterToolboxIconScaleWithTimer
        : ClbConstants.voltmeterToolboxIconScaleAlone;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) {
        setState(() => _draggingOut = true);
        _extractAtPointer(d.localPosition);
      },
      onPanUpdate: (d) {
        if (!widget.model.voltmeterVisible) return;
        _moveBodyOnly(d.delta);
      },
      onPanEnd: (_) => _endToolboxDrag(),
      onPanCancel: () {
        setState(() => _draggingOut = false);
        widget.model.voltmeter.isDragged = false;
        final dock = _toolboxCanvasRect();
        if (dock != null) {
          maybeReturnVoltmeterToToolbox(
            model: widget.model,
            mvt: widget.mvt ?? YawPitchMvt(),
            toolboxBounds: dock,
          );
        }
        widget.model.notifyViewChanged();
      },
      // PhET: drag only (no tap-to-place).
      child: showIcon
          ? _VoltmeterToolboxIcon(scale: scale)
          : SizedBox(
              width: _VoltmeterToolboxIcon.layoutWidthFor(scale),
              height: _VoltmeterToolboxIcon.layoutHeightFor(scale),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, _) {
        return Material(
          key: _key,
          color: ClbColors.meterPanelFill,
          elevation: 2,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minWidth: 175),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.model.voltmeterVisible || _draggingOut)
                  Opacity(
                    opacity: widget.model.voltmeterVisible ? 0 : 1,
                    child: _voltmeterSlot(showIcon: true),
                  )
                else
                  SizedBox(
                    width: _VoltmeterToolboxIcon.layoutWidthFor(
                      widget.includeTimer
                          ? ClbConstants.voltmeterToolboxIconScaleWithTimer
                          : ClbConstants.voltmeterToolboxIconScaleAlone,
                    ),
                    height: _VoltmeterToolboxIcon.layoutHeightFor(
                      widget.includeTimer
                          ? ClbConstants.voltmeterToolboxIconScaleWithTimer
                          : ClbConstants.voltmeterToolboxIconScaleAlone,
                    ),
                  ),
                if (widget.includeTimer) ...[
                  const SizedBox(width: 13),
                  if (!widget.model.stopwatchVisible || _draggingStopwatchOut)
                    Opacity(
                      opacity: widget.model.stopwatchVisible ? 0 : 1,
                      child: _stopwatchSlot(),
                    )
                  else
                    const SizedBox(
                      width: _StopwatchToolboxIcon.layoutWidth,
                      height: _StopwatchToolboxIcon.layoutHeight,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `VoltmeterIconNode` — body@0.17, probes@0.10, Voltage + ? readout.
/// Outer [scale]: Light Bulb toolbox `0.6`, Capacitance `1` (`ToolboxPanel.js`).
class _VoltmeterToolboxIcon extends StatelessWidget {
  const _VoltmeterToolboxIcon({this.scale = 1.0});

  final double scale;

  static const double _bodyW0 = 405 * ClbConstants.voltmeterIconBodyScale;
  static const double _bodyH0 = 502 * ClbConstants.voltmeterIconBodyScale;
  static const double _probeW0 = 62 * ClbConstants.voltmeterIconProbeScale;
  static const double _probeH0 = 501 * ClbConstants.voltmeterIconProbeScale;

  /// Probe centerBottom offsets from body centerBottom (`VoltmeterIconNode`).
  static const double _probeDx0 = 40;
  static const double _probeDy0 = 15;

  static double layoutWidthFor(double scale) =>
      (_bodyW0 + _probeDx0 * 2 + _probeW0) * scale;
  static double layoutHeightFor(double scale) =>
      math.max(_bodyH0, _probeH0 + _probeDy0) * scale;

  @override
  Widget build(BuildContext context) {
    final bodyW = _bodyW0 * scale;
    final bodyH = _bodyH0 * scale;
    final probeW = _probeW0 * scale;
    final probeH = _probeH0 * scale;
    final probeDx = _probeDx0 * scale;
    final probeDy = _probeDy0 * scale;
    final w = layoutWidthFor(scale);
    final h = layoutHeightFor(scale);
    final bodyLeft = (w - bodyW) / 2;
    final bodyTop = 0.0;
    final bodyCenterBottom = Offset(bodyLeft + bodyW / 2, bodyTop + bodyH);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: bodyLeft,
            top: bodyTop,
            width: bodyW,
            height: bodyH,
            child: Image.asset(
              ClbConstants.assetVoltmeterBody,
              width: bodyW,
              height: bodyH,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned(
            left: bodyLeft + bodyW * 0.25,
            top: bodyTop + bodyH * 0.28,
            width: bodyW * 0.5,
            child: Column(
              children: [
                Text(
                  ClbStrings.voltage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: math.max(7.0, bodyW * 0.08),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 0.75),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    ClbStrings.voltsUnknown,
                    style: TextStyle(
                      fontSize: math.max(8.0, bodyW * 0.09),
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: bodyCenterBottom.dx - probeDx - probeW / 2,
            top: bodyCenterBottom.dy - probeDy - probeH,
            width: probeW,
            height: probeH,
            child: Image.asset(
              ClbConstants.assetProbeRed,
              width: probeW,
              height: probeH,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned(
            left: bodyCenterBottom.dx + probeDx - probeW / 2,
            top: bodyCenterBottom.dy - probeDy - probeH,
            width: probeW,
            height: probeH,
            child: Image.asset(
              ClbConstants.assetProbeBlack,
              width: probeW,
              height: probeH,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size(w, h),
              painter: _IconProbeWiresPainter(
                bodyLeft: bodyLeft,
                bodyTop: bodyTop,
                bodySize: Size(bodyW, bodyH),
                redBottom: Offset(
                  bodyCenterBottom.dx - probeDx,
                  bodyCenterBottom.dy - probeDy,
                ),
                blackBottom: Offset(
                  bodyCenterBottom.dx + probeDx,
                  bodyCenterBottom.dy - probeDy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconProbeWiresPainter extends CustomPainter {
  _IconProbeWiresPainter({
    required this.bodyLeft,
    required this.bodyTop,
    required this.bodySize,
    required this.redBottom,
    required this.blackBottom,
  });

  final double bodyLeft;
  final double bodyTop;
  final Size bodySize;
  final Offset redBottom;
  final Offset blackBottom;

  @override
  void paint(Canvas canvas, Size size) {
    final posConn = Offset(
      bodyLeft + 3 * bodySize.width / 7,
      bodyTop + bodySize.height * 7 / 8,
    );
    final negConn = Offset(
      bodyLeft + 4 * bodySize.width / 7,
      bodyTop + bodySize.height * 7 / 8,
    );
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final redPath = Path()
      ..moveTo(posConn.dx, posConn.dy)
      ..cubicTo(
        posConn.dx + (redBottom.dx - posConn.dx) / 2,
        posConn.dy + 10,
        redBottom.dx,
        posConn.dy + 5,
        redBottom.dx,
        redBottom.dy,
      );
    final blackPath = Path()
      ..moveTo(negConn.dx, negConn.dy)
      ..cubicTo(
        negConn.dx + (blackBottom.dx - negConn.dx) / 2,
        negConn.dy + 10,
        blackBottom.dx,
        negConn.dy + 5,
        blackBottom.dx,
        blackBottom.dy,
      );
    canvas.drawPath(redPath, paint..color = ClbColors.redColorblind);
    canvas.drawPath(blackPath, paint..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _IconProbeWiresPainter oldDelegate) => false;
}

/// Compact stopwatch icon for Light Bulb toolbox (text approx, no Material Icons).
class _StopwatchToolboxIcon extends StatelessWidget {
  const _StopwatchToolboxIcon();

  static const double layoutWidth = 72;
  static const double layoutHeight = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layoutWidth,
      height: layoutHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black54),
      ),
      alignment: Alignment.center,
      child: const Text(
        '00:00.0',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
