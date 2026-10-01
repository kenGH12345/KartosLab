import 'package:flutter/material.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../fmw_constants.dart';

/// NineGrid shell with center = FittedBox of PhET 1024×618 content.
class FmwPageShell extends StatelessWidget {
  const FmwPageShell({
    super.key,
    required this.child,
    this.backgroundColor,
    this.footer,
  });

  final Widget child;
  final Color? backgroundColor;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return NineGridLayout(
      backgroundColor: backgroundColor,
      footer: footer,
      center: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: FmwConstants.layoutWidth,
              height: FmwConstants.layoutHeight,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
