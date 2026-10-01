import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../curve_fitting_constants.dart';
import '../curve_fitting_strings.dart';
import '../format_number.dart';
import '../model/curve_fitting_model.dart';
import 'barometer_widget.dart';
import 'view_options_panel.dart';

/// χ² / r² deviations accordion — PhET `DeviationsAccordionBox`.
class DeviationsPanel extends StatelessWidget {
  const DeviationsPanel({super.key, required this.model});

  final CurveFittingModel model;

  @override
  Widget build(BuildContext context) {
    final chi = model.curve.chiSquared;
    final r2 = model.curve.rSquared;
    final n = model.points.getRelevantPoints().length;
    final chiDisplay =
        math.min(chi, CurveFittingConstants.maxChiSquareDisplayValue);
    final chiOp =
        chi > CurveFittingConstants.maxChiSquareDisplayValue ? '>' : '=';
    final curveOn = model.curveVisible;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale barometers down when vertical space is tight.
        const designH = CurveFittingConstants.barometerAxisHeight;
        final available = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : designH + 120;
        // Title + readouts + info ≈ 120; barometers need designH.
        final forBars = math.max(80.0, available - 120);
        final scale = (forBars / designH).clamp(0.35, 1.0);

        return CfPanelChrome(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () =>
                    model.setDeviationsExpanded(!model.deviationsExpanded),
                child: Row(
                  children: [
                    Icon(
                      model.deviationsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        CurveFittingStrings.deviations,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (model.deviationsExpanded) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BarometerWidget.chiSquared(
                      chiSquared: chi,
                      numberOfPoints: n,
                      fillVisible: curveOn,
                      scale: scale,
                    ),
                    BarometerWidget.rSquared(
                      rSquared: r2,
                      fillVisible: curveOn,
                      scale: scale,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ValueReadout(
                        label: 'X² $chiOp',
                        valueText: curveOn ? formatNumber(chiDisplay, 2) : '',
                        showValue: curveOn,
                      ),
                    ),
                    Expanded(
                      child: _ValueReadout(
                        label: 'r² =',
                        valueText: (!curveOn || r2.isNaN)
                            ? ''
                            : formatNumber(r2, 2),
                        showValue: curveOn && !r2.isNaN,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    tooltip: 'Info',
                    icon: const Icon(Icons.info_outline, size: 22),
                    color: const Color.fromRGBO(44, 107, 159, 1),
                    onPressed: () => _showChiInfo(context),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showChiInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reduced χ²'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(CurveFittingStrings.theReducedChiSquaredStatisticIs),
              const SizedBox(height: 8),
              const Text(
                'X_r² = 1/(N − f) · Σ [y(x_i) − y_i]² / σ_i²',
                style: TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(CurveFittingStrings.nEqualsNumberOfDataPointsPattern()),
              const SizedBox(height: 4),
              Text(CurveFittingStrings.fEqualsNumberOfParametersPattern()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ValueReadout extends StatelessWidget {
  const _ValueReadout({
    required this.label,
    required this.valueText,
    required this.showValue,
  });

  final String label;
  final String valueText;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(CurveFittingConstants.panelCornerRadius),
            border: Border.all(color: Colors.black26),
          ),
          child: Text(
            showValue ? valueText : ' ',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
