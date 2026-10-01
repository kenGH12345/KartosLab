import 'package:flutter/material.dart';

import 'qwi_layout.dart';

/// Scales a fixed PhET [QwiLayout.designSize] play area into available bounds.
///
/// Same pattern as Color Vision (`FittedBox` + explicit design [SizedBox]).
class QwiDesignScaler extends StatelessWidget {
  const QwiDesignScaler({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : QwiLayout.designWidth;
          final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
              ? constraints.maxHeight
              : QwiLayout.designHeight;
          return SizedBox(
            width: w,
            height: h,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox(
                width: QwiLayout.designWidth,
                height: QwiLayout.designHeight,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
