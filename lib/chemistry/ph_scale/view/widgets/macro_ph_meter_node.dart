import 'package:flutter/material.dart';

import '../../model/macro_model.dart';
import '../../model/ph_chemistry.dart';
import '../../model/ph_scale_colors.dart';
import '../../model/ph_scale_constants.dart';
import '../../model/water.dart';
import '../painters/beaker_painters.dart';
import '../ph_scale_fonts.dart';

/// Macro meter: fixed scale + sliding pH indicator + wire + probe.
/// PhET `MacroPHMeterNode.ts` / `PHIndicatorNode.ts`.
class MacroPhMeterNode extends StatefulWidget {
  const MacroPhMeterNode({
    super.key,
    required this.model,
    required this.layoutKey,
    required this.onProbeDragged,
  });

  final MacroModel model;

  /// Key of the 1100×700 layout [Stack] (inside FittedBox) for absolute coords.
  final GlobalKey layoutKey;
  final ValueChanged<Offset> onProbeDragged;

  static const double scaleW = 55;
  static const double scaleH = 450;

  /// Probe graphic center relative to [probePosition] (tip ≈ +30 below center).
  static const Offset probeGraphicCenter = Offset(0, -5);

  @override
  State<MacroPhMeterNode> createState() => _MacroPhMeterNodeState();
}

class _MacroPhMeterNodeState extends State<MacroPhMeterNode> {
  bool _dragging = false;
  /// Finger offset from probe position at pointer-down (layout coords).
  Offset _grab = Offset.zero;

  Offset? _layoutLocal(Offset global) {
    final box =
        widget.layoutKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  void _onPointerDown(PointerDownEvent e) {
    final local = _layoutLocal(e.position);
    if (local == null) return;
    final probe = widget.model.meter.probePosition;
    _grab = local - probe;
    _dragging = true;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!_dragging) return;
    final local = _layoutLocal(e.position);
    if (local == null) return;
    // Absolute: probe stays locked under finger (no delta accumulation lag).
    widget.onProbeDragged(local - _grab);
  }

  void _onPointerUp(PointerUpEvent e) {
    _dragging = false;
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _dragging = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model.meter,
      builder: (context, _) {
        final model = widget.model;
        final body = model.meter.bodyPosition;
        final probe = model.meter.probePosition;
        final display = model.formatDisplayedPH();
        final pH = model.meter.displayedPH;
        final indicatorCenterY = phToScaleY(pH ?? 7, MacroPhMeterNode.scaleH);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative chrome — must NOT steal faucet / dropper hits.
            IgnorePointer(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: body.dx,
                    top: body.dy,
                    child: CustomPaint(
                      size: const Size(
                        MacroPhMeterNode.scaleW + 80,
                        MacroPhMeterNode.scaleH,
                      ),
                      painter: PhScaleBarPainter(
                        width: MacroPhMeterNode.scaleW,
                        height: MacroPhMeterNode.scaleH,
                      ),
                    ),
                  ),
                  Positioned(
                    left: body.dx + MacroPhMeterNode.scaleW,
                    top: body.dy + indicatorCenterY - _PhIndicator.halfHeight,
                    child: _PhIndicator(
                      display: display,
                      enabled: pH != null,
                      highlightNeutral: pH != null &&
                          PhScaleConstants.toFixedNumber(
                                pH,
                                PhScaleConstants.phMeterDecimalPlaces,
                              ) ==
                              7,
                    ),
                  ),
                  CustomPaint(
                    size: PhScaleConstants.layoutBounds,
                    painter: _WirePainter(
                      from: Offset(
                        body.dx + MacroPhMeterNode.scaleW + 50,
                        body.dy + indicatorCenterY,
                      ),
                      to: probe,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: probe.dx - 40,
              top: probe.dy - 50,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: const SizedBox(
                  width: 80,
                  height: 100,
                  child: Center(child: _ProbeGraphic()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Sliding purple callout — PhET `PHIndicatorNode`.
class _PhIndicator extends StatelessWidget {
  const _PhIndicator({
    required this.display,
    required this.enabled,
    required this.highlightNeutral,
  });

  final String? display;
  final bool enabled;
  final bool highlightNeutral;

  static const double halfHeight = 48;
  static const double arrowW = 21;
  static const double arrowH = 28;
  static const double corner = 12;

  @override
  Widget build(BuildContext context) {
    final fill = enabled
        ? PhScaleColors.phProbe
        : PhScaleColors.phMeterDisabled;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // dashed line across scale is drawn inside scale; tip arrow here
        if (enabled)
          CustomPaint(
            size: const Size(arrowW, arrowH),
            painter: _ArrowPainter(),
          ),
        Container(
          constraints: const BoxConstraints(minWidth: 90),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(corner),
            border: Border.all(
              color: highlightNeutral ? Colors.white : Colors.black,
              width: highlightNeutral ? 3 : 2,
            ),
            boxShadow: highlightNeutral
                ? const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 0,
                      offset: Offset(0, 0),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('pH', style: PhScaleFonts.meterLabel),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(corner),
                ),
                child: Text(
                  display ?? '',
                  style: PhScaleFonts.meterValue.copyWith(
                    color: enabled
                        ? Colors.black
                        : PhScaleColors.phMeterDisabled,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProbeGraphic extends StatelessWidget {
  const _ProbeGraphic();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 44,
      height: 70,
      child: CustomPaint(painter: _ProbePainter()),
    );
  }
}

class _ProbePainter extends CustomPainter {
  const _ProbePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 0, 28, 48),
      const Radius.circular(14),
    );
    canvas.drawRRect(body, Paint()..color = PhScaleColors.phProbe);
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      const Offset(22, 24),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(22, 16),
      const Offset(22, 32),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      const Offset(14, 24),
      const Offset(30, 24),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5,
    );
    // tip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 48, 12, 18),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WirePainter extends CustomPainter {
  _WirePainter({required this.from, required this.to});

  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx + 40,
        from.dy + 80,
        to.dx - 40,
        to.dy - 40,
        to.dx,
        to.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = PhScaleColors.phProbeWire
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) =>
      oldDelegate.from != from || oldDelegate.to != to;
}

/// Probe tip in solution / faucet / dropper → displayed pH.
PhValue resolveProbePH({
  required MacroModel model,
  required Offset tip,
}) {
  final beaker = model.beaker;
  final sol = model.solution;
  final vol = sol.totalVolume;
  if (vol > 0) {
    final h = beaker.size.height * (vol / beaker.volume);
    final top = beaker.position.dy - h;
    final inBeaker = tip.dx >= beaker.left &&
        tip.dx <= beaker.right &&
        tip.dy >= top &&
        tip.dy <= beaker.position.dy;
    if (inBeaker) return sol.pH;
  }

  final wf = model.waterFaucet;
  if (wf.flowRate > 0) {
    final stream = Rect.fromCenter(
      center: Offset(wf.position.dx, wf.position.dy + 60),
      width: 40,
      height: 120,
    );
    if (stream.contains(tip)) return Water.pH;
  }

  final df = model.drainFaucet;
  if (df.flowRate > 0 && vol > 0) {
    final stream = Rect.fromCenter(
      center: Offset(df.position.dx, df.position.dy + 40),
      width: 40,
      height: 80,
    );
    if (stream.contains(tip)) return sol.pH;
  }

  final d = model.dropper.position;
  if (model.dropper.isDispensing || model.isAutofilling) {
    final stream = Rect.fromCenter(
      center: Offset(d.dx, d.dy + 80),
      width: 30,
      height: 100,
    );
    if (stream.contains(tip)) return model.dropper.solute.pH;
  }

  return null;
}
