import 'package:flutter/material.dart';

import '../../model/resistance_in_a_wire_model.dart';
import '../../resistance_in_a_wire_view_constants.dart';
import 'slider_unit.dart';
import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';

/// PhET `ControlPanel` — resistance readout + ρ / L / A slider units.
///
/// Readout `centerX` is fixed (issue #181) — value text does not re-layout the
/// panel while dragging.
class ResistanceInAWireControlPanel extends StatelessWidget {
  const ResistanceInAWireControlPanel({
    super.key,
    required this.model,
    this.resistivityFocusNode,
    this.lengthFocusNode,
    this.areaFocusNode,
    this.onKeyboardInteraction,
  });

  final ResistanceInAWireModel model;
  final FocusNode? resistivityFocusNode;
  final FocusNode? lengthFocusNode;
  final FocusNode? areaFocusNode;
  final VoidCallback? onKeyboardInteraction;

  @override
  Widget build(BuildContext context) {
    final formatted = model.getFormattedResistanceValue();
    // Source pattern: "resistance = {value} ohms" (plural "ohms", not Ω).
    final readout = RiawStrings.resistanceReadout(formatted);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ResistanceInAWireViewConstants.controlXMargin,
        vertical: ResistanceInAWireViewConstants.controlYMargin,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: ResistanceInAWireViewConstants.controlLineWidth,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed-width slot so changing digits do not jump the panel (issue #181).
          SizedBox(
            width: ResistanceInAWireViewConstants.sliderWidth * 4.5,
            child: Semantics(
              label: readout,
              liveRegion: true,
              child: Text(
                readout,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: ResistanceInAWireViewConstants.uiFontFamily,
                  fontSize: ResistanceInAWireViewConstants.readoutFontSize,
                  color: ResistanceInAWireViewConstants.red,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: ResistanceInAWireViewConstants.resistanceReadoutGap,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderUnit(
                key: const Key('riaw_resistivity_slider'),
                property: model.resistivityProperty,
                range: model.resistivityProperty.range,
                symbol: 'ρ',
                name: RiawStrings.resistivity,
                unit: 'Ωcm',
                semanticLabel: RiawStrings.semanticResistivity,
                keyboardStep: 0.05,
                shiftKeyboardStep: 0.01,
                focusNode: resistivityFocusNode,
                onKeyboardInteraction: onKeyboardInteraction,
              ),
              const SizedBox(
                width: ResistanceInAWireViewConstants.controlSliderSpacing,
              ),
              SliderUnit(
                key: const Key('riaw_length_slider'),
                property: model.lengthProperty,
                range: model.lengthProperty.range,
                symbol: 'L',
                name: RiawStrings.length,
                unit: 'cm',
                semanticLabel: RiawStrings.semanticLength,
                keyboardStep: 1,
                shiftKeyboardStep: 0.01,
                focusNode: lengthFocusNode,
                onKeyboardInteraction: onKeyboardInteraction,
              ),
              const SizedBox(
                width: ResistanceInAWireViewConstants.controlSliderSpacing,
              ),
              SliderUnit(
                key: const Key('riaw_area_slider'),
                property: model.areaProperty,
                range: model.areaProperty.range,
                symbol: 'A',
                name: RiawStrings.area,
                unit: 'cm²',
                unitIsRichText: true,
                semanticLabel: RiawStrings.semanticArea,
                keyboardStep: 1,
                shiftKeyboardStep: 0.01,
                focusNode: areaFocusNode,
                onKeyboardInteraction: onKeyboardInteraction,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
