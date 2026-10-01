import 'package:flutter/material.dart';

import '../../domain/probe.dart';
import 'qwi_colors.dart';
import 'qwi_panel.dart';
import 'qwi_typography.dart';

/// Port of PhET `DetectorProbeNode` chrome (circle + % / state + wire + Detect panel).
///
/// Does **not** change probe probability / projection — view + interaction only.
class QwiProbeNode extends StatelessWidget {
  const QwiProbeNode({
    super.key,
    required this.probe,
    required this.waveSize,
    required this.panelAnchor,
    required this.onMove,
    required this.onRadiusChanged,
    required this.onDetectOrReset,
  });

  final DetectorProbe probe;
  final Size waveSize;
  final Offset panelAnchor;
  final void Function(double normX, double normY) onMove;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onDetectOrReset;

  Color get _fill {
    switch (probe.state) {
      case ProbeState.detected:
        return QwiColors.probeDetectedFill;
      case ProbeState.notDetected:
        return QwiColors.probeNotDetectedFill;
      case ProbeState.ready:
        return QwiColors.probeReadyFill;
    }
  }

  String get _circleLabel {
    switch (probe.state) {
      case ProbeState.detected:
        return 'Particle\nDetected';
      case ProbeState.notDetected:
        return 'Not\nDetected';
      case ProbeState.ready:
        return '${(probe.probability * 100).toStringAsFixed(1)}%';
    }
  }

  String get _buttonLabel => probe.state == ProbeState.ready ? 'Detect' : 'Reset Detector';

  @override
  Widget build(BuildContext context) {
    final cx = probe.normalizedX * waveSize.width;
    final cy = probe.normalizedY * waveSize.height;
    final r = (probe.radius * waveSize.width).clamp(8.0, waveSize.width * 0.45);

    return Stack(
      key: const Key('sp_probe_overlay'),
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _ProbeWirePainter(
              from: Offset(cx, cy + r),
              to: Offset(panelAnchor.dx, panelAnchor.dy - 28),
            ),
          ),
        ),
        Positioned(
          left: cx - r,
          top: cy - r,
          width: r * 2,
          height: r * 2,
          child: Semantics(
            label: 'Detector probe',
            value: _circleLabel.replaceAll('\n', ' '),
            child: GestureDetector(
              onPanUpdate: (d) {
                final nx = ((cx + d.delta.dx) / waveSize.width).clamp(0.0, 1.0);
                final ny = ((cy + d.delta.dy) / waveSize.height).clamp(0.0, 1.0);
                onMove(nx, ny);
              },
              child: CustomPaint(
                painter: _ProbeCirclePainter(fill: _fill, radius: r),
                child: Center(
                  child: Text(
                    _circleLabel,
                    textAlign: TextAlign.center,
                    style: QwiTypography.probeReadout(r > 36 ? 14.4 : 11),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: panelAnchor.dx - 100,
          top: panelAnchor.dy - 28,
          width: 200,
          child: Material(
            type: MaterialType.transparency,
            child: QwiPanel(
              child: Row(
                children: [
                  Expanded(
                    child: QwiPushButton(
                      key: const Key('sp_probe_detect'),
                      label: _buttonLabel,
                      onPressed: onDetectOrReset,
                      minWidth: 90,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Detector Size', style: QwiTypography.label(11)),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            activeTrackColor: QwiColors.selectedControl,
                            inactiveTrackColor: const Color(0xFFCCCCCC),
                          ),
                          child: Slider(
                            key: const Key('sp_probe_size_slider'),
                            value: probe.radius.clamp(0.04, 0.35),
                            min: 0.04,
                            max: 0.35,
                            onChanged: probe.state == ProbeState.ready ? onRadiusChanged : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProbeCirclePainter extends CustomPainter {
  _ProbeCirclePainter({required this.fill, required this.radius});

  final Color fill;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, radius, Paint()..color = fill);
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..color = QwiColors.probeStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ProbeCirclePainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.radius != radius;
}

class _ProbeWirePainter extends CustomPainter {
  _ProbeWirePainter({required this.from, required this.to});

  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = (from.dy + to.dy) / 2;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy);
    final paint = Paint()
      ..color = QwiColors.probeWire
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = (d + 4).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, next), paint);
        d += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProbeWirePainter oldDelegate) =>
      oldDelegate.from != from || oldDelegate.to != to;
}
