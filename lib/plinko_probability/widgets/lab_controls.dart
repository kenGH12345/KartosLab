import 'package:flutter/material.dart';

import '../controller/lab_controller.dart';
import '../model/plinko_common_model.dart';
import '../plinko_constants.dart';
import '../plinko_strings.dart';
import 'lab_right_panel_layout.dart';
import 'plinko_number_control.dart';

export 'statistics_accordion_box.dart';

/// Rows + Binary Probability — `PegControls.js`.
class PegControls extends StatelessWidget {
  const PegControls({
    super.key,
    required this.controller,
    this.layoutScale = 1.0,
  });

  final LabController controller;
  final double layoutScale;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final s = layoutScale;
    return Container(
      width: LabRightPanelLayout.panelFixedWidth * s,
      padding: EdgeInsets.symmetric(
        horizontal: LabRightPanelLayout.pegXMargin * s,
        vertical: LabRightPanelLayout.pegYMargin * s,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(LabRightPanelLayout.panelCornerRadius * s),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          PlinkoNumberControl(
            title: PlinkoStrings.rows,
            value: m.numberOfRows.toDouble(),
            min: PlinkoConstants.rowsMin.toDouble(),
            max: PlinkoConstants.rowsMax.toDouble(),
            step: 1,
            decimalPlaces: 0,
            titleYSpacing: 3,
            layoutScale: s,
            onChanged: (v) => controller.setNumberOfRows(v.round()),
          ),
          SizedBox(height: LabRightPanelLayout.pegVBoxSpacing * s),
          PlinkoNumberControl(
            title: PlinkoStrings.binaryProbability,
            value: m.probability,
            min: PlinkoConstants.binaryProbabilityMin,
            max: PlinkoConstants.binaryProbabilityMax,
            step: PlinkoConstants.binaryProbabilityStep,
            decimalPlaces: 2,
            titleYSpacing: 5,
            layoutScale: s,
            onChanged: controller.setProbability,
          ),
        ],
      ),
    );
  }
}

/// ball / path / none — `HopperModeControl.js` VerticalAquaRadioButtonGroup.
class HopperModeControl extends StatelessWidget {
  const HopperModeControl({super.key, required this.controller});

  final LabController controller;

  @override
  Widget build(BuildContext context) {
    final mode = controller.model.hopperMode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in const [
          (HopperMode.ball, PlinkoStrings.ball),
          (HopperMode.path, PlinkoStrings.path),
          (HopperMode.none, PlinkoStrings.none),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              onTap: () => controller.setHopperMode(entry.$1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mode == entry.$1
                          ? const Color(0xFFB3E5FC)
                          : Colors.white,
                      border: Border.all(width: 1.5),
                    ),
                    child: mode == entry.$1
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.$2,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Arial',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
