/// Shared sim-coordinate scope for pointer → model conversion.
library;

import 'package:flutter/material.dart';

class SimCoordScope extends StatefulWidget {
  const SimCoordScope({
    super.key,
    required this.simKey,
    required this.child,
  });

  final GlobalKey simKey;
  final Widget child;

  @override
  State<SimCoordScope> createState() => SimCoordScopeState();
}

class SimCoordScopeState extends State<SimCoordScope> {
  GlobalKey get simKey => widget.simKey;

  Offset globalToSim(Offset global) {
    final box = simKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
