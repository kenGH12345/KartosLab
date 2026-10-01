// Copyright 2024-2026, University of Colorado Boulder
/// ClassicalCoinNode 渲染经典硬币（正面 Heads / 反面 Tails）
///
/// 对应官方：js/coins/view/ClassicalCoinNode.ts
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/qct_assets.dart';
import '../../common/quantum_measurement_colors.dart';
import 'coin_node.dart';

const _minMarginFactor = 0.35;
const _tailsMinYMarginFactor = 0.3;

class ClassicalCoinNode extends StatefulWidget {
  final ValueListenable<String> coinStateNotifier; // 'heads' | 'tails'
  final double radius;

  const ClassicalCoinNode({
    super.key,
    required this.coinStateNotifier,
    required this.radius,
  });

  @override
  State<ClassicalCoinNode> createState() => _ClassicalCoinNodeState();
}

class _ClassicalCoinNodeState extends State<ClassicalCoinNode> {
  late final ValueNotifier<double> _crossFade;

  @override
  void initState() {
    super.initState();
    _crossFade = ValueNotifier(_computeCrossFade());
    widget.coinStateNotifier.addListener(_updateCrossFade);
  }

  void _updateCrossFade() {
    _crossFade.value = _computeCrossFade();
  }

  double _computeCrossFade() {
    return widget.coinStateNotifier.value == 'heads' ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    widget.coinStateNotifier.removeListener(_updateCrossFade);
    _crossFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headsFace = CoinFaceParameters(
      fill: QuantumMeasurementColors.headsFill,
      stroke: QuantumMeasurementColors.headsColor,
      content: SvgPicture.asset(QctAssets.classicalCoinHeads),
      minYMarginFactor: _minMarginFactor,
    );

    final tailsFace = CoinFaceParameters(
      fill: QuantumMeasurementColors.tailsFill,
      stroke: QuantumMeasurementColors.tailsColor,
      content: SvgPicture.asset(QctAssets.classicalCoinTails),
      minYMarginFactor: _tailsMinYMarginFactor,
    );

    return CoinNode(
      radius: widget.radius,
      crossFadeNotifier: _crossFade,
      coinFaceParameters: [headsFace, tailsFace],
    );
  }
}
