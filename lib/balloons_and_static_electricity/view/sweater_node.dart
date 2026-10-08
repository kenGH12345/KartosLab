import 'package:flutter/material.dart';

import '../model/balloons_static_electricity_constants.dart';
import '../model/balloons_static_electricity_model.dart';
import '../model/base_vec2.dart';
import 'base_view_layout.dart';
import 'charge_painter.dart';
import 'package:kratos/balloons_and_static_electricity/base_strings.dart';

/// Sweater image + charges — PhET `SweaterNode` (not draggable).
class SweaterNode extends StatelessWidget {
  const SweaterNode({super.key, required this.model});

  final BalloonsStaticElectricityModel model;

  @override
  Widget build(BuildContext context) {
    final s = model.sweater;
    final mode = model.showCharges;

    final plusVisible = <bool>[];
    final minusVisible = <bool>[];
    final plusCenters = <BaseVec2>[];
    final minusCenters = <BaseVec2>[];

    for (var i = 0; i < s.plusCharges.length; i++) {
      plusCenters.add(s.plusCharges[i].position);
      minusCenters.add(s.minusCharges[i].position);
      if (mode == ShowCharges.noCharges) {
        plusVisible.add(false);
        minusVisible.add(false);
      } else {
        final showAll = mode == ShowCharges.allCharges;
        final moved = s.minusCharges[i].moved;
        // allCharges: all + and remaining −
        // chargeDifferences: leftover + where moved; hide −
        plusVisible.add(showAll || moved);
        minusVisible.add(showAll && !moved);
      }
    }

    return Positioned(
      left: s.x,
      top: s.y,
      width: s.width,
      height: s.height,
      child: Semantics(
        label: BaseStrings.sweater,
        child: IgnorePointer(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                BaseAssets.sweater,
                width: BaseConstants.sweaterWidth,
                height: BaseConstants.sweaterHeight,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
              if (mode != ShowCharges.noCharges)
                Positioned(
                  left: -s.x,
                  top: -s.y,
                  width: BaseViewLayout.layoutWidth,
                  height: BaseViewLayout.layoutHeight,
                  child: CustomPaint(
                    painter: ChargesPainter(
                      plusCenters: plusCenters,
                      minusCenters: minusCenters,
                      plusVisible: plusVisible,
                      minusVisible: minusVisible,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
