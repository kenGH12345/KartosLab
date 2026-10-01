import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/pl_colors.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';

/// PhET layoutBounds 1024×618 FittedBox shell (EFAC / CLB pattern).
class PlSimulationShell extends StatelessWidget {
  const PlSimulationShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PlColors.background,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: PlConstants.layoutWidth,
          height: PlConstants.layoutHeight,
          child: ColoredBox(
            color: PlColors.background,
            child: child,
          ),
        ),
      ),
    );
  }
}
