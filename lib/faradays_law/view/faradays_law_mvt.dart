import 'dart:ui' show Offset, Size;

import '../faradays_law_constants.dart';

/// Identity transform for PhET layout bounds (834×504).
///
/// Play area is laid out in source coordinates then fitted to the widget via
/// [FittedBox]; all sim components share this single coordinate system.
class FaradaysLawMvt {
  const FaradaysLawMvt();

  Size get layoutSize => FaradaysLawConstants.layoutSize;

  Offset modelToView(Offset model) => model;

  Offset viewToModel(Offset view) => view;
}
