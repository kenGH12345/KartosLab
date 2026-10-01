import 'package:flutter/material.dart';

import '../vector_addition_constants.dart';

/// Fits PhET layoutBounds into available cell.
class VaPageShell extends StatelessWidget {
  const VaPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: VectorAdditionConstants.layoutWidth,
            height: VectorAdditionConstants.layoutHeight,
            child: child,
          ),
        );
      },
    );
  }
}
