import 'package:flutter/material.dart';

import '../john_travoltage_assets.dart';
import '../model/john_travoltage_model.dart';
import '../model/leg.dart';
import 'appendage_node.dart';
import 'jt_view_layout.dart';

/// Leg view — PhET `LegNode.js`.
class LegNode extends StatelessWidget {
  const LegNode({
    super.key,
    required this.model,
  });

  final JohnTravoltageModel model;

  Leg get leg => model.leg;

  @override
  Widget build(BuildContext context) {
    return AppendageNode(
      debugKey: const ValueKey('jt-leg'),
      appendage: leg,
      assetPath: JohnTravoltageAssets.leg,
      imageSize: JtViewLayout.legImageSize,
      dx: JtViewLayout.legDx,
      dy: JtViewLayout.legDy,
      angleOffset: JtViewLayout.legAngleOffset,
      limitRotation: Leg.limitRotation,
      onAngleChanged: (angle) => model.setLegAngle(angle),
    );
  }
}
