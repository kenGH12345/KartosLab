/// PhET Floating Panel — a draggable floating control panel.
library;

import 'package:flutter/material.dart';
import '../interaction/phet_draggable.dart';
import 'phet_panel.dart';

class PhetFloatingPanel extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double? width;
  final Offset initialPosition;

  const PhetFloatingPanel({
    super.key,
    this.title,
    required this.children,
    this.width = 240,
    this.initialPosition = const Offset(16, 16),
  });

  @override
  Widget build(BuildContext context) {
    return PhetDraggable(
      initialPosition: initialPosition,
      builder: (context, position) {
        return PhetPanel(
          width: width,
          title: title,
          children: children,
        );
      },
    );
  }
}
