/// Spin layout — SpinScreenView / SpinMeasurementArea / SpinStatePreparationArea.
library;

class QmSpinLayoutSpec {
  const QmSpinLayoutSpec();

  /// SpinScreenView dividingLineX empirically determined
  static const dividingLineX = 300.0;
  static const dividingLineTop = 70.0;

  /// measurementArea.left = dividingLineX
  double get measurementAreaLeft => dividingLineX;

  /// ModelViewTransform scale 180, inverted Y, origin (0,0)
  static const modelViewScale = 180.0;

  /// SternGerlach model positions (meters-like units in SpinModel)
  static const sg0Position = (x: 0.8, y: 0.0);
  static const sg1Position = (x: 2.0, y: 0.3);
  static const sg2Position = (x: 2.0, y: -0.3);
  static const particleSourcePosition = (x: -0.5, y: 0.0);

  /// SternGerlach geometry constants (model units)
  static const sternGerlachWidth = 150 / 200; // 0.75
  static const sternGerlachHeight = 100 / 200; // 0.5

  /// Prep BlochSphereWithProjectionNode scale
  static const preparationBlochScale = 0.9;

  /// Histogram above SG
  static const histogramModelY = 1.1;
  static const histogramScale = 0.8;

  ({double x, double y}) modelToView(double mx, double my) => (
        x: mx * modelViewScale,
        y: -my * modelViewScale,
      );
}
