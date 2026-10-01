const double kWaveEpsilon = 1e-12;
const double kNearApertureXFraction = 1e-4;

double smoothStep(double edge0, double edge1, double x) {
  if (x <= edge0) {
    return 0;
  }
  if (x >= edge1) {
    return 1;
  }
  final u = (x - edge0) / (edge1 - edge0);
  return u * u * (3 - 2 * u);
}

double clampDouble(double value, double min, double max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}
