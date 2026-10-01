import 'package:flutter/material.dart';

import '../john_travoltage_assets.dart';
import '../model/arm.dart';
import '../model/john_travoltage_model.dart';
import 'appendage_node.dart';
import 'jt_view_layout.dart';

/// Arm view — PhET `ArmNode.js`.
class ArmNode extends StatelessWidget {
  const ArmNode({
    super.key,
    required this.model,
  });

  final JohnTravoltageModel model;

  Arm get arm => model.arm;

  @override
  Widget build(BuildContext context) {
    return AppendageNode(
      debugKey: const ValueKey('jt-arm'),
      appendage: arm,
      assetPath: JohnTravoltageAssets.arm,
      imageSize: JtViewLayout.armImageSize,
      dx: JtViewLayout.armDx,
      dy: JtViewLayout.armDy,
      angleOffset: JtViewLayout.armAngleOffset,
      onAngleChanged: model.setArmAngle,
    );
  }
}
