import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/masb_controller.dart';
import '../masb_constants.dart';
import '../model/spring.dart';
import '../transform/masb_coordinate_transform.dart';

/// PhET `TwoSpringScreenView.springSystemControlsNode`:
/// Spring Strength · Stopper · Hanger(1/2) · Stopper · Spring Strength
class SpringSystemControlsOverlay extends StatelessWidget {
  const SpringSystemControlsOverlay({
    super.key,
    required this.controller,
    required this.transform,
  });

  final MasbController controller;
  final MasbCoordinateTransform transform;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final springs = controller.model.springs;
        if (springs.isEmpty) return const SizedBox.shrink();

        final ceilingY = transform.modelToViewY(MasbConstants.ceilingY);
        // Keep the whole control cluster below the viewport top so Strength
        // titles are not clipped (panels must not sit above the hanger).
        const minTop = 12.0;
        final hangerTop = math.max(minTop, ceilingY - 10);

        if (springs.length == 1) {
          // Lab: hanger centered on spring X so the coil hangs under the bar.
          final x = transform.modelToViewX(springs.first.positionX);
          const hangerW = 48.0;
          const stopperSize = 36.0;
          const gap = 6.0;
          const panelW = 150.0;
          final hangerLeft = x - hangerW / 2;
          final panelTop = hangerTop;
          final stopperTop =
              math.max(minTop, hangerTop - (stopperSize - 20) / 2);

          return Positioned.fill(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: hangerLeft - gap - stopperSize - gap - panelW,
                  top: panelTop,
                  child: _SpringStrengthPanel(
                    controller: controller,
                    springIndex: 0,
                    title: 'Spring Strength',
                  ),
                ),
                Positioned(
                  left: hangerLeft - gap - stopperSize,
                  top: stopperTop,
                  child:
                      _StopperButton(controller: controller, springIndex: 0),
                ),
                Positioned(
                  left: hangerLeft,
                  top: hangerTop,
                  child: const _HangerBar(width: hangerW, labels: []),
                ),
              ],
            ),
          );
        }

        final x0 = transform.modelToViewX(springs[0].positionX);
        final x1 = transform.modelToViewX(springs[1].positionX);
        final mid = (x0 + x1) / 2;
        final sep = (x1 - x0).abs();
        final hangerW = math.max(56.0, sep * 1.4);
        final hangerLeft = mid - hangerW / 2;

        // Absolute anchors: labels 1/2 sit on spring X; panels flank the hanger.
        const stopperSize = 36.0;
        const gap = 6.0;
        const panelW = 150.0;
        // Same top band as hanger — do not offset panels upward (that caused clip).
        final panelTop = hangerTop;
        final stopperTop = math.max(minTop, hangerTop - (stopperSize - 20) / 2);

        return Positioned.fill(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: hangerLeft - gap - stopperSize - gap - panelW,
                top: panelTop,
                child: _SpringStrengthPanel(
                  controller: controller,
                  springIndex: 0,
                  title: 'Spring Strength 1',
                ),
              ),
              Positioned(
                left: hangerLeft - gap - stopperSize,
                top: stopperTop,
                child: _StopperButton(controller: controller, springIndex: 0),
              ),
              Positioned(
                left: hangerLeft,
                top: hangerTop,
                child: _HangerBar(
                  width: hangerW,
                  labels: const ['1', '2'],
                  labelFractions: _labelFractions(springs),
                ),
              ),
              Positioned(
                left: hangerLeft + hangerW + gap,
                top: stopperTop,
                child: _StopperButton(controller: controller, springIndex: 1),
              ),
              Positioned(
                left: hangerLeft + hangerW + gap + stopperSize + gap,
                top: panelTop,
                child: _SpringStrengthPanel(
                  controller: controller,
                  springIndex: 1,
                  title: 'Spring Strength 2',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Relative X of labels 1/2 within the 1.4×sep hanger (PhET SpringHangerNode).
  static List<double> _labelFractions(List<MasbSpring> springs) {
    final left = springs[0].positionX;
    final right = springs[1].positionX;
    final mid = (left + right) / 2;
    final sep = (right - left).abs();
    final hangerLeft = mid - sep * 0.7;
    final hangerW = sep * 1.4;
    if (hangerW <= 0) return const [0.25, 0.75];
    return [
      ((left - hangerLeft) / hangerW).clamp(0.05, 0.95),
      ((right - hangerLeft) / hangerW).clamp(0.05, 0.95),
    ];
  }
}

class _HangerBar extends StatelessWidget {
  const _HangerBar({
    required this.width,
    required this.labels,
    this.labelFractions = const [],
  });

  final double width;
  final List<String> labels;
  final List<double> labelFractions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFFB4B4B4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: labels.isEmpty
          ? null
          : Stack(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Positioned(
                    left: width *
                            (i < labelFractions.length
                                ? labelFractions[i]
                                : (i + 1) / (labels.length + 1)) -
                        5,
                    top: 1,
                    child: Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StopperButton extends StatelessWidget {
  const _StopperButton({
    required this.controller,
    required this.springIndex,
  });

  final MasbController controller;
  final int springIndex;

  @override
  Widget build(BuildContext context) {
    final active = controller.model.springs[springIndex].buttonEnabled;
    return Tooltip(
      message: 'Stop oscillation',
      child: Material(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: active ? () => controller.stopSpringAt(springIndex) : null,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.55),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Opacity(
              opacity: active ? 1 : 0.35,
              child: CustomPaint(
                size: const Size(22, 22),
                painter: _StopSignPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StopSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide / 2 * 0.95;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 8 + i * (math.pi / 4);
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE53935));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB71C1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Basics title: "Spring Strength N" — binds to that spring's k (3–12 N/m).
class _SpringStrengthPanel extends StatelessWidget {
  const _SpringStrengthPanel({
    required this.controller,
    required this.springIndex,
    required this.title,
  });

  final MasbController controller;
  final int springIndex;
  final String title;

  @override
  Widget build(BuildContext context) {
    final k = controller.model.springs[springIndex].springConstant;
    return Material(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
        child: SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                    disabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: const Color(0xFF00C4DF),
                  inactiveTrackColor: Colors.grey.shade400,
                  thumbColor: const Color(0xFF00C4DF),
                ),
                child: Slider(
                  value: k.clamp(
                    MasbConstants.springConstantMin,
                    MasbConstants.springConstantMax,
                  ),
                  min: MasbConstants.springConstantMin,
                  max: MasbConstants.springConstantMax,
                  divisions: 9,
                  onChanged: (v) =>
                      controller.setSpringConstantAt(springIndex, v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Small',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                  Text('Large',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
