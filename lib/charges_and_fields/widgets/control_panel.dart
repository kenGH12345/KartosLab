import 'package:flutter/material.dart';

import '../caf_colors.dart';
import '../caf_constants.dart';
import '../caf_strings.dart';
import '../model/charges_and_fields_model.dart';

/// Upper-right control panel — ChargesAndFieldsControlPanel.
class CafControlPanel extends StatelessWidget {
  const CafControlPanel({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final ChargesAndFieldsModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CafColors.controlPanelFill,
        border: Border.all(
          color: CafColors.controlPanelBorder,
          width: CafConstants.panelLineWidth,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _check(
            CafStrings.electricField,
            model.isElectricFieldVisible,
            (v) {
              model.isElectricFieldVisible = v;
              onChanged();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: _check(
              CafStrings.directionOnly,
              model.isElectricFieldDirectionOnly,
              (v) {
                model.isElectricFieldDirectionOnly = v;
                onChanged();
              },
              enabled: model.isElectricFieldVisible,
            ),
          ),
          _check(
            CafStrings.voltage,
            model.isElectricPotentialVisible,
            (v) {
              model.isElectricPotentialVisible = v;
              onChanged();
            },
          ),
          _check(
            CafStrings.values,
            model.areValuesVisible,
            (v) {
              model.areValuesVisible = v;
              onChanged();
            },
          ),
          _check(
            CafStrings.grid,
            model.isGridVisible,
            (v) {
              model.isGridVisible = v;
              if (!v) model.snapToGrid = false;
              onChanged();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: _check(
              CafStrings.snapToGrid,
              model.snapToGrid,
              (v) {
                model.setSnapToGrid(v);
                onChanged();
              },
              enabled: model.isGridVisible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _check(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: Checkbox(
                  value: value,
                  onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                  side: const BorderSide(color: CafColors.checkbox, width: 1.5),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return CafColors.checkboxBackground;
                    }
                    return CafColors.checkboxBackground;
                  }),
                  checkColor: CafColors.checkbox,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: CafColors.controlPanelText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
