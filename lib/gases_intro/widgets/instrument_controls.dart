import 'package:flutter/material.dart';

import '../gases_intro_constants.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/particle.dart';
import '../painters/gauge_painter.dart';
import '../painters/thermometer_painter.dart';
import '../view/view_interaction_state.dart';

export '../painters/gauge_painter.dart';
export '../painters/thermometer_painter.dart';

/// Port of ParticleTypeRadioButtonGroup — RectangularRadioButtonGroup horizontal.
class ParticleTypeRadioButtonGroup extends StatelessWidget {
  const ParticleTypeRadioButtonGroup({
    super.key,
    required this.model,
  });

  final IdealGasLawModel model;

  static const Color _base = Color(0xFF6D6E70); // radioButtonGroupBaseColor
  static const Color _selected = Color(0xFF69C3E7); // selectedStroke
  static const Color _deselected = Color(0xFFB0B0B0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _typeButton(
          kind: ParticleKind.heavy,
          color: const Color(GasesIntroConstants.heavyParticleColor),
          radiusPm: GasesIntroConstants.heavyRadius,
        ),
        const SizedBox(width: 8),
        _typeButton(
          kind: ParticleKind.light,
          color: const Color(GasesIntroConstants.lightParticleColor),
          radiusPm: GasesIntroConstants.lightRadius,
        ),
      ],
    );
  }

  Widget _typeButton({
    required ParticleKind kind,
    required Color color,
    required double radiusPm,
  }) {
    final selected = model.particleType == kind;
    final r = (radiusPm * GasesIntroConstants.mvtScale).clamp(6.0, 14.0);
    return Material(
      color: _base,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => model.setParticleType(kind),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? _selected : _deselected,
              width: selected ? 3 : 1.5,
            ),
          ),
          child: Container(
            width: r * 2,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                colors: [
                  Color.lerp(color, Colors.white, 0.55)!,
                  color,
                  Color.lerp(color, Colors.black, 0.35)!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// PressureGaugeNode = Gauge + PressureDisplay (ComboBoxDisplay units).
class PressureGaugeInstrument extends StatelessWidget {
  const PressureGaugeInstrument({
    super.key,
    required this.displayedKpa,
    required this.units,
    required this.onUnitsChanged,
  });

  final double displayedKpa;
  final PressureUnits units;
  final ValueChanged<PressureUnits> onUnitsChanged;

  @override
  Widget build(BuildContext context) {
    final atm = displayedKpa * GasesIntroConstants.atmPerKpa;
    final label = units == PressureUnits.atmospheres
        ? '${atm.toStringAsFixed(1)} atm'
        : '${displayedKpa.round()} kPa';

    // V5: face + combo follow parent Positioned width (anchors × layoutScale).
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 130.0;
        final faceH = (w * (100 / 130)).clamp(60.0, 100.0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: w,
              height: faceH,
              child: CustomPaint(
                painter: PressureGaugePainter(
                  displayedKpa: displayedKpa,
                  showValueText: false,
                ),
              ),
            ),
            _UnitsCombo<PressureUnits>(
              value: units,
              items: const [
                (PressureUnits.atmospheres, 'atm'),
                (PressureUnits.kilopascals, 'kPa'),
              ],
              displayText: label,
              onChanged: onUnitsChanged,
            ),
          ],
        );
      },
    );
  }
}

/// GasPropertiesThermometerNode = Thermometer + TemperatureDisplay.
class ThermometerInstrument extends StatelessWidget {
  const ThermometerInstrument({
    super.key,
    required this.temperatureK,
    required this.units,
    required this.onUnitsChanged,
  });

  final double? temperatureK;
  final TemperatureUnits units;
  final ValueChanged<TemperatureUnits> onUnitsChanged;

  @override
  Widget build(BuildContext context) {
    String label;
    if (temperatureK == null) {
      label = units == TemperatureUnits.kelvin ? '— K' : '— °C';
    } else if (units == TemperatureUnits.kelvin) {
      label = '${temperatureK!.round()} K';
    } else {
      label = '${(temperatureK! - 273.15).round()} °C';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _UnitsCombo<TemperatureUnits>(
          value: units,
          items: const [
            (TemperatureUnits.kelvin, 'K'),
            (TemperatureUnits.celsius, '°C'),
          ],
          displayText: label,
          onChanged: onUnitsChanged,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 36,
          height: 140,
          child: CustomPaint(
            painter: ThermometerPainter(temperatureK: temperatureK),
          ),
        ),
      ],
    );
  }
}

/// ComboBoxDisplay-like: shows value+units, opens list to change units.
class _UnitsCombo<T> extends StatelessWidget {
  const _UnitsCombo({
    required this.value,
    required this.items,
    required this.displayText,
    required this.onChanged,
  });

  final T value;
  final List<(T, String)> items;
  final String displayText;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      child: PopupMenuButton<T>(
        initialValue: value,
        padding: EdgeInsets.zero,
        onSelected: onChanged,
        itemBuilder: (context) => [
          for (final (v, u) in items)
            PopupMenuItem(
              value: v,
              child: Text(u, style: const TextStyle(fontSize: 13)),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: LayoutBuilder(
            builder: (context, c) {
              final bounded = c.maxWidth.isFinite;
              final label = Text(
                displayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              );
              return Row(
                mainAxisSize:
                    bounded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (bounded) Expanded(child: label) else label,
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: Colors.black54,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// GasPropertiesOopsDialog — OopsDialog + phetGirlLabCoat icon.
class GasPropertiesOopsDialog extends StatelessWidget {
  const GasPropertiesOopsDialog({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            color: Colors.white,
            elevation: 12,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/gases_intro/phetGirlLabCoat.png',
                        height: 132,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onDismiss,
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
