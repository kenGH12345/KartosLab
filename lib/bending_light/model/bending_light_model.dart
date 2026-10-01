import 'package:flutter/foundation.dart';

import '../bending_light_constants.dart';
import 'enums.dart';
import 'laser.dart';
import 'light_ray.dart';
import 'substance.dart';

/// Base model (`BendingLightModel.ts`).
abstract class BendingLightModel extends ChangeNotifier {
  BendingLightModel({
    required double laserAngle,
    required bool topLeftQuadrant,
    required double laserDistanceFromPivot,
  }) {
    wavelength = BendingLightConstants.wavelengthRed;
    laser = Laser(
      wavelengthGetter: () => wavelength,
      distanceFromPivot: laserDistanceFromPivot,
      angle: laserAngle,
      topLeftQuadrant: topLeftQuadrant,
    );
  }

  final List<LightRay> rays = [];
  final MediumColorFactory mediumColorFactory = MediumColorFactory();

  double get modelWidth => BendingLightConstants.modelWidth;
  double get modelHeight => BendingLightConstants.modelHeight;

  LaserViewEnum laserView = LaserViewEnum.ray;
  late double wavelength; // meters
  TimeSpeed speed = TimeSpeed.normal;
  bool isPlaying = true;
  bool showNormal = true;
  bool showAngles = false;
  late final Laser laser;

  void addRay(LightRay ray) => rays.add(ray);

  void clearModel() => rays.clear();

  void updateModel() {
    clearModel();
    propagateRays();
    notifyListeners();
  }

  void propagateRays();

  @mustCallSuper
  void reset() {
    laserView = LaserViewEnum.ray;
    wavelength = BendingLightConstants.wavelengthRed;
    isPlaying = true;
    speed = TimeSpeed.normal;
    showNormal = true;
    showAngles = false;
    laser.reset();
    clearModel();
    notifyListeners();
  }

  void setWavelength(double meters) {
    wavelength = meters;
    updateModel();
  }

  void setLaserOn(bool value) {
    laser.on = value;
    updateModel();
  }

  void setLaserView(LaserViewEnum view) {
    laserView = view;
    laser.setWave(view == LaserViewEnum.wave);
    updateModel();
  }

  void setShowNormal(bool value) {
    showNormal = value;
    notifyListeners();
  }

  void setShowAngles(bool value) {
    showAngles = value;
    notifyListeners();
  }
}
