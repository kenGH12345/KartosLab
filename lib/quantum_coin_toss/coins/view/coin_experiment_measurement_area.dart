// Copyright 2024-2026, University of Colorado Boulder
/// Right column: single + multiple coin measurements.
/// Matches CoinExperimentMeasurementArea.ts + official measurement-mode screenshots.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/model/experiment_measurement_state.dart';
import '../../common/model/system_type.dart';
import '../../common/qct_assets.dart';
import '../../common/quantum_measurement_colors.dart';
import '../../common/quantum_measurement_strings.dart';
import '../model/coins_experiment_scene_model.dart';
import 'classical_coin_node.dart';
import 'coin_experiment_button_set.dart';
import 'mini_coin.dart';
import 'quantum_coin_node.dart';
import 'scene_section_header.dart';

/// Official SingleCoinTestBox ≈ 165×145 with thick stroke.
const _singleBoxW = 165.0;
const _singleBoxH = 145.0;
const _singleStroke = 14.0;

/// Official MultiCoinTestBox = 200×200.
const _multiBoxSize = 200.0;

const _indicatorCoinRadius = 36.0;

class CoinExperimentMeasurementArea extends StatelessWidget {
  const CoinExperimentMeasurementArea({super.key, required this.scene});

  final CoinsExperimentSceneModel scene;

  @override
  Widget build(BuildContext context) {
    final isQuantum = scene.systemType == SystemType.quantum;
    final textColor = isQuantum
        ? QuantumMeasurementColors.quantumSceneText
        : QuantumMeasurementColors.classicalSceneText;

    return ListenableBuilder(
      listenable: Listenable.merge([
        scene.preparingExperimentProperty,
        scene.singleCoin.measurementStateProperty,
        scene.singleCoin.measuredValueProperty,
        scene.coinSet.measurementStateProperty,
        scene.coinSet.numberOfCoinsProperty,
        scene.coinSet.measuredDataChangedNotifier,
      ]),
      builder: (context, _) {
        final preparing = scene.preparingExperimentProperty.value;
        final coinsInTestBox = !preparing;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SceneSectionHeader(
                title: QuantumMeasurementStrings.singleCoinMeasurements,
                textColor: textColor,
                maxWidth: 360,
              ),
              const SizedBox(height: 16),
              _SingleCoinRow(
                scene: scene,
                isQuantum: isQuantum,
                preparing: preparing,
                coinsInTestBox: coinsInTestBox,
              ),
              const SizedBox(height: 36),
              SceneSectionHeader(
                title: QuantumMeasurementStrings.multipleCoinMeasurements,
                textColor: textColor,
                maxWidth: 360,
              ),
              const SizedBox(height: 16),
              _MultipleCoinRow(
                scene: scene,
                isQuantum: isQuantum,
                preparing: preparing,
                coinsInTestBox: coinsInTestBox,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Single ───────────────────────────────────────────────────────────────────

class _SingleCoinRow extends StatelessWidget {
  const _SingleCoinRow({
    required this.scene,
    required this.isQuantum,
    required this.preparing,
    required this.coinsInTestBox,
  });

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;
  final bool preparing;
  final bool coinsInTestBox;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SingleCoinTestBox(
          scene: scene,
          isQuantum: isQuantum,
          preparing: preparing,
        ),
        const SizedBox(width: 28),
        CoinExperimentButtonSet(
          coinSet: scene.singleCoin,
          coinsInTestBox: coinsInTestBox,
          visible: !preparing,
        ),
      ],
    );
  }
}

class _SingleCoinTestBox extends StatelessWidget {
  const _SingleCoinTestBox({
    required this.scene,
    required this.isQuantum,
    required this.preparing,
  });

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;
  final bool preparing;

  bool get _revealed =>
      !preparing &&
      scene.singleCoin.measurementStateProperty.value ==
          ExperimentMeasurementState.revealed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _singleBoxW,
      height: _singleBoxH,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: QuantumMeasurementColors.testBoxRectangleStroke,
          width: _singleStroke,
        ),
      ),
      child: preparing
          ? _HazeOverlay(isQuantum: isQuantum)
          : Stack(
              alignment: Alignment.center,
              children: [
                _MeasuredCoin(scene: scene, isQuantum: isQuantum),
                if (!_revealed) _HazeOverlay(isQuantum: isQuantum),
                if (!_revealed) const _MaskedCoinDisk(),
              ],
            ),
    );
  }
}

class _HazeOverlay extends StatelessWidget {
  const _HazeOverlay({required this.isQuantum});
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              QuantumMeasurementColors.testBoxGradientStart,
              isQuantum
                  ? const Color(0xCCBAE3E0)
                  : QuantumMeasurementColors.testBoxGradientEnd,
            ],
          ),
        ),
      ),
    );
  }
}

