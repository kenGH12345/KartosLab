import 'package:flutter/material.dart';

import '../curve_fitting_constants.dart';
import '../model/curve_fitting_model.dart';
import 'curve_order_panel.dart';
import 'fit_panel.dart';
import 'view_options_panel.dart';

/// Stacks ViewOptions + (optional) Order + Fit — PhET `ControlPanels`.
///
/// Order/Fit are omitted entirely when [curveVisible] is false so no leftover
/// spacing remains (matches `curveVisibleProperty.linkAttribute(..., 'visible')`).
class ControlPanelsColumn extends StatefulWidget {
  const ControlPanelsColumn({super.key, required this.model});

  final CurveFittingModel model;

  @override
  State<ControlPanelsColumn> createState() => ControlPanelsColumnState();
}

class ControlPanelsColumnState extends State<ControlPanelsColumn> {
  final GlobalKey<ViewOptionsPanelState> _viewOptionsKey =
      GlobalKey<ViewOptionsPanelState>();

  void reset() {
    _viewOptionsKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final curveOn = widget.model.curveVisible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ViewOptionsPanel(key: _viewOptionsKey, model: widget.model),
        if (curveOn) ...[
          const SizedBox(height: CurveFittingConstants.controlsYSpacing),
          CurveOrderPanel(model: widget.model),
          const SizedBox(height: CurveFittingConstants.controlsYSpacing),
          FitPanel(model: widget.model),
        ],
      ],
    );
  }
}
