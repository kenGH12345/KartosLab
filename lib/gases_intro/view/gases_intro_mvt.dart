/// PhET ModelViewTransform2.createOffsetXYScaleMapping evidence
/// from BaseModel.ts @ 10c7c08:
///   modelOriginOffset = (645, 475)
///   scaleX = +0.040, scaleY = -0.040
///
/// View coords are Ideal ScreenView layoutBounds (1008×618).
class GasesIntroMvt {
  GasesIntroMvt._();

  static const double scale = 0.040; // MODEL_VIEW_SCALE
  static const double originX = 645; // container bottom-right corner in view
  static const double originY = 475;

  static double vx(double modelXPm) => originX + modelXPm * scale;
  static double vy(double modelYPm) => originY - modelYPm * scale;
  static double vs(double pm) => pm * scale;

  static double mx(double viewX) => (viewX - originX) / scale;
  static double my(double viewY) => (originY - viewY) / scale;
}
