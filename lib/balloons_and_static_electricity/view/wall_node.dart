import 'package:flutter/material.dart';

import '../model/balloons_static_electricity_constants.dart';
import '../model/balloons_static_electricity_model.dart';
import 'base_view_layout.dart';
import 'charge_painter.dart';
import 'package:kratos/balloons_and_static_electricity/base_strings.dart';

/// Wall image + charge canvas — PhET `WallNode`.
class WallNode extends StatelessWidget {
  const WallNode({super.key, required this.model});

  final BalloonsStaticElectricityModel model;

  @override
  Widget build(BuildContext context) {
    final wall = model.wall;
    if (!wall.isVisible) return const SizedBox.shrink();

    final showCharges = model.showCharges == ShowCharges.allCharges;
    final plus = wall.plusCharges.map((c) => c.position).toList();
    final minus = wall.minusCharges.map((c) => c.position).toList();

    return Stack(
      children: [
        // Black to the right of the wall image (BASEView).
        Positioned(
          left: wall.x + BaseViewLayout.wallImageWidth,
          top: 0,
          width: 1000,
          height: BaseViewLayout.layoutHeight,
          child: const ColoredBox(color: Colors.black),
        ),
        Positioned(
          left: wall.x,
          top: 0,
          child: Semantics(
            label: BaseStrings.wall,
            child: IgnorePointer(
              child: Image.asset(
                BaseAssets.wall,
                width: BaseViewLayout.wallImageWidth,
                height: BaseViewLayout.wallImageHeight,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
                alignment: Alignment.topLeft,
              ),
            ),
          ),
        ),
        if (showCharges)
          Positioned(
            left: wall.x,
            top: 0,
            width: wall.width + 20,
            height: BaseConstants.height,
            child: IgnorePointer(
              child: CustomPaint(
                painter: WallChargesPainter(
                  wallX: wall.x,
                  plusPositions: plus,
                  minusPositions: minus,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
