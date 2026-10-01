import 'package:flutter/material.dart';

import '../normal_modes_constants.dart';

/// Maps the PhET 1024×618 ScreenView into the available cell.
class NmLayout extends StatelessWidget {
  const NmLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: NormalModesConstants.layoutWidth,
            height: NormalModesConstants.layoutHeight,
            child: child,
          ),
        );
      },
    );
  }
}
