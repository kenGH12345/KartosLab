// Copyright 2024-2026, University of Colorado Boulder
/// P(symbol) with coin SVG or spin arrows (ProbabilityOfSymbolBox.ts).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/qct_assets.dart';
import '../../common/quantum_measurement_colors.dart';
import '../../common/quantum_measurement_strings.dart';

class ProbabilityOfSymbolBox extends StatelessWidget {
  const ProbabilityOfSymbolBox({
    super.key,
    required this.face,
    this.fontSize = 16,
    this.bold = true,
  });

  /// heads | tails | up | down
  final String face;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(QuantumMeasurementStrings.probabilityPrefix, style: style),
        Text('(', style: style),
        _FaceSymbol(face: face, fontSize: fontSize, bold: bold),
        Text(')', style: style),
      ],
    );
  }
}

class _FaceSymbol extends StatelessWidget {
  const _FaceSymbol({
    required this.face,
    required this.fontSize,
    required this.bold,
  });

  final String face;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final iconHeight = fontSize * 1.15;
    switch (face) {
      case 'heads':
        return SvgPicture.asset(
          QctAssets.classicalCoinHeads,
          height: iconHeight,
        );
      case 'tails':
        return SvgPicture.asset(
          QctAssets.classicalCoinTails,
          height: iconHeight,
        );
      case 'up':
        return Text(
          QuantumMeasurementStrings.spinUpSymbol,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        );
      case 'down':
        return Text(
          QuantumMeasurementStrings.spinDownSymbol,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: QuantumMeasurementColors.downColor,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
