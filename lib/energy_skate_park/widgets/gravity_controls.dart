import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/model/gravity_magnitude.dart';

/// EnergySkateParkGravityControls.ts — slider and/or NumberControl + ComboBox.
///
/// - Intro: slider only (`includeGravitySlider`)
/// - Measure/Graphs/Playground: NumberControl (value + slider) + ComboBox
///   with Custom when magnitude ∉ {Moon, Earth, Jupiter}
class GravityControls extends StatelessWidget {
  const GravityControls({
    super.key,
    required this.controller,
    this.showCombo = false,
    this.showValueDisplay = false,
    this.sliderOnly = false,
  });

  final EspController controller;

  /// GravityComboBox (Moon / Earth / Jupiter / Custom).
  final bool showCombo;

  /// NumberDisplay with 1 decimal (GravityNumberControl).
  final bool showValueDisplay;

  /// PhysicalSlider: no number readout (Intro).
  final bool sliderOnly;

  @override
  Widget build(BuildContext context) {
    final g = controller.model.gravityMagnitude;
    final showReadout = showValueDisplay && !sliderOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              EspStrings.gravity,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (showReadout) ...[
              const Spacer(),
              Text(
                GravityMagnitude.display(g),
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
        Slider(
          value: GravityMagnitude.clamp(g),
          min: EspConstants.gravityMagnitudeMin,
          max: EspConstants.gravityMagnitudeMax,
          // ~0.1 m/s² steps (NumberControl delta); drag still writes model.
          divisions: ((EspConstants.gravityMagnitudeMax -
                      EspConstants.gravityMagnitudeMin) /
                  EspConstants.gravityShiftInterval)
              .round(),
          label: GravityMagnitude.display(g),
          onChanged: (v) =>
              controller.setGravityMagnitude(GravityMagnitude.roundFine(v)),
        ),
        if (!showCombo)
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(EspStrings.gravityTiny, style: TextStyle(fontSize: 11)),
                Text(EspStrings.gravityLots, style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        if (showCombo) ...[
          const SizedBox(height: 4),
          _GravityComboBox(
            magnitude: g,
            onPreset: controller.setGravityMagnitude,
          ),
        ],
      ],
    );
  }
}

/// PhysicalComboBox adapter: null display = Custom (does not write model).
class _GravityComboBox extends StatelessWidget {
  const _GravityComboBox({
    required this.magnitude,
    required this.onPreset,
  });

  final double magnitude;
  final ValueChanged<double> onPreset;

  @override
  Widget build(BuildContext context) {
    final adapter = GravityMagnitude.comboAdapterValue(magnitude);
    // DropdownButton cannot use null as selected when items include null
    // without careful typing — use sentinel -1 for Custom display.
    const customSentinel = -1.0;
    final value = adapter ?? customSentinel;

    return DropdownButton<double>(
      isExpanded: true,
      value: value,
      items: const [
        DropdownMenuItem(
          value: EspConstants.moonGravity,
          child: Text(EspStrings.moon),
        ),
        DropdownMenuItem(
          value: EspConstants.earthGravity,
          child: Text(EspStrings.earth),
        ),
        DropdownMenuItem(
          value: EspConstants.jupiterGravity,
          child: Text(EspStrings.jupiter),
        ),
        DropdownMenuItem(
          value: customSentinel,
          child: Text(EspStrings.gravityCustom),
        ),
      ],
      onChanged: (v) {
        // Selecting Custom does not change physicalProperty (PhysicalComboBox.ts:120).
        if (v == null || v == customSentinel) return;
        onPreset(v);
      },
    );
  }
}
