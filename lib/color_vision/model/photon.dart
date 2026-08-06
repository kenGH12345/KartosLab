import 'dart:ui';

/// A single photon particle in the color-vision simulation.
class Photon {
  double x;
  double y;
  Color color;
  bool alive;
  bool filtered;

  Photon({
    this.x = 0,
    this.y = 0,
    this.color = const Color(0xFFFFFFFF),
    this.alive = false,
    this.filtered = false,
  });

  void reset(double x, double y, Color color) {
    this.x = x;
    this.y = y;
    this.color = color;
    alive = true;
    filtered = false;
  }

  void kill() {
    alive = false;
    filtered = false;
  }
}
