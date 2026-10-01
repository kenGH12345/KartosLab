import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../painters/composite_thermometer_painter.dart';
import '../som_strings.dart';

/// PhET `CompositeThermometerNode`: ComboBoxDisplay readout above ThermometerNode.
///
/// Column layout with spacing 10. Readout shows rounded Kelvin + [SomStrings.kelvinUnits]
/// (U+212A) inside a light ComboBoxDisplay-style box with dropdown arrow.
class CompositeThermometer extends StatelessWidget {
  const CompositeThermometer({
    super.key,
    required this.temperatureKelvin,
    this.width = 56,
  });

  final double? temperatureKelvin;
  final double width;

  static const double _readoutFontSize = 11;
  static const double _xMargin = 6;
  static const double _yMargin = 4;
  static const double _cornerRadius = 5;
  static const double _spacing = 10;

  @override
  Widget build(BuildContext context) {
    final painter = CompositeThermometerPainter(
      temperatureKelvin: temperatureKelvin,
    );
    final thermoSize = painter.intrinsicSize;

    // PhET ComboBoxDisplay: number + space + units (e.g. "14 K")
    final label = temperatureKelvin == null
        ? '—'
        : '${temperatureKelvin!.round()} ${SomStrings.kelvinUnits}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ComboBoxReadout(label: label),
        const SizedBox(height: _spacing),
        SizedBox(
          width: math.max(thermoSize.width, width * 0.6),
          height: thermoSize.height,
          child: CustomPaint(painter: painter),
        ),
      ],
    );
  }
}

/// Light ComboBoxDisplay chrome: value+units + dropdown chevron.
class _ComboBoxReadout extends StatelessWidget {
  const _ComboBoxReadout({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CompositeThermometer._xMargin,
        vertical: CompositeThermometer._yMargin,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius:
            BorderRadius.circular(CompositeThermometer._cornerRadius),
        border: Border.all(color: const Color(0xFF666666), width: 0.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 1.5,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: CompositeThermometer._readoutFontSize,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 4),
          CustomPaint(
            size: const Size(8, 5),
            painter: const _DropdownArrowPainter(),
          ),
        ],
      ),
    );
  }
}

class _DropdownArrowPainter extends CustomPainter {
  const _DropdownArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF333333));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
