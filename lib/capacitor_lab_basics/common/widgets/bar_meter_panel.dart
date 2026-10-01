import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../../clb_strings.dart';
import '../model/clb_model.dart';
import '../render/circuit_render_data.dart';

/// Capacitance / charge / energy bar meters — `BarMeterPanel.js`
///
/// Layout: checkbox + label | value text | bar (pico units ×1e12, 2 decimals).
class BarMeterPanel extends StatelessWidget {
  const BarMeterPanel({
    super.key,
    required this.model,
    required this.data,
  });

  final ClbModel model;
  final CircuitRenderData data;

  static const double minWidth = 580;
  static const double barMaxWidth = 220;
  static const double valueSlotWidth = 72;

  @override
  Widget build(BuildContext context) {
    if (!model.barGraphsVisible) {
      return const SizedBox.shrink();
    }

    return Material(
      color: ClbColors.meterPanelFill,
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: const BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(
              label: ClbStrings.capacitance,
              checked: model.capacitanceMeterVisible,
              onCheck: (v) => model.capacitanceMeter.visible = v,
              valueSi: data.capacitanceMeterValue,
              color: ClbColors.capacitance,
              showMeter: model.capacitanceMeterVisible,
              maxValue: ClbConstants.capacitanceMeterMaxValue,
              format: (pico) => ClbStrings.picoFaradsPattern(pico),
            ),
            const SizedBox(height: 8),
            _row(
              label: ClbStrings.topPlateCharge,
              checked: model.topPlateChargeMeterVisible,
              onCheck: (v) => model.plateChargeMeter.visible = v,
              valueSi: data.plateChargeMeterValue.abs(),
              color: ClbColors.positiveCharge,
              showMeter: model.topPlateChargeMeterVisible,
              maxValue: ClbConstants.plateChargeMeterMaxValue,
              format: (pico) => ClbStrings.picoCoulombsPattern(pico),
            ),
            const SizedBox(height: 8),
            _row(
              label: ClbStrings.storedEnergy,
              checked: model.storedEnergyMeterVisible,
              onCheck: (v) => model.storedEnergyMeter.visible = v,
              valueSi: data.storedEnergyMeterValue,
              color: ClbColors.storedEnergy,
              showMeter: model.storedEnergyMeterVisible,
              maxValue: ClbConstants.storedEnergyMeterMaxValue,
              format: (pico) => ClbStrings.picoJoulesPattern(pico),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required String label,
    required bool checked,
    required void Function(bool) onCheck,
    required double valueSi,
    required Color color,
    required bool showMeter,
    required double maxValue,
    required String Function(double pico) format,
  }) {
    final frac = maxValue == 0 ? 0.0 : (valueSi / maxValue).clamp(0.0, 1.0);
    final pico = valueSi * 1e12;
    final valueText = format(pico);

    return Row(
      children: [
        InkWell(
          onTap: () => onCheck(!checked),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87),
                    color: checked ? const Color(0xFF4A90D9) : Colors.white,
                  ),
                  child: checked
                      ? const CustomPaint(painter: _MiniCheckPainter())
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                child: Text(label, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: valueSlotWidth,
          child: showMeter
              ? Text(
                  valueText,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.right,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 7),
        if (showMeter)
          SizedBox(
            width: barMaxWidth,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                color: Colors.white,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: (barMaxWidth - 2) * frac,
                  height: 16,
                  color: color,
                ),
              ),
            ),
          )
        else
          const SizedBox(width: barMaxWidth, height: 18),
      ],
    );
  }
}

class _MiniCheckPainter extends CustomPainter {
  const _MiniCheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.42, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height * 0.28);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
