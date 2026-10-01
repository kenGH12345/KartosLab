import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../curve_fitting_strings.dart';
import '../model/curve_fitting_model.dart';

/// Curve / Residuals / Values — PhET `ViewOptionsPanel`.
class ViewOptionsPanel extends StatefulWidget {
  const ViewOptionsPanel({super.key, required this.model});

  final CurveFittingModel model;

  @override
  State<ViewOptionsPanel> createState() => ViewOptionsPanelState();
}

class ViewOptionsPanelState extends State<ViewOptionsPanel> {
  /// Saved residuals visibility while curve is off — PhET `wereResidualsVisible`.
  bool wereResidualsVisible = false;

  void reset() {
    wereResidualsVisible = false;
  }

  void _onCurveChanged(bool? value) {
    final on = value ?? false;
    final m = widget.model;
    if (on) {
      m.setCurveVisible(true);
      m.setResidualsVisible(wereResidualsVisible);
    } else {
      wereResidualsVisible = m.residualsVisible;
      m.setResidualsVisible(false);
      m.setCurveVisible(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    return Material(
      color: CurveFittingColors.panelBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(CurveFittingConstants.panelCornerRadius),
        side: const BorderSide(color: Colors.black26),
      ),
      child: SizedBox(
        width: CurveFittingConstants.panelMaxWidth,
        child: Padding(
          padding: const EdgeInsets.all(CurveFittingConstants.panelMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _check(
                label: CurveFittingStrings.curve,
                value: m.curveVisible,
                onChanged: _onCurveChanged,
              ),
              _check(
                label: CurveFittingStrings.residuals,
                value: m.residualsVisible,
                onChanged: m.curveVisible
                    ? (v) => m.setResidualsVisible(v ?? false)
                    : null,
              ),
              _check(
                label: CurveFittingStrings.values,
                value: m.valuesVisible,
                onChanged: (v) => m.setValuesVisible(v ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _check({
    required String label,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: _labelStyle)),
          ],
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(fontSize: 16);

class _CfPanel extends StatelessWidget {
  const _CfPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CurveFittingColors.panelBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(CurveFittingConstants.panelCornerRadius),
        side: const BorderSide(color: Colors.black26),
      ),
      child: SizedBox(
        width: CurveFittingConstants.panelMaxWidth,
        child: Padding(
          padding: const EdgeInsets.all(CurveFittingConstants.panelMargin),
          child: child,
        ),
      ),
    );
  }
}

/// Shared panel chrome for curve-fitting control panels.
class CfPanelChrome extends StatelessWidget {
  const CfPanelChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => _CfPanel(child: child);
}
