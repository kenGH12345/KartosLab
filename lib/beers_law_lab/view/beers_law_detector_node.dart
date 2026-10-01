import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/beers_law_constants.dart';
import '../model/beers_law_model.dart';
import '../model/detector_mode.dart';
import 'beers_law_layout.dart';
import 'beers_law_mvt.dart';

/// PhET `DetectorNode` — fixed body + wire + draggable probe.
class BeersLawDetectorNode extends StatelessWidget {
  const BeersLawDetectorNode({
    super.key,
    required this.model,
    this.mvt = const BeersLawMvt(),
  });

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _DetectorWire(model: model, mvt: mvt),
        _DetectorBody(model: model, mvt: mvt),
        _DetectorProbe(model: model, mvt: mvt),
      ],
    );
  }
}

class _DetectorBody extends StatelessWidget {
  const _DetectorBody({required this.model, required this.mvt});

  final BeersLawModel model;
  final BeersLawMvt mvt;

  String get _valueText {
    final v = model.displayedMeasurement;
    if (v == null) return '—';
    if (model.detector.mode == DetectorMode.transmittance) {
      return '${v.toStringAsFixed(BeersLawConstants.decimalPlacesTransmittance)}%';
    }
    return v.toStringAsFixed(BeersLawConstants.decimalPlacesAbsorbance);
  }

  @override
  Widget build(BuildContext context) {
    final pos = mvt.modelToView(model.detector.bodyPosition);
    const bodyW = 220.0;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: bodyW,
      child: Semantics(
        label: 'Detector reading $_valueText',
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: BeersLawLayout.detectorColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black54),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 3, offset: Offset(1, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.black26),
                ),
                child: Text(
                  _valueText,
                  key: const Key('beers_law_detector_value'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _ModeRadio(
                selected: model.detector.mode,
                onChanged: model.setDetectorMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeRadio extends StatelessWidget {
  const _ModeRadio({required this.selected, required this.onChanged});

  final DetectorMode selected;
  final ValueChanged<DetectorMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _radio(DetectorMode.transmittance, 'Transmittance'),
        _radio(DetectorMode.absorbance, 'Absorbance'),
      ],
    );
  }

  Widget _radio(DetectorMode mode, String label) {
    final on = selected == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 1.5),
              ),
              child: on
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectorProbe extends StatefulWidget {
  const _DetectorProbe({required this.model, required this.mvt});

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  State<_DetectorProbe> createState() => _DetectorProbeState();
}

class _DetectorProbeState extends State<_DetectorProbe> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final mvt = widget.mvt;
    final center = mvt.modelToView(model.detector.probePosition);
    final r = BeersLawLayout.probeRadius;
    final handleH = BeersLawLayout.probeHandleHeight;
    final handleW = BeersLawLayout.probeHandleWidth;
    final left = center.dx - r;
    final top = center.dy - r;

    return Positioned(
      left: left,
      top: top,
      width: r * 2 + handleW * 0.3,
      height: r * 2 + handleH * 0.3,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyJ) {
            model.jumpDetectorProbe();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Semantics(
          label: 'Detector probe',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) {
              // Delta-based drag preserves pointer offset (no snap-to-center).
              final cur = model.detector.probePosition;
              model.setDetectorProbePosition(Offset(
                cur.dx + mvt.viewToModelDelta(d.delta.dx),
                cur.dy + mvt.viewToModelDelta(d.delta.dy),
              ));
            },
            onPanEnd: (_) => model.endDetectorProbeDrag(),
            child: CustomPaint(
              size: Size(r * 2 + 20, r * 2 + 20),
              painter: _ProbePainter(
                color: BeersLawLayout.detectorColor,
                inBeam: model.isProbeInBeam,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProbePainter extends CustomPainter {
  _ProbePainter({required this.color, required this.inBeam});

  final Color color;
  final bool inBeam;

  @override
  void paint(Canvas canvas, Size size) {
    final r = BeersLawLayout.probeRadius;
    final ir = BeersLawLayout.probeInnerRadius;
    final c = Offset(r, r);

    // handle (down-left at ~1.25π)
    final handleAngle = 1.25 * math.pi;
    final hx = c.dx + math.cos(handleAngle) * (r - 8);
    final hy = c.dy + math.sin(handleAngle) * (r - 8);
    final handle = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(hx, hy),
        width: BeersLawLayout.probeHandleWidth * 0.55,
        height: BeersLawLayout.probeHandleHeight * 0.55,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(handle, Paint()..color = color);
    canvas.drawRRect(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black87
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black87
        ..strokeWidth = 2,
    );
    canvas.drawCircle(c, ir, Paint()..color = const Color(0xFF42A5F5));
    canvas.drawCircle(
      c,
      ir,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54
        ..strokeWidth = 1.5,
    );
    // crosshair
    final cross = Paint()
      ..color = inBeam ? Colors.yellowAccent : Colors.black54
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(c.dx - 12, c.dy), Offset(c.dx + 12, c.dy), cross);
    canvas.drawLine(Offset(c.dx, c.dy - 12), Offset(c.dx, c.dy + 12), cross);
  }

  @override
  bool shouldRepaint(covariant _ProbePainter oldDelegate) =>
      oldDelegate.inBeam != inBeam || oldDelegate.color != color;
}

class _DetectorWire extends StatelessWidget {
  const _DetectorWire({required this.model, required this.mvt});

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  Widget build(BuildContext context) {
    final body = mvt.modelToView(model.detector.bodyPosition);
    final probe = mvt.modelToView(model.detector.probePosition);
    // Approximate attach points
    final p0 = Offset(body.dx + 30, body.dy + 140);
    final p1 = probe;

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _WirePainter(p0: p0, p1: p1),
        ),
      ),
    );
  }
}

class _WirePainter extends CustomPainter {
  _WirePainter({required this.p0, required this.p1});

  final Offset p0;
  final Offset p1;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset((p0.dx + p1.dx) / 2, math.max(p0.dy, p1.dy) + 40);
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, p1.dx, p1.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) =>
      oldDelegate.p0 != p0 || oldDelegate.p1 != p1;
}
