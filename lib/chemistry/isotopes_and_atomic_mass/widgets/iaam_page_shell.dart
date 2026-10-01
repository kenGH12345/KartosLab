import 'package:flutter/material.dart';

import '../iaam_constants.dart';

/// Fits PhET 768×464 ScreenView into the available cell.
class IaamPageShell extends StatelessWidget {
  const IaamPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: IaamConstants.layoutWidth,
            height: IaamConstants.layoutHeight,
            child: child,
          ),
        );
      },
    );
  }
}
