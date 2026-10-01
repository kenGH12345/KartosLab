import 'dart:math' as math;

/// Pure Dart complex number (no dart:ui).
class Complex {
  const Complex(this.real, this.imaginary);

  final double real;
  final double imaginary;

  static const Complex zero = Complex(0, 0);

  factory Complex.polar(double magnitude, double phase) {
    return Complex(magnitude * math.cos(phase), magnitude * math.sin(phase));
  }

  double get magnitudeSquared => real * real + imaginary * imaginary;

  double get magnitude => math.sqrt(magnitudeSquared);

  double get phase => math.atan2(imaginary, real);

  Complex get conjugate => Complex(real, -imaginary);

  Complex operator +(Complex other) => Complex(real + other.real, imaginary + other.imaginary);

  Complex operator -(Complex other) => Complex(real - other.real, imaginary - other.imaginary);

  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }

  Complex operator /(Complex other) {
    final denom = other.magnitudeSquared;
    if (denom == 0) {
      return Complex.zero;
    }
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denom,
      (imaginary * other.real - real * other.imaginary) / denom,
    );
  }

  Complex scale(double s) => Complex(real * s, imaginary * s);

  @override
  String toString() => 'Complex($real, $imaginary)';
}

Complex polarTimesComplex(double magnitude, double phase, Complex value) {
  final polar = Complex.polar(magnitude, phase);
  return polar * value;
}
