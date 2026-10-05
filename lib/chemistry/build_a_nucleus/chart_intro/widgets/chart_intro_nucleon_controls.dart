/// Chart Intro 质子 / 中子生成器。对标 `NucleonCreatorsNode` 两行。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../../model/nucleon.dart';
import '../../widgets/nucleon_arrow_column.dart';
import '../controller/chart_intro_controller.dart';

class ChartIntroNucleonControls extends StatelessWidget {
  const ChartIntroNucleonControls({super.key, required this.controller});

  final ChartIntroController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.state;
    const proton = Color(BanConstants.protonColorValue);
    const neutron = Color(BanConstants.neutronColorValue);
    return Table(
      key: const ValueKey('chart_intro_nucleon_creators'),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            NucleonArrowButton(
              buttonKey: const ValueKey('chart_intro_add_proton'),
              up: true,
              color: proton,
              onPressed: s.canAddProton ? controller.addProton : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _Ball(
                color: proton,
                ballKey: const ValueKey('chart_intro_proton_ball'),
                enabled: s.canAddProton,
                onDragStart: () =>
                    controller.beginCreatorDrag(NucleonType.proton),
              ),
            ),
            NucleonArrowButton(
              buttonKey: const ValueKey('chart_intro_add_pair'),
              up: true,
              color: Colors.black87,
              doubled: true,
              onPressed: s.canAddPair ? controller.addPair : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _Ball(
                color: neutron,
                ballKey: const ValueKey('chart_intro_neutron_ball'),
                enabled: s.canAddNeutron,
                onDragStart: () =>
                    controller.beginCreatorDrag(NucleonType.neutron),
              ),
            ),
            NucleonArrowButton(
              buttonKey: const ValueKey('chart_intro_add_neutron'),
              up: true,
              color: neutron,
              onPressed: s.canAddNeutron ? controller.addNeutron : null,
            ),
          ],
        ),
        TableRow(
          children: [
            NucleonArrowButton(
              buttonKey: const ValueKey('chart_intro_remove_proton'),
              up: false,
              color: proton,
              onPressed: s.canRemoveProton ? controller.removeProton : null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Protons',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            NucleonArrowButton(
              buttonKey: const ValueKey('chart_intro_remove_pair'),
              up: false,
              color: Colors.black87,
              doubled: true,
              onPressed: s.canRemovePair ? controller.removePair : null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Neutrons',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            NucleonArrowButton(
              buttonKey: const ValueKey('chart_intro_remove_neutron'),
              up: false,
              color: neutron,
              onPressed: s.canRemoveNeutron ? controller.removeNeutron : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _Ball extends StatelessWidget {
  const _Ball({
    required this.color,
    required this.ballKey,
    required this.enabled,
    required this.onDragStart,
  });

  final Color color;
  final Key ballKey;
  final bool enabled;
  final VoidCallback onDragStart;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled ? (_) => onDragStart() : null,
      child: Center(
        child: Container(
          key: ballKey,
          width: BanConstants.nucleonRadius * 2,
          height: BanConstants.nucleonRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.4),
              radius: 1.6,
              colors: [Colors.white, color],
            ),
          ),
        ),
      ),
    );
  }
}
