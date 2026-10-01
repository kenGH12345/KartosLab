import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Display scale for the 834×504 stage.
///
/// The stage is laid out at the window size on each axis, so there is no
/// letterbox margin. Glyphs use the smaller axis and stay square. Widgets
/// built outside a [StageScale] (unit tests) use 1.
class StageScale extends InheritedWidget {
  const StageScale({
    super.key,
    required this.scaleX,
    required this.scaleY,
    required super.child,
  });

  final double scaleX;
  final double scaleY;

  static StageScale? _scope(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StageScale>();

  static double x(BuildContext context) => _scope(context)?.scaleX ?? 1;

  static double y(BuildContext context) => _scope(context)?.scaleY ?? 1;

  /// Square size for glyphs and controls that must not stretch.
  static double of(BuildContext context) =>
      math.min(x(context), y(context));

  static double px(BuildContext context, double stagePx) =>
      stagePx * of(context);

  @override
  bool updateShouldNotify(StageScale oldWidget) =>
      oldWidget.scaleX != scaleX || oldWidget.scaleY != scaleY;
}
