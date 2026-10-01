/// Probability / result labels for prep and measurement areas.
/// Classical uses SVG face glyphs (ProbabilityOfSymbolBox.ts).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/system_type.dart';
import '../../qm_assets.dart';

class CoinResultDisplay extends StatelessWidget {
  const CoinResultDisplay({
    super.key,
    required this.systemType,
    required this.upProbability,
    this.fontSize = 14,
  });

  final SystemType systemType;
  final double upProbability;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final down = 1.0 - upProbability;
    final downColor = systemType == SystemType.classical
        ? QuantumMeasurementColors.tailsColor
        : QuantumMeasurementColors.downColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProbLine(
          systemType: systemType,
          isUp: true,
          value: upProbability,
          fontSize: fontSize,
        ),
        _ProbLine(
          systemType: systemType,
          isUp: false,
          value: down,
          fontSize: fontSize,
          color: downColor,
        ),
      ],
    );
  }
}

class _ProbLine extends StatelessWidget {
  const _ProbLine({
    required this.systemType,
    required this.isUp,
    required this.value,
    required this.fontSize,
    this.color,
  });

  final SystemType systemType;
  final bool isUp;
  final double value;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: fontSize, color: color ?? Colors.black);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('P(', style: style),
        if (systemType == SystemType.classical)
          SizedBox(
            width: fontSize + 2,
            height: fontSize + 2,
            child: SvgPicture.asset(
              isUp
                  ? QmAssets.classicalCoinHeads
                  : QmAssets.classicalCoinTails,
              fit: BoxFit.contain,
            ),
          )
        else
          Text(isUp ? '\u2191' : '\u2193', style: style),
        Text(') = ${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