class _MaskedCoinDisk extends StatelessWidget {
  const _MaskedCoinDisk();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _indicatorCoinRadius * 2.05,
      height: _indicatorCoinRadius * 2.05,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: QuantumMeasurementColors.maskedFill,
        border: Border.all(
          color: QuantumMeasurementColors.coinStroke,
          width: 6,
        ),
      ),
    );
  }
}

class _MeasuredCoin extends StatefulWidget {
  const _MeasuredCoin({required this.scene, required this.isQuantum});

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;

  @override
  State<_MeasuredCoin> createState() => _MeasuredCoinState();
}

class _MeasuredCoinState extends State<_MeasuredCoin> {
  late final ValueNotifier<bool> _showSuperposition;
  late final ValueNotifier<double> _probability;

  @override
  void initState() {
    super.initState();
    _showSuperposition = ValueNotifier(false);
    _probability = ValueNotifier(_probFromState());
    widget.scene.singleCoin.measuredValueProperty.addListener(_sync);
  }

  @override
  void dispose() {
    widget.scene.singleCoin.measuredValueProperty.removeListener(_sync);
    _showSuperposition.dispose();
    _probability.dispose();
    super.dispose();
  }

  void _sync() => _probability.value = _probFromState();

  double _probFromState() =>
      widget.scene.singleCoin.measuredValueProperty.value == 'up' ? 1.0 : 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.isQuantum) {
      return QuantumCoinNode(
        coinStateNotifier: widget.scene.singleCoin.measuredValueProperty,
        stateProbabilityNotifier: _probability,
        radius: _indicatorCoinRadius,
        showSuperpositionNotifier: _showSuperposition,
      );
    }
    return ClassicalCoinNode(
      coinStateNotifier: widget.scene.singleCoin.measuredValueProperty,
      radius: _indicatorCoinRadius,
    );
  }
}

// ── Multiple ─────────────────────────────────────────────────────────────────

class _MultipleCoinRow extends StatelessWidget {
  const _MultipleCoinRow({
    required this.scene,
    required this.isQuantum,
    required this.preparing,
    required this.coinsInTestBox,
  });

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;
  final bool preparing;
  final bool coinsInTestBox;

  @override
  Widget build(BuildContext context) {
    if (preparing) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MultiTestBoxShell(
            hazy: true,
            isQuantum: isQuantum,
            child: const SizedBox.shrink(),
          ),
          const SizedBox(width: 28),
          _IdenticalCoinsSelector(scene: scene),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MultiTestBoxShell(
          hazy: scene.coinSet.measurementStateProperty.value !=
              ExperimentMeasurementState.revealed,
          isQuantum: isQuantum,
          child: _CoinGrid(scene: scene, isQuantum: isQuantum),
        ),
        const SizedBox(width: 24),
        _CoinHistogram(scene: scene, isQuantum: isQuantum),
        const SizedBox(width: 24),
        CoinExperimentButtonSet(
          coinSet: scene.coinSet,
          coinsInTestBox: coinsInTestBox,
          visible: true,
        ),
      ],
    );
  }
}

class _MultiTestBoxShell extends StatelessWidget {
  const _MultiTestBoxShell({
    required this.child,
    required this.hazy,
    required this.isQuantum,
  });

  final Widget child;
  final bool hazy;
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _multiBoxSize,
      height: _multiBoxSize,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: QuantumMeasurementColors.testBoxRectangleStroke,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          if (hazy)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0x99EEEEEE),
                        isQuantum
                            ? const Color(0x99CCEAE8)
                            : const Color(0x99BAE3E0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IdenticalCoinsSelector extends StatelessWidget {
  const _IdenticalCoinsSelector({required this.scene});

  final CoinsExperimentSceneModel scene;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scene.coinSet.numberOfCoinsProperty,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              QuantumMeasurementStrings.identicalCoins,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            for (final count in multiCoinExperimentQuantities)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: InkWell(
                  onTap: () =>
                      scene.coinSet.numberOfCoinsProperty.value = count,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AquaDot(
                        selected:
                            scene.coinSet.numberOfCoinsProperty.value == count,
                      ),
                      const SizedBox(width: 8),
                      Text('$count', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AquaDot extends StatelessWidget {
  const _AquaDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF0094BD) : Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: selected
          ? const Center(
              child: CircleAvatar(radius: 3.5, backgroundColor: Colors.white),
            )
          : null,
    );
  }
}

class _CoinGrid extends StatelessWidget {
  const _CoinGrid({required this.scene, required this.isQuantum});

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    final count = scene.coinSet.numberOfCoinsProperty.value;
    final revealed = scene.coinSet.measurementStateProperty.value ==
        ExperimentMeasurementState.revealed;

    if (count >= 10000) {
      return _PixelBlock(scene: scene, isQuantum: isQuantum, revealed: revealed);
    }

    // Official: N=10 → 5×2, N=100 → 10×10
    final cols = count <= 10 ? 5 : 10;
    final cell = (_multiBoxSize - 16) / cols;
    final radius = count <= 10 ? cell * 0.38 : cell * 0.36;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: count,
        itemBuilder: (context, i) {
          if (!revealed) {
            return MiniCoin(
              value: 'hidden',
              radius: radius,
              isQuantum: isQuantum,
            );
          }
          final value = i < scene.coinSet.measuredValues.length
              ? scene.coinSet.measuredValues[i]
              : (isQuantum ? 'up' : 'heads');
          return MiniCoin(
            value: value,
            radius: radius,
            isQuantum: isQuantum,
          );
        },
      ),
    );
  }
}

