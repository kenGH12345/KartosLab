/// Classical coin visual -?original SVG assets + CoinNode crossfade.
/// Embeds QCT CoinNode primitive; assets from QM path (same PhET originals).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kratos/quantum_coin_toss/coins/view/coin_node.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../qm_assets.dart';

class ClassicalCoinDisplay extends StatefulWidget {
  const ClassicalCoinDisplay({
    super.key,
    required this.face,
    required this.radius,
    this.revealed = true,
  });

  /// 'heads' | 'tails'
  final ValueListenable<String> face;
  final double radius;
  final bool revealed;

  @override
  State<ClassicalCoinDisplay> createState() => _ClassicalCoinDisplayState();
}

class _ClassicalCoinDisplayState extends State<ClassicalCoinDisplay> {
  late final ValueNotifier<double> _crossFade;

  @override
  void initState() {
    super.initState();
    _crossFade = ValueNotifier(_fade());
    widget.face.addListener(_sync);
  }

  void _sync() => _crossFade.value = _fade();

  double _fade() => widget.face.value == 'heads' ? 1.0 : 0.0;

  @override
  void dispose() {
    widget.face.removeListener(_sync);
    _crossFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.revealed) {
      return Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: QuantumMeasurementColors.maskedFill,
          border: Border.all(color: QuantumMeasurementColors.coinStroke, width: 2),
        ),
      );
    }

    return CoinNode(
      radius: widget.radius,
      crossFadeNotifier: _crossFade,
      coinFaceParameters: [
        CoinFaceParameters(
          fill: QuantumMeasurementColors.headsFill,
          stroke: QuantumMeasurementColors.headsColor,
          content: SvgPicture.asset(QmAssets.classicalCoinHeads),
          minYMarginFactor: 0.35,
        ),
        CoinFaceParameters(
          fill: QuantumMeasurementColors.tailsFill,
          stroke: QuantumMeasurementColors.tailsColor,
          content: SvgPicture.asset(QmAssets.classicalCoinTails),
          minYMarginFactor: 0.3,
        ),
      ],
    );
  }
}
