import 'package:flutter/material.dart';

import '../controller/intro_controller.dart';
import '../controller/lab_controller.dart';
import '../model/plinko_common_model.dart';
import '../plinko_assets.dart';
import '../plinko_colors.dart';
import 'lab_right_panel_layout.dart';
import 'plinko_chrome_buttons.dart';

/// Intro play panel: Play + vertical ×1 / ×10 / ×100 — `IntroPlayPanel.js`.
class IntroPlayPanel extends StatelessWidget {
  const IntroPlayPanel({
    super.key,
    required this.controller,
  });

  final IntroController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
      decoration: BoxDecoration(
        color: PlinkoColors.panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black87),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 20),
          PlinkoPlayButton(
            onPressed: m.isBallCapReached ? null : controller.play,
            enabled: !m.isBallCapReached,
          ),
          const SizedBox(width: 25),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _modeRadio(
                selected: m.ballMode == BallMode.oneBall,
                label: '×1',
                onTap: () => controller.setBallMode(BallMode.oneBall),
              ),
              const SizedBox(height: 10),
              _modeRadio(
                selected: m.ballMode == BallMode.tenBalls,
                label: '×10',
                onTap: () => controller.setBallMode(BallMode.tenBalls),
              ),
              const SizedBox(height: 10),
              _modeRadio(
                selected: m.ballMode == BallMode.maxBalls,
                label: '×100',
                onTap: () => controller.setBallMode(BallMode.maxBalls),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _modeRadio({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _aquaDot(selected),
          const SizedBox(width: 8),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: PlinkoColors.ball,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontFamily: 'Arial'),
          ),
        ],
      ),
    );
  }
}

Widget _aquaDot(bool selected) {
  // Approximate sun AquaRadioButton: light disk + dark selected center.
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: selected ? const Color(0xFFB3E5FC) : Colors.white,
      border: Border.all(color: Colors.black87, width: 1.5),
      boxShadow: selected
          ? const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 1,
                offset: Offset(0.5, 0.5),
              ),
            ]
          : null,
    ),
    child: selected
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
  );
}

/// Lab play panel: Play/Pause + vertical one/continuous — `LabPlayPanel.js`.
class LabPlayPanel extends StatelessWidget {
  const LabPlayPanel({
    super.key,
    required this.controller,
    this.layoutScale = 1.0,
  });

  final LabController controller;
  final double layoutScale;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final isContinuous = m.ballMode == BallMode.continuous;
    final showPause = isContinuous && m.isPlaying;
    final s = layoutScale;
    // BallNode = ShadedSphereNode(2 * BALL_RADIUS), BALL_RADIUS=8 → Ø16 layout.
    final ballD = 16 * s;

    return Container(
      width: LabRightPanelLayout.panelFixedWidth * s,
      padding: EdgeInsets.symmetric(
        horizontal: LabRightPanelLayout.playXMargin * s,
        vertical: LabRightPanelLayout.playYMargin * s,
      ),
      decoration: BoxDecoration(
        color: PlinkoColors.panelBackground,
        borderRadius:
            BorderRadius.circular(LabRightPanelLayout.panelCornerRadius * s),
        border: Border.all(color: Colors.black87),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          if (showPause)
            PlinkoPauseButton(
              onPressed: controller.pausePressed,
              radius: LabRightPanelLayout.playButtonRadius * s,
            )
          else
            PlinkoPlayButton(
              onPressed: m.isBallCapReached ? null : controller.playPressed,
              enabled: !m.isBallCapReached,
              radius: LabRightPanelLayout.playButtonRadius * s,
            ),
          SizedBox(width: LabRightPanelLayout.playHBoxSpacing * s),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labIconRadio(
                selected: m.ballMode == BallMode.oneBall,
                scale: s,
                child: _ShadedBall(diameter: ballD),
                onTap: () => controller.setBallMode(BallMode.oneBall),
              ),
              SizedBox(height: LabRightPanelLayout.playRadioSpacing * s),
              _labIconRadio(
                selected: isContinuous,
                scale: s,
                child: SizedBox(
                  width: ballD * 0.5 * 5 + 14 * s,
                  height: ballD,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var i = 0; i < 5; i++)
                        Positioned(
                          left: i * (ballD * 0.5),
                          child: _ShadedBall(diameter: ballD),
                        ),
                      Positioned(
                        left: 5 * (ballD * 0.5) + 8 * s, // HStrut(BALL_RADIUS)
                        top: ballD * 0.35,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < 3; i++)
                              Container(
                                width: 2 * s,
                                height: 2 * s,
                                margin: EdgeInsets.only(right: 2 * s),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => controller.setBallMode(BallMode.continuous),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _labIconRadio({
    required bool selected,
    required Widget child,
    required VoidCallback onTap,
    required double scale,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _aquaDotScaled(selected, scale),
          SizedBox(width: 8 * scale),
          child,
        ],
      ),
    );
  }
}

Widget _aquaDotScaled(bool selected, double scale) {
  // VerticalAquaRadioButtonGroup radioButtonOptions.radius = 8
  final d = LabRightPanelLayout.playRadioRadius * 2 * scale;
  return Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: selected ? const Color(0xFFB3E5FC) : Colors.white,
      border: Border.all(color: Colors.black87, width: 1),
    ),
    child: selected
        ? Center(
            child: Container(
              width: d * 0.4,
              height: d * 0.4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1565C0),
              ),
            ),
          )
        : null,
  );
}

/// PhET `BallNode` / `ShadedSphereNode` — red + white highlight.
class _ShadedBall extends StatelessWidget {
  const _ShadedBall({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: _ShadedBallPainter(),
    );
  }
}

class _ShadedBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(r, r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.95,
          colors: const [
            PlinkoColors.ballHighlight,
            PlinkoColors.ball,
            Color(0xFFB71C1C),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Histogram mode icons using original PNG assets.
class HistogramModeControl extends StatelessWidget {
  const HistogramModeControl({
    super.key,
    required this.mode,
    required this.modes,
    required this.onChanged,
  });

  final HistogramDisplayMode mode;
  final List<HistogramDisplayMode> modes;
  final ValueChanged<HistogramDisplayMode> onChanged;

  String _asset(HistogramDisplayMode m) {
    switch (m) {
      case HistogramDisplayMode.counter:
        return PlinkoAssets.counter;
      case HistogramDisplayMode.cylinder:
        return PlinkoAssets.cylinder;
      case HistogramDisplayMode.fraction:
        return PlinkoAssets.fraction;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final m in modes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () => onChanged(m),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: mode == m ? Colors.white : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: mode == m ? Colors.black : Colors.black45,
                    width: mode == m ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(_asset(m), fit: BoxFit.contain),
              ),
            ),
          ),
      ],
    );
  }
}
