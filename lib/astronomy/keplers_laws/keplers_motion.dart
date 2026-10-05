import 'package:flutter/material.dart';

/// Shared easing for Kepler tab / law / visibility transitions.
class KeplersMotion {
  KeplersMotion._();

  static const Duration duration = Duration(milliseconds: 400);
  static const Curve curve = Curves.easeInOutCubic;

  static Widget fadeSize({required Object key, required Widget child}) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) {
        return Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.none,
          children: <Widget>[
            ...previous,
            ?current,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            alignment: Alignment.topCenter,
            sizeFactor: CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(key), child: child),
    );
  }
}
