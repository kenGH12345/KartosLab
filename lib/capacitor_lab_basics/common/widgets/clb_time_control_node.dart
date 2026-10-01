import 'package:flutter/material.dart';

import '../model/clb_model.dart';
import '../model/time_speed.dart';

/// PhET `TimeControlNode` + `Panel` skin for Light Bulb.
///
/// Source: `CLBLightBulbScreenView.js:100-114` + scenery-phet `TimeControlNode.ts`
/// Layout: [PlayPause (r≈20.8) + StepForward (r=15)]  —spacing 40—  [Normal/Slow radios]
/// Panel: fill rgba(255,255,255,0.6), xMargin/yMargin 15, stroke null.
///
/// **Does not change** Pause / Resume / Step / Slow semantics — only chrome.
class ClbTimeControlNode extends StatelessWidget {
  const ClbTimeControlNode({super.key, required this.model});

  final ClbModel model;

  /// `SceneryPhetConstants.DEFAULT_BUTTON_RADIUS`
  static const double playPauseRadius = 20.8;

  /// `PlayPauseStepButtonGroup` DEFAULT_STEP_BUTTON_RADIUS
  static const double stepRadius = 15;

  /// `TimeControlNode` default flowBoxSpacing
  static const double groupSpacing = 40;

  /// Panel margins — `CLBLightBulbScreenView.js:109-110`
  static const double panelMargin = 15;

  static const Color _panelFill = Color.fromRGBO(255, 255, 255, 0.6);
  static const Color _buttonFace = Color(0xFFFED700);
  static const Color _buttonEdge = Color(0xFFCC9900);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(panelMargin),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _PlayPauseStepGroup(model: model),
            const SizedBox(width: groupSpacing),
            _SpeedRadioGroup(model: model),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseStepGroup extends StatelessWidget {
  const _PlayPauseStepGroup({required this.model});

  final ClbModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(
          radius: ClbTimeControlNode.playPauseRadius,
          onPressed: () => model.setPlaying(!model.isPlaying),
          semanticLabel: model.isPlaying ? 'Pause' : 'Play',
          painter: model.isPlaying
              ? const _PauseIconPainter()
              : const _PlayIconPainter(),
        ),
        const SizedBox(width: 10), // playPauseStepXSpacing
        _RoundIconButton(
          radius: ClbTimeControlNode.stepRadius,
          onPressed: () => model.manualStep(),
          semanticLabel: 'Step',
          painter: const _StepForwardIconPainter(),
        ),
      ],
    );
  }
}

class _SpeedRadioGroup extends StatelessWidget {
  const _SpeedRadioGroup({required this.model});

  final ClbModel model;

  @override
  Widget build(BuildContext context) {
    // TimeSpeedRadioButtonGroup: NORMAL then SLOW, VerticalAquaRadio, spacing 9
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SpeedRadio(
          label: 'Normal',
          selected: model.timeSpeed == TimeSpeed.normal,
          onTap: () => model.setTimeSpeed(TimeSpeed.normal),
        ),
        const SizedBox(height: 9),
        _SpeedRadio(
          label: 'Slow',
          selected: model.timeSpeed == TimeSpeed.slow,
          onTap: () => model.setTimeSpeed(TimeSpeed.slow),
        ),
      ],
    );
  }
}

class _SpeedRadio extends StatelessWidget {
  const _SpeedRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 1.2),
              color: selected ? const Color(0xFF5A9BD5) : Colors.white,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.radius,
    required this.onPressed,
    required this.painter,
    required this.semanticLabel,
  });

  final double radius;
  final VoidCallback onPressed;
  final CustomPainter painter;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.35, -0.4),
              radius: 0.95,
              colors: [
                Color(0xFFFFF4A8),
                ClbTimeControlNode._buttonFace,
                ClbTimeControlNode._buttonEdge,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            border: Border.all(color: const Color(0xFF996600), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: CustomPaint(painter: painter),
        ),
      ),
    );
  }
}