class _PixelBlock extends StatelessWidget {
  const _PixelBlock({
    required this.scene,
    required this.isQuantum,
    required this.revealed,
  });

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    if (!revealed) {
      return const SizedBox.expand();
    }
    final values = scene.coinSet.measuredValues;
    final n = scene.coinSet.numberOfCoinsProperty.value;
    final v0 = scene.coinSet.validValues[0];
    final count0 = values.take(n).where((v) => v == v0).length;
    final frac0 = n > 0 ? count0 / n : 0.5;

    return Column(
      children: [
        Expanded(
          flex: (frac0 * 1000).round().clamp(1, 1000),
          child: ColoredBox(
            color: isQuantum
                ? QuantumMeasurementColors.upColor
                : QuantumMeasurementColors.headsColor,
          ),
        ),
        Expanded(
          flex: ((1 - frac0) * 1000).round().clamp(1, 1000),
          child: ColoredBox(
            color: isQuantum
                ? QuantumMeasurementColors.downColor
                : QuantumMeasurementColors.tailsColor,
          ),
        ),
      ],
    );
  }
}

/// Histogram matching CoinMeasurementHistogram.ts (N=…, two bars, face icons).
class _CoinHistogram extends StatelessWidget {
  const _CoinHistogram({required this.scene, required this.isQuantum});

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    final count = scene.coinSet.numberOfCoinsProperty.value;
    final revealed = scene.coinSet.measurementStateProperty.value ==
        ExperimentMeasurementState.revealed;
    final values = scene.coinSet.measuredValues.take(count);
    final v0 = scene.coinSet.validValues[0];
    final v1 = scene.coinSet.validValues[1];
    final left = revealed ? values.where((v) => v == v0).length : 0;
    final right = revealed ? values.where((v) => v == v1).length : 0;
    final maxCount = count > 0 ? count : 1;

    final leftColor = isQuantum
        ? QuantumMeasurementColors.upColor
        : QuantumMeasurementColors.headsColor;
    final rightColor = isQuantum
        ? QuantumMeasurementColors.downColor
        : QuantumMeasurementColors.tailsColor;

    return SizedBox(
      width: 200,
      height: 160,
      child: Column(
        children: [
          Text(
            QuantumMeasurementStrings.numberOfCoinsLabel(count),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _HistBar(
                    count: left,
                    maxCount: maxCount,
                    color: leftColor,
                    label: _AxisIcon(isQuantum: isQuantum, left: true),
                  ),
                ),
                SizedBox(
                  width: 18,
                  child: CustomPaint(painter: _AxisTicksPainter()),
                ),
                Expanded(
                  child: _HistBar(
                    count: right,
                    maxCount: maxCount,
                    color: rightColor,
                    label: _AxisIcon(isQuantum: isQuantum, left: false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistBar extends StatelessWidget {
  const _HistBar({
    required this.count,
    required this.maxCount,
    required this.color,
    required this.label,
  });

  final int count;
  final int maxCount;
  final Color color;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    final frac = maxCount == 0 ? 0.0 : count / maxCount;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: frac.clamp(0.0, 1.0),
              widthFactor: 0.55,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        label,
      ],
    );
  }
}

class _AxisIcon extends StatelessWidget {
  const _AxisIcon({required this.isQuantum, required this.left});

  final bool isQuantum;
  final bool left;

  @override
  Widget build(BuildContext context) {
    if (isQuantum) {
      final up = left;
      return Text(
        up
            ? QuantumMeasurementStrings.spinUpSymbol
            : QuantumMeasurementStrings.spinDownSymbol,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: up
              ? QuantumMeasurementColors.upColor
              : QuantumMeasurementColors.downColor,
        ),
      );
    }
    return SizedBox(
      width: 22,
      height: 22,
      child: SvgPicture.asset(
        left ? QctAssets.classicalCoinHeads : QctAssets.classicalCoinTails,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AxisTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;
    final x = size.width / 2;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (final t in [0.0, 0.5, 1.0]) {
      final y = size.height * (1 - t);
      canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
