import 'package:flutter/material.dart';

import '../../model/ohms_law_model.dart';
import '../../ohms_law_view_constants.dart';
import 'slider_unit.dart';

/// PhET `ControlPanel` — voltage + resistance slider units in a bordered panel.
class OhmsLawControlPanel extends StatelessWidget {
  const OhmsLawControlPanel({
    super.key,
    required this.model,
    this.voltageFocusNode,
    this.resistanceFocusNode,
  });

  final OhmsLawModel model;
  final FocusNode? voltageFocusNode;
  final FocusNode? resistanceFocusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OhmsLawViewConstants.controlXMargin,
        vertical: OhmsLawViewConstants.controlYMargin,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: OhmsLawViewConstants.controlLineWidth,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SliderUnit(
            key: const Key('ohms_law_voltage_slider'),
            property: model.voltageProperty,
            range: model.voltageProperty.range,
            symbol: 'V',
            name: 'voltage',
            unit: 'V',
            decimalPlaces: 1,
            semanticLabel: 'Voltage',
            // ControlPanel.js: keyboardStep 0.5; SliderUnit default shift 0.1
            keyboardStep: 0.5,
            shiftKeyboardStep: 0.1,
            focusNode: voltageFocusNode,
          ),
          const SizedBox(width: OhmsLawViewConstants.controlSliderSpacing),
          SliderUnit(
            key: const Key('ohms_law_resistance_slider'),
            property: model.resistanceProperty,
            range: model.resistanceProperty.range,
            symbol: 'R',
            name: 'resistance',
            unit: 'Ω',
            decimalPlaces: 0,
            semanticLabel: 'Resistance',
            // ControlPanel.js: keyboardStep 20, shiftKeyboardStep 1
            keyboardStep: 20,
            shiftKeyboardStep: 1,
            focusNode: resistanceFocusNode,
          ),
        ],
      ),
    );
  }
}
