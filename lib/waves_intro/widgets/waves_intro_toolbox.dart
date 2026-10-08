import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_measuring_tape.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/pendulum_lab/widgets/pl_stopwatch_node.dart';

import '../model/waves_intro_model.dart';
import '../waves_intro_constants.dart';
import '../waves_intro_strings.dart';

/// Toolbox icons → measuring tape / stopwatch / wave meter.
/// Evidence: `ToolboxPanel.js` @ WI lock `31ebfd7`.
class WavesIntroToolbox extends StatelessWidget {
  const WavesIntroToolbox({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final t = model.tools;
        return Material(
          elevation: 2,
          color: const Color(0xFFF1F1F2),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9.55),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToolIcon(
                  label: loc.common.measuringTape,
                  selected: t.isMeasuringTapeInPlayArea,
                  onTap: () {
                    if (t.isMeasuringTapeInPlayArea) {
                      model.returnMeasuringTape();
                    } else {
                      model.takeOutMeasuringTape();
                    }
                  },
                  child: const KratosMeasuringTapeIcon(scale: 0.5),
                ),
                const SizedBox(width: 10),
                _ToolIcon(
                  label: loc.common.stopwatch,
                  selected: t.isStopwatchVisible,
                  onTap: () {
                    if (t.isStopwatchVisible) {
                      model.returnStopwatch();
                    } else {
                      model.takeOutStopwatch();
                    }
                  },
                  child: CustomPaint(
                    size: const Size(26, 22),
                    painter: _TimerIconPainter(),
                  ),
                ),
                const SizedBox(width: 10),
                _ToolIcon(
                  label: WavesIntroStrings.waveMeter,
                  selected: t.isWaveMeterInPlayArea,
                  onTap: () {
                    if (t.isWaveMeterInPlayArea) {
                      model.returnWaveMeter();
                    } else {
                      model.takeOutWaveMeter();
                    }
                  },
                  child: CustomPaint(
                    size: const Size(28, 20),
                    painter: _MeterIconPainter(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Opacity(opacity: selected ? 0.35 : 1, child: child),
      ),
    );
  }
}

class _TimerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(3)),
      Paint()..color = const Color(0xFF2C2C2C),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '0.00',
        style: TextStyle(color: Colors.white, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(3, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MeterIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)),
      Paint()..color = const Color(0xFF3A3A3A),
    );
    final path = Path()
      ..moveTo(2, size.height * 0.7)
      ..lineTo(size.width * 0.35, size.height * 0.3)
      ..lineTo(size.width * 0.55, size.height * 0.75)
      ..lineTo(size.width - 2, size.height * 0.4);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF58C0FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Overlay tools drawn in the wave viewport (view coordinates).
class WavesIntroToolsOverlay extends StatelessWidget {
  const WavesIntroToolsOverlay({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final t = model.tools;
        return Stack(
          children: [
            if (t.isMeasuringTapeInPlayArea) _MeasuringTape(model: model),
            if (t.isStopwatchVisible) _StopwatchPanel(model: model),
            if (t.isWaveMeterInPlayArea) _WaveMeterPanel(model: model),
          ],
        );
      },
    );
  }
}

/// Map WaterDrop.y (100 → 0) into wave-area top offset.
class WaterDropLayout {
  static double yToTop(double dropY) {
    // y=100 above lattice → near top; y=0 at surface (vertical center-ish for top view marker)
    const maxY = 100.0;
    return (1 - dropY / maxY) * (WavesIntroConstants.waveAreaViewSize * 0.45);
  }
}

class _MeasuringTape extends StatelessWidget {
  const _MeasuringTape({required this.model});

  final WavesIntroModel model;

  void _nudgeBoth(Offset delta) {
    final t = model.tools;
    model.setMeasuringTapeBase(t.measuringTapeBase + delta);
    model.setMeasuringTapeTip(t.measuringTapeTip + delta);
  }

  @override
  Widget build(BuildContext context) {
    final t = model.tools;
    final len = t.measuringTapeModelLength(
      waveAreaWidth: model.scene.config.waveAreaWidth,
      waveAreaViewWidth: WavesIntroConstants.waveAreaViewSize,
    );
    final unit = model.scene.config.positionUnitLabel;

    return SizedBox(
      width: WavesIntroConstants.waveAreaViewSize,
      height: WavesIntroConstants.waveAreaViewSize,
      child: KratosMeasuringTape(
        key: const ValueKey('wi-measuring-tape'),
        base: t.measuringTapeBase,
        tip: t.measuringTapeTip,
        label: '${len.toStringAsFixed(2)} $unit',
        onBaseDelta: _nudgeBoth,
        onTipDelta: (d) => model.setMeasuringTapeTip(t.measuringTapeTip + d),
        onBodyDelta: _nudgeBoth,
      ),
    );
  }
}

class _StopwatchPanel extends StatelessWidget {
  const _StopwatchPanel({required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    final t = model.tools;
    return Positioned(
      right: 8,
      top: 8,
      child: PlStopwatchNode(
        timeSeconds: t.stopwatchTime,
        isRunning: t.isStopwatchRunning,
        onToggleRunning: model.toggleStopwatchRunning,
        onReset: model.clearStopwatchTime,
      ),
    );
  }
}

class _WaveMeterPanel extends StatelessWidget {
  const _WaveMeterPanel({required this.model});

