/// PhET Gas — ideal gas model (PV = nRT).
library;

import 'package:flutter/material.dart';

class Gas {
  double pressure;   // Pa
  double temperature; // K
  double volume;     // m³
  double moles;      // mol

  static const double R = 8.314; // J/(mol·K)

  Gas({
    this.pressure = 101325,
    this.temperature = 298,
    this.volume = 0.001,
    this.moles = 0.04,
  });

  /// Validate with ideal gas law: PV = nRT.
  /// Returns the expected pressure given current V, n, T.
  double get expectedPressure => moles * R * temperature / volume;

  /// Get pressure in atm.
  double get pressureAtm => pressure / 101325;

  /// Get temperature in °C.
  double get temperatureCelsius => temperature - 273.15;

  void reset() {
    pressure = 101325;
    temperature = 298;
    volume = 0.001;
    moles = 0.04;
  }
}

/// A gas particle for kinetic theory visualization.
class GasParticle {
  Offset position;
  Offset velocity;
  double radius;
  Color color;

  GasParticle({
    required this.position,
    required this.velocity,
    this.radius = 4,
    this.color = const Color(0xff90caf9),
  });

  void update(double dt, Rect bounds) {
    position += velocity * dt;
    // Bounce off walls
    if (position.dx < bounds.left + radius || position.dx > bounds.right - radius) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy < bounds.top + radius || position.dy > bounds.bottom - radius) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
    position = Offset(
      position.dx.clamp(bounds.left + radius, bounds.right - radius),
      position.dy.clamp(bounds.top + radius, bounds.bottom - radius),
    );
  }

  void draw(Canvas canvas) {
    canvas.drawCircle(position, radius, Paint()..color = color);
  }
}
