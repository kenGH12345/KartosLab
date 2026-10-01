import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';

class EspPageMetrics {
  const EspPageMetrics({
    required this.rightPanelWidth,
    required this.bottomPanelHeight,
  });

  final double rightPanelWidth;
  final double bottomPanelHeight;

  static const double rightReserveLogical = 240;
  static const double bottomReserveLogical = 72;

  static EspPageMetrics compute(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    return EspPageMetrics(
      rightPanelWidth: (w * 0.26).clamp(200.0, 260.0),
      bottomPanelHeight: (h * 0.12).clamp(56.0, 80.0),
    );
  }
}

class EspSimulationViewport extends StatelessWidget {
  const EspSimulationViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: EspColors.screenBackground,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: EspConstants.layoutWidth - EspPageMetrics.rightReserveLogical,
          height:
              EspConstants.layoutHeight - EspPageMetrics.bottomReserveLogical,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: EspConstants.layoutWidth -
                  EspPageMetrics.rightReserveLogical,
              maxWidth: EspConstants.layoutWidth -
                  EspPageMetrics.rightReserveLogical,
              minHeight: EspConstants.layoutHeight -
                  EspPageMetrics.bottomReserveLogical,
              maxHeight: EspConstants.layoutHeight -
                  EspPageMetrics.bottomReserveLogical,
              child: SizedBox(
                width: EspConstants.layoutWidth -
                    EspPageMetrics.rightReserveLogical,
                height: EspConstants.layoutHeight -
                    EspPageMetrics.bottomReserveLogical,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
