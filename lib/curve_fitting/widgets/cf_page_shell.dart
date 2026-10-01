import 'package:flutter/material.dart';

/// Fills the NineGrid center cell; [CfScreenBody] sizes via [LayoutBuilder].
class CfPageShell extends StatelessWidget {
  const CfPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: child);
  }
}