  final WavesIntroModel model;

  /// Chart body size — [已确认] WaveMeterNode SeismographNode width:150 height:110
  static const double chartWidth = 150;
  static const double chartHeight = 110;
  static const Color series1Color = Color(0xFF191919);
  static const Color series2Color = Color(0xFF808080);
  static const Color wire2Color = Color(0xFF5A5A5A);

  @override
  Widget build(BuildContext context) {
    final t = model.tools;
    final body = t.waveMeterBody;
    final probe1Center = t.probe1 + const Offset(8, 8);
    final probe2Center = t.probe2 + const Offset(8, 8);
    final bodyLeftBottom = Offset(body.dx + 8, body.dy + chartHeight + 28);
    final bodyLeftBottom2 = Offset(body.dx + 42, body.dy + chartHeight + 28);

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _MeterWirePainter(
                from: bodyLeftBottom,
                to: probe1Center,
                color: series1Color,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _MeterWirePainter(
                from: bodyLeftBottom2,
                to: probe2Center,
                color: wire2Color,
              ),
            ),
          ),
        ),
        Positioned(
          left: t.probe1.dx,
          top: t.probe1.dy,
          child: GestureDetector(
            onPanUpdate: (d) => model.setProbe1(t.probe1 + d.delta),
            child: const _ProbeHandle(color: series1Color),
          ),
        ),
        Positioned(
          left: t.probe2.dx,
          top: t.probe2.dy,
          child: GestureDetector(
            onPanUpdate: (d) => model.setProbe2(t.probe2 + d.delta),
            child: const _ProbeHandle(color: series2Color),
          ),
        ),
        Positioned(
          left: body.dx,
          top: body.dy,
          child: GestureDetector(
            onPanUpdate: (d) =>
                model.setWaveMeterBody(t.waveMeterBody + d.delta),
            child: Material(
              elevation: 4,
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: chartWidth,
                      height: chartHeight,
                      child: CustomPaint(
                        painter: _MeterChartPainter(
                          s1: t.series1,
                          s2: t.series2,
                          verticalLabel:
                              model.scene.config.graphVerticalAxisLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProbeHandle extends StatelessWidget {
  const _ProbeHandle({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 22),
      painter: _ProbePainter(color: color),
    );
  }
}

class _ProbePainter extends CustomPainter {
  _ProbePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final tip = Offset(size.width / 2, size.height);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(2, 6)
      ..arcToPoint(
        Offset(size.width - 2, 6),
        radius: const Radius.circular(6),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ProbePainter old) => old.color != color;
}

class _MeterWirePainter extends CustomPainter {
  _MeterWirePainter({
    required this.from,
    required this.to,
    required this.color,
  });
  final Offset from;
  final Offset to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset(
      (from.dx + to.dx) / 2,
      mathMax(from.dy, to.dy) + 18,
    );
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MeterWirePainter old) =>
      old.from != from || old.to != to || old.color != color;
}

double mathMax(double a, double b) => a > b ? a : b;

class _MeterChartPainter extends CustomPainter {
  _MeterChartPainter({
    required this.s1,
    required this.s2,
    required this.verticalLabel,
  });
  final List<double> s1;
  final List<double> s2;
  final String verticalLabel;

  /// Fixed vertical range — presentation only; sampling unchanged.
  static const double yRange = 2.0;
  static const int timeDivisions = 4;

  @override
  void paint(Canvas canvas, Size size) {
    const plotLeft = 18.0;
    const plotBottom = 16.0;
    const plotTop = 8.0;
    final plot = Rect.fromLTRB(
      plotLeft,
      plotTop,
      size.width - 4,
      size.height - plotBottom,
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF2A2A2A),
    );
    canvas.drawRect(plot, Paint()..color = const Color(0xFF1A1A1A));

    final gridPaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 0.75;
    for (var i = 0; i <= timeDivisions; i++) {
      final x = plot.left + plot.width * i / timeDivisions;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
    }
    canvas.drawLine(
      Offset(plot.left, plot.center.dy),
      Offset(plot.right, plot.center.dy),
      gridPaint..color = const Color(0xFF777777),
    );

    void drawSeries(List<double> s, Color c) {
      if (s.length < 2) return;
      final path = Path();
      var started = false;
      for (var i = 0; i < s.length; i++) {
        final v = s[i];
        if (v.isNaN) {
          started = false;
          continue;
        }
        final x = plot.left + i / (s.length - 1) * plot.width;
        final y = plot.center.dy - (v / yRange) * (plot.height * 0.45);
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    drawSeries(s1, const Color(0xFFE8E8E8));
    drawSeries(s2, const Color(0xFFAAAAAA));

    final tp = TextPainter(
      text: const TextSpan(
        text: 'time',
        style: TextStyle(color: Colors.white, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(plot.center.dx - tp.width / 2, size.height - tp.height - 1),
    );

    canvas.save();
    canvas.translate(2, plot.center.dy);
    canvas.rotate(-1.57079632679);
    final vp = TextPainter(
      text: TextSpan(
        text: verticalLabel,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: plot.height);
    vp.paint(canvas, Offset(-vp.width / 2, 0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MeterChartPainter old) => true;
}
