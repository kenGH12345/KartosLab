import 'package:flutter/material.dart';

import '../curve_fitting_strings.dart';
import '../model/curve_fitting_model.dart';
import 'view_options_panel.dart';

/// Linear / Quadratic / Cubic — PhET `CurveOrderPanel`.
class CurveOrderPanel extends StatelessWidget {
  const CurveOrderPanel({super.key, required this.model});

  final CurveFittingModel model;

  @override
  Widget build(BuildContext context) {
    if (!model.curveVisible) return const SizedBox.shrink();

    return CfPanelChrome(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _orderRow(1, CurveFittingStrings.linear),
          _orderRow(2, CurveFittingStrings.quadratic),
          _orderRow(3, CurveFittingStrings.cubic),
        ],
      ),
    );
  }

  Widget _orderRow(int order, String label) {
    final selected = model.order == order;
    return InkWell(
      onTap: () => model.setOrder(order),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? Colors.blue : Colors.black54,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
