import 'package:flutter/material.dart';

import '../pm_colors.dart';
import '../pm_constants.dart';

/// PhET layoutBounds 1024×618 FittedBox shell（与 pendulum_lab 同模式）。
class PmSimulationShell extends StatelessWidget {
  const PmSimulationShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PmColors.background,
      child: DefaultTextStyle(
        style: PmConstants.uiText,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: PmConstants.layoutWidth,
            height: PmConstants.layoutHeight,
            child: ColoredBox(
              color: PmColors.background,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
