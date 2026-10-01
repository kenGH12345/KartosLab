import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

export 'package:kratos/energy_forms_and_changes/systems/widgets/light_bulb_node.dart';

/// PhET `FanNode` — frame cycle fan01–fan10.
class FanNode extends StatelessWidget {
  const FanNode({
    super.key,
    required this.model,
    required this.opacity,
  });

  final SystemsModel model;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final active = model.users.targetIndex ==
        model.users.ids.indexOf(EnergyUserId.fan);
    final frame = active
        ? ((model.generatorWheelAngle.abs() / 0.4).floor() % 10) + 1
        : 1;
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        EfacAssets.png('fan${frame.toString().padLeft(2, '0')}'),
        width: 140,
      ),
    );
  }

  static Offset topLeftFromModelOrigin() => const Offset(-70, -120);
}