/// Play triangle — relative to PlayIconShape (width 0.8r, height r).
class _PlayIconPainter extends CustomPainter {
  const _PlayIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.32;
    final h = size.height * 0.4;
    final path = Path()
      ..moveTo(cx - w * 0.35, cy - h / 2)
      ..lineTo(cx - w * 0.35, cy + h / 2)
      ..lineTo(cx + w * 0.55, cy)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PauseIconPainter extends CustomPainter {
  const _PauseIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final barW = size.width * 0.12;
    final barH = size.height * 0.4;
    final gap = size.width * 0.08;
    final paint = Paint()..color = Colors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - gap - barW / 2, cy),
          width: barW,
          height: barH,
        ),
        const Radius.circular(1),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + gap + barW / 2, cy),
          width: barW,
          height: barH,
        ),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StepForwardIconPainter extends CustomPainter {
  const _StepForwardIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()..color = Colors.black;
    // triangle + bar (StepForwardButton convention)
    final tri = Path()
      ..moveTo(cx - size.width * 0.18, cy - size.height * 0.28)
      ..lineTo(cx - size.width * 0.18, cy + size.height * 0.28)
      ..lineTo(cx + size.width * 0.12, cy)
      ..close();
    canvas.drawPath(tri, paint);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx + size.width * 0.2, cy),
        width: size.width * 0.08,
        height: size.height * 0.5,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// PhET `StopwatchNode` approx — shaded body, readout, Reset + Play/Pause.
///
/// Source: scenery-phet `StopwatchNode.ts` (includePlayPauseResetButtons).
/// Logic unchanged: toggle [ClbModel.stopwatchRunning], zero time, toolbox return.
class ClbStopwatchNode extends StatelessWidget {
  const ClbStopwatchNode({
    super.key,
    required this.model,
    required this.onDragEnd,
  });

  final ClbModel model;
  final VoidCallback onDragEnd;

  static const Color _body = Color(0xFFE8E8E8);
  static const Color _bodyDark = Color(0xFFB0B0B0);
  static const Color _button = Color(0xFFFED700);

  String get _formatted {
    final t = model.stopwatchTime;
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toStringAsFixed(1).padLeft(4, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) {
        model.stopwatchX += d.delta.dx;
        model.stopwatchY += d.delta.dy;
        model.notifyViewChanged();
      },
      onPanEnd: (_) => onDragEnd(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_body, _bodyDark],
          ),
          border: Border.all(color: const Color(0xFF666666), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF444444)),
                ),
                child: Text(
                  _formatted,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF33FF66),
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RectIconButton(
                    enabled: model.stopwatchTime > 0,
                    onPressed: () {
                      model.stopwatchTime = 0;
                      model.stopwatchRunning = false;
                      model.notifyViewChanged();
                    },
                    semanticLabel: 'Reset',
                    painter: const _UTurnIconPainter(),
                  ),
                  const SizedBox(width: 6),
                  _RectIconButton(
                    enabled: true,
                    onPressed: () {
                      model.stopwatchRunning = !model.stopwatchRunning;
                      model.notifyViewChanged();
                    },
                    semanticLabel:
                        model.stopwatchRunning ? 'Pause' : 'Play',
                    painter: model.stopwatchRunning
                        ? const _PauseIconPainter()
                        : const _PlayIconPainter(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RectIconButton extends StatelessWidget {
  const _RectIconButton({
    required this.onPressed,
    required this.painter,
    required this.semanticLabel,
    required this.enabled,
  });

  final VoidCallback onPressed;
  final CustomPainter painter;
  final String semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: GestureDetector(
          onTap: enabled ? onPressed : null,
          child: Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: ClbStopwatchNode._button,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFF996600)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: CustomPaint(painter: painter),
          ),
        ),
      ),
    );
  }
}

class _UTurnIconPainter extends CustomPainter {
  const _UTurnIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(cx + 6, cy + 4)
      ..lineTo(cx + 6, cy - 2)
      ..arcToPoint(
        Offset(cx - 6, cy - 2),
        radius: const Radius.circular(6),
        clockwise: false,
      )
      ..lineTo(cx - 6, cy + 2);
    canvas.drawPath(path, paint);
    // arrow head
    canvas.drawPath(
      Path()
        ..moveTo(cx - 6, cy + 5)
        ..lineTo(cx - 9, cy + 1)
        ..lineTo(cx - 3, cy + 1)
        ..close(),
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
