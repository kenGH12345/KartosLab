import 'dart:ui';

import '../model/beers_law_constants.dart';

/// PhET Beer's Law MVT: offsetScale(0,0) × 125 — 1 cm = 125 px.
class BeersLawMvt {
  const BeersLawMvt();

  static const double scale = BeersLawConstants.modelViewScale;

  Offset modelToView(Offset cm) => Offset(cm.dx * scale, cm.dy * scale);

  Offset viewToModel(Offset px) => Offset(px.dx / scale, px.dy / scale);

  double modelToViewDelta(double cm) => cm * scale;

  double viewToModelDelta(double px) => px / scale;

  Size modelToViewSize(double widthCm, double heightCm) =>
      Size(modelToViewDelta(widthCm), modelToViewDelta(heightCm));
}
