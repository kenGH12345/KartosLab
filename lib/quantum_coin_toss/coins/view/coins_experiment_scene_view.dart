// Copyright 2024-2026, University of Colorado Boulder
/// One classical or quantum scene (CoinsExperimentSceneView.ts).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/model/system_type.dart';
import '../../common/quantum_measurement_colors.dart';
import '../../common/quantum_measurement_strings.dart';
import '../model/coins_experiment_scene_model.dart';
import 'coin_experiment_measurement_area.dart';
import 'coin_experiment_preparation_area.dart';

const _prepDividerFraction = 0.38;
const _measureDividerFraction = 0.20;

class CoinsExperimentSceneView extends StatefulWidget {
  const CoinsExperimentSceneView({super.key, required this.scene});

  final CoinsExperimentSceneModel scene;

  @override
  State<CoinsExperimentSceneView> createState() =>
      _CoinsExperimentSceneViewState();
}

class _CoinsExperimentSceneViewState extends State<CoinsExperimentSceneView>
    with SingleTickerProviderStateMixin {
  late AnimationController _dividerController;
  late Animation<double> _dividerAnimation;

  @override
  void initState() {
    super.initState();
    _dividerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _dividerAnimation = CurvedAnimation(
      parent: _dividerController,
      curve: Curves.easeOutCubic,
    );
    _syncDividerAnimation(jump: true);
    widget.scene.preparingExperimentProperty.addListener(_onPreparingChanged);
  }

  @override
  void didUpdateWidget(covariant CoinsExperimentSceneView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene) {
      oldWidget.scene.preparingExperimentProperty
          .removeListener(_onPreparingChanged);
      widget.scene.preparingExperimentProperty.addListener(_onPreparingChanged);
      _syncDividerAnimation(jump: true);
    }
  }

  @override
  void dispose() {
    widget.scene.preparingExperimentProperty.removeListener(_onPreparingChanged);
    _dividerController.dispose();
    super.dispose();
  }

  void _onPreparingChanged() {
    _syncDividerAnimation(jump: false);
    setState(() {});
  }

  void _syncDividerAnimation({required bool jump}) {
    final preparing = widget.scene.preparingExperimentProperty.value;
    if (jump) {
      _dividerController.value = preparing ? 0.0 : 1.0;
    } else if (preparing) {
      _dividerController.reverse();
    } else {
      _dividerController.forward();
    }
  }

  double _dividerFraction(double t) {
    return _prepDividerFraction +
        (_measureDividerFraction - _prepDividerFraction) * t;
  }

  @override
  Widget build(BuildContext context) {
    final isQuantum = widget.scene.systemType == SystemType.quantum;
    final bg = isQuantum
        ? QuantumMeasurementColors.quantumSceneBackground
        : QuantumMeasurementColors.classicalSceneBackground;
    final preparing = widget.scene.preparingExperimentProperty.value;

    return ColoredBox(
      color: bg,
      // Force the scene to fill the parent. A Stack of only Positioned
      // children otherwise collapses when a non-positioned shrink sneaks in.
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _dividerAnimation,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                if (!width.isFinite ||
                    !height.isFinite ||
                    width <= 0 ||
                    height <= 0) {
                  return const SizedBox.shrink();
                }

                final dividerX =
                    width * _dividerFraction(_dividerAnimation.value);
                final leftWidth = dividerX.clamp(120.0, width - 160.0);
                final rightWidth = (width - leftWidth).clamp(160.0, width);

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // ── Left: preparation ──
                    Positioned(
                      left: 0,
                      top: 0,
                      width: leftWidth,
                      height: height,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 72),
                        child: CoinExperimentPreparationArea(
                          scene: widget.scene,
                        ),
                      ),
                    ),
                    // ── Right: measurement (explicit width — never depend on
                    // Stack.size via Positioned(right:0) alone) ──
                    Positioned(
                      left: leftWidth,
                      top: 0,
                      width: rightWidth,
                      height: height,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 72),
                        child: CoinExperimentMeasurementArea(
                          scene: widget.scene,
                        ),
                      ),
                    ),
                    // ── Dashed divider ──
                    Positioned(
                      left: leftWidth - 1,
                      top: 24,
                      bottom: 24,
                      child: CustomPaint(
                        size: Size(2, height),
                        painter: const _DashedDividerPainter(),
                      ),
                    ),
                    // ── Start measurement arrow (prep mode only) ──
                    if (preparing)
                      Positioned(
                        left: leftWidth - 36,
                        top: math.min(245, height * 0.38),
                        child: _StartMeasurementButton(
                          onPressed: () {
                            widget.scene.preparingExperimentProperty.value =
                                false;
                          },
                        ),
                      ),
                    // ── New Coin under left column (measurement mode) ──
                    if (!preparing)
                      Positioned(
                        left: 8,
                        width: leftWidth - 16,
                        top: height * 0.55,
                        child: Center(
                          child: _NewCoinButton(
                            onPressed: () {
                              widget.scene.preparingExperimentProperty.value =
                                  true;
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StartMeasurementButton extends StatelessWidget {
  const _StartMeasurementButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: QuantumMeasurementColors.startMeasurementButton,
      borderRadius: BorderRadius.circular(4),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: const SizedBox(
          width: 72,
          height: 40,
          child: CustomPaint(painter: _RightArrowPainter()),
        ),
      ),
    );
  }
}

class _NewCoinButton extends StatelessWidget {
  const _NewCoinButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: QuantumMeasurementColors.newCoinButton,
      borderRadius: BorderRadius.circular(4),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            QuantumMeasurementStrings.newCoin,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = QuantumMeasurementColors.dividerLineStroke
      ..strokeWidth = 2;
    const dash = 6.0;
    const gap = 5.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, math.min(y + dash, size.height)),
        paint,
      );
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RightArrowPainter extends CustomPainter {
  const _RightArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cy = size.height / 2;
    const shaftLeft = 10.0;
    final tipX = size.width - 10;
    canvas.drawLine(Offset(shaftLeft, cy), Offset(tipX - 14, cy), paint);

    final path = Path()
      ..moveTo(tipX, cy)
      ..lineTo(tipX - 18, cy - 12)
      ..lineTo(tipX - 18, cy + 12)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
