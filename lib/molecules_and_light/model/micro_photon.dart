import '../molecules_and_light_constants.dart';

/// PhET `MicroPhoton`. Wavelength is fixed for the life of the photon.
class MicroPhoton {
  MicroPhoton(this.wavelength);

  final double wavelength;
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;

  LightType get lightType => LightType.fromWavelength(wavelength);

  void setVelocity(double vx, double vy) {
    this.vx = vx;
    this.vy = vy;
  }

  void step(double dt) {
    x += vx * dt;
    y += vy * dt;
  }
}
