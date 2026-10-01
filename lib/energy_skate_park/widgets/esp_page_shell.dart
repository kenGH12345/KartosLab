import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';

/// Fits PhET 1024×618 ScreenView into the available cell.
class EspPageShell extends StatelessWidget {
  const EspPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: EspConstants.layoutWidth,
            height: EspConstants.layoutHeight,
            child: child,
          ),
        );
      },
    );
  }
}
