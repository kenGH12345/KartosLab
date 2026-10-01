import 'dart:math' as math;

/// Minimal port of PhET `dot/js/Complex` for [Spring.step] analytics.
class Complex {
  Complex(this.real, this.imaginary);

  double real;
  double imaginary;

  static final Complex zero = Complex(0, 0);
  static final Complex one = Complex(1, 0);
  static final Complex i = Complex(0, 1);

  static Complex fromReal(double real) => Complex(real, 0);

  double get magnitude => math.sqrt(real * real + imaginary * imaginary);

  double get magnitudeSquared => real * real + imaginary * imaginary;

  Complex copy() => Complex(real, imaginary);

  Complex plus(Complex c) => Complex(real + c.real, imaginary + c.imaginary);

  Complex minus(Complex c) => Complex(real - c.real, imaginary - c.imaginary);

  Complex times(Complex c) => Complex(
        real * c.real - imaginary * c.imaginary,
        real * c.imaginary + imaginary * c.real,
      );

  Complex dividedBy(Complex c) {
    final mag = c.magnitudeSquared;
    return Complex(
      (real * c.real + imaginary * c.imaginary) / mag,
      (imaginary * c.real - real * c.imaginary) / mag,
    );
  }

  Complex squared() => times(this);

  Complex sinOf() {
    return Complex(
      math.sin(real) * _cosh(imaginary),
      math.cos(real) * _sinh(imaginary),
    );
  }

  Complex cosOf() {
    return Complex(
      math.cos(real) * _cosh(imaginary),
      -math.sin(real) * _sinh(imaginary),
    );
  }

  Complex exponentiated() {
    final mag = math.exp(real);
    return Complex(mag * math.cos(imaginary), mag * math.sin(imaginary));
  }

  Complex sqrtOf() {
    final mag = magnitude;
    return Complex(
      math.sqrt((mag + real) / 2),
      (imaginary >= 0 ? 1.0 : -1.0) * math.sqrt((mag - real) / 2),
    );
  }

  // Mutable chain (matches PhET Spring.step usage).

  Complex setRealImaginary(double r, double im) {
    real = r;
    imaginary = im;
    return this;
  }

  Complex add(Complex c) => setRealImaginary(real + c.real, imaginary + c.imaginary);

  Complex subtract(Complex c) =>
      setRealImaginary(real - c.real, imaginary - c.imaginary);

  Complex multiply(Complex c) => setRealImaginary(
        real * c.real - imaginary * c.imaginary,
        real * c.imaginary + imaginary * c.real,
      );

  Complex divide(Complex c) {
    final mag = c.magnitudeSquared;
    return setRealImaginary(
      (real * c.real + imaginary * c.imaginary) / mag,
      (imaginary * c.real - real * c.imaginary) / mag,
    );
  }

  Complex sqrt() {
    final mag = magnitude;
    return setRealImaginary(
      math.sqrt((mag + real) / 2),
      (imaginary >= 0 ? 1.0 : -1.0) * math.sqrt((mag - real) / 2),
    );
  }

  Complex exponentiate() {
    final mag = math.exp(real);
    return setRealImaginary(mag * math.cos(imaginary), mag * math.sin(imaginary));
  }

  Complex cos() {
    return setRealImaginary(
      math.cos(real) * _cosh(imaginary),
      -math.sin(real) * _sinh(imaginary),
    );
  }

  static double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
}
