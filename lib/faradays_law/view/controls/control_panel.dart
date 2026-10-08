import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../faradays_law_constants.dart';
import '../../model/faradays_law_model.dart';
import 'coil_radio_group.dart';
import 'fl_phet_checkbox.dart';
import 'flip_magnet_button.dart';
import 'package:kratos/faradays_law/faradays_law_strings.dart';

/// Bottom control strip — `ControlPanelNode.js`.
///
/// Layout coords (source):
/// - strip bottom = layout.maxY - 10 = 494
/// - checkboxes x = 174
/// - coil radios left = 377
/// - flip right = maxX - 110
/// - reset right = maxX - 10, scale 0.75
class FaradaysLawControlPanel extends StatelessWidget {
  const FaradaysLawControlPanel({
    super.key,
    required this.model,
  });

  final FaradaysLawModel model;

  static const double _stripBottom = 504 - 10; // maxY - 10

  @override
  Widget build(BuildContext context) {
    // Coil radio approximate height ~80; center near strip bottom - 40
    const coilCenterY = _stripBottom - 40.0;
    const voltmeterCenterY = coilCenterY - 20;
    const fieldLinesCenterY = coilCenterY + 20;

    return Stack(
      children: [
        // Voltmeter checkbox
        Positioned(
          left: 174,
          top: voltmeterCenterY - 14,
          child: FlLabeledCheckbox(
            key: const Key('faradays_law_voltmeter_checkbox'),
            label: FaradaysLawStrings.voltmeter,
            value: model.voltmeterVisible,
            onChanged: model.setVoltmeterVisible,
          ),
        ),

        // Field Lines checkbox
        Positioned(
          left: 174,
          top: fieldLinesCenterY - 14,
          child: FlLabeledCheckbox(
            key: const Key('faradays_law_field_lines_checkbox'),
            label: FaradaysLawStrings.fieldLines,
            value: model.magnet.fieldLinesVisible,
            onChanged: model.setFieldLinesVisible,
          ),
        ),

        // Coil mode radios
        Positioned(
          left: 377,
          bottom: 504 - _stripBottom,
          child: CoilRadioGroup(
            topCoilVisible: model.topCoilVisible,
            onChanged: model.setTopCoilVisible,
          ),
        ),

        // Flip Magnet — right = 834 - 110 = 724
        Positioned(
          right: 834 - 724,
          bottom: 504 - _stripBottom,
          child: FlipMagnetButton(onPressed: model.flipPolarity),
        ),

        // Reset All — right = 834 - 10, scale 0.75 → radius 20.5 * 0.75
        Positioned(
          right: 10,
          bottom: 504 - _stripBottom,
          child: KratosResetAllButton(
            key: const Key('faradays_law_reset_all'),
            radius: 20.5 * FaradaysLawConstants.resetAllButtonScale,
            onPressed: model.reset,
          ),
        ),
      ],
    );
  }
}
