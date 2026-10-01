import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../curve_fitting_strings.dart';
import '../format_number.dart';
import '../model/curve_fitting_model.dart';

/// Equation accordion on the graph — PhET `EquationAccordionBox`.
class EquationOverlay extends StatelessWidget {
  const EquationOverlay({super.key, required this.model});

  final CurveFittingModel model;

  /// Max digits per ascending coefficient — PhET `MAX_DIGITS`.
  static const maxDigits = [2, 3, 4, 4];

  @override
  Widget build(BuildContext context) {
    if (!model.curveVisible) return const SizedBox.shrink();

    final expanded = model.equationExpanded;
    final present = model.curve.isCurvePresent;

    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      borderRadius:
          BorderRadius.circular(CurveFittingConstants.panelCornerRadius),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () =>
                  model.setEquationExpanded(!model.equationExpanded),
              child: Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            if (!expanded)
              const Text(
                CurveFittingStrings.equation,
                style: TextStyle(fontSize: 14),
              )
            else if (!present)
              const Text(
                CurveFittingStrings.undefinedLabel,
                style: TextStyle(fontSize: 14),
              )
            else
              Flexible(child: _NumericEquation(model: model)),
          ],
        ),
      ),
    );
  }

  /// Round coeff to MAX_DIGITS semantics — returns (sign, absString).
  static (String, String) roundedParameterStrings(double number, int maxDig) {
    final abs = number.abs();
    if (abs == 0) {
      return ('+', toFixed(0, maxDig - 1));
    }
    final exponent = math.log(abs) / math.ln10;
    final expFloor = exponent.isFinite ? exponent.floor() : 0;
    late final int decimalPlaces;
    if (expFloor >= maxDig) {
      decimalPlaces = 0;
    } else if (expFloor > 0) {
      decimalPlaces = maxDig - expFloor - 1;
    } else {
      decimalPlaces = maxDig - 1;
    }
    final sign = number >= 0 ? '+' : '−';
    return (sign, toFixed(abs, decimalPlaces));
  }
}

class _NumericEquation extends StatelessWidget {
  const _NumericEquation({required this.model});

  final CurveFittingModel model;

  @override
  Widget build(BuildContext context) {
    final coeffs = model.curve.coefficients;
    final order = model.order;
    final spans = <InlineSpan>[
      const TextSpan(
        text: 'y = ',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
    ];

    // Render descending: highest power first
    for (var i = order; i >= 0; i--) {
      final c = i < coeffs.length ? coeffs[i] : 0.0;
      final (sign, absStr) = EquationOverlay.roundedParameterStrings(
        c,
        EquationOverlay.maxDigits[i],
      );
      if (i == order) {
        // Leading term: unary minus if negative, no plus
        if (sign == '−') {
          spans.add(const TextSpan(
            text: '−',
            style: TextStyle(fontSize: 14, color: CurveFittingColors.blue),
          ));
        }
        spans.add(TextSpan(
          text: absStr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CurveFittingColors.blue,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: ' $sign ',
          style: const TextStyle(fontSize: 14),
        ));
        spans.add(TextSpan(
          text: absStr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CurveFittingColors.blue,
          ),
        ));
      }
      if (i >= 2) {
        final sup = i == 2 ? '²' : '³';
        spans.add(TextSpan(
          text: ' x$sup',
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ));
      } else if (i == 1) {
        spans.add(const TextSpan(
          text: ' x',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
