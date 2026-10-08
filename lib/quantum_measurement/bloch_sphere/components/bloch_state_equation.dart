/// State equation readouts — BlochSphereSymbolic/NumericalEquationNode.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/qm_visual.dart';
import '../model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

String _basisLetter(BlochStateDirection basis) {
  switch (basis) {
    case BlochStateDirection.xPlus:
    case BlochStateDirection.xMinus:
      return 'x';
    case BlochStateDirection.yPlus:
    case BlochStateDirection.yMinus:
      return 'y';
    case BlochStateDirection.zPlus:
    case BlochStateDirection.zMinus:
    case BlochStateDirection.custom:
      return 'z';
  }
}

/// Ports BlochSphereNumericalEquationNode coefficient math (no global-phase UI).
String blochNumericEquation({
  required double polar,
  required double azimuthal,
  BlochStateDirection basis = BlochStateDirection.zPlus,
}) {
  const zero = 1e-5;
  double cosF(double x) => double.parse(math.cos(x).toStringAsFixed(4));
  double sinF(double x) => double.parse(math.sin(x).toStringAsFixed(4));
  double atan2F(double y, double x) =>
      double.parse(math.atan2(y, x).toStringAsFixed(4));

  var theta = polar.abs() < zero ? 0.0 : polar;
  var phi = azimuthal.abs() < zero ? 0.0 : azimuthal;
  final a = cosF(theta / 2);
  final b = sinF(theta / 2);

  double up;
  double down;
  double azimCoeff;

  switch (basis) {
    case BlochStateDirection.xPlus:
    case BlochStateDirection.xMinus:
      up = math.sqrt(((cosF(phi) * sinF(theta)) + 1) / 2);
      down = math.sqrt(((-cosF(phi) * sinF(theta)) + 1) / 2);
      final phiPlus =
          atan2F(b * sinF(phi), a + b * cosF(phi)) / math.pi;
      final phiMinus =
          atan2F(-b * sinF(phi), a - b * cosF(phi)) / math.pi;
      azimCoeff = phiMinus - phiPlus;
      break;
    case BlochStateDirection.yPlus:
    case BlochStateDirection.yMinus:
      up = math.sqrt(((sinF(phi) * sinF(theta)) + 1) / 2);
      down = math.sqrt(((-sinF(phi) * sinF(theta)) + 1) / 2);
      final phiPlus =
          atan2F(b * cosF(phi), a + b * sinF(phi)) / math.pi;
      final phiMinus =
          atan2F(-b * cosF(phi), a - b * sinF(phi)) / math.pi;
      azimCoeff = phiMinus - phiPlus;
      break;
    default:
      up = a.abs();
      down = b.abs();
      azimCoeff = phi / math.pi;
  }
  if (azimCoeff < 0) azimCoeff += 2;

  final letter = _basisLetter(basis);
  final upS = up.toStringAsFixed(2);
  final downS = down.toStringAsFixed(2);
  final azS = azimCoeff.toStringAsFixed(2);
  return '|ψ⟩ = $upS|↑$letter⟩ + $downS e^{i$azS\u03C0}|↓$letter⟩';
}

class BlochStateEquation extends StatelessWidget {
  const BlochStateEquation({
    super.key,
    required this.polar,
    required this.azimuthal,
    this.basis = BlochStateDirection.zPlus,
    this.showSymbolic = true,
    this.showTitle = true,
  });

  final double polar;
  final double azimuthal;
  final BlochStateDirection basis;
  final bool showSymbolic;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final numeric = blochNumericEquation(
      polar: polar,
      azimuthal: azimuthal,
      basis: basis,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          const Text(
            QmStrings.spinStateToPrepare,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
        ],
        if (showSymbolic) ...[
          const Text(
            '|ψ⟩ = cos(θ/2)|↑z⟩ + sin(θ/2) e^{iφ}|↓z⟩',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0FFFF),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF88CCCC)),
          ),
          child: Text(
            numeric,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Measurement-area equation panel + Basis radios (BlochSphereMeasurementArea).
class BlochMeasureEquationPanel extends StatelessWidget {
  const BlochMeasureEquationPanel({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final BlochSphereModel model;
  final VoidCallback onChanged;

  static const _bases = <(BlochStateDirection, String)>[
    (BlochStateDirection.xPlus, 'X'),
    (BlochStateDirection.yPlus, 'Y'),
    (BlochStateDirection.zPlus, 'Z'),
  ];

  @override
  Widget build(BuildContext context) {
    if (!model.isSingleMeasurementMode) return const SizedBox.shrink();
    final m = model.singleMeasurement;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF777777)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            blochNumericEquation(
              polar: m.polarAngle,
              azimuthal: m.azimuthalAngle,
              basis: model.equationBasis,
            ),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(QmStrings.basis, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              for (final (d, label) in _bases) ...[
                QmAquaRadio(
                  selected: model.equationBasis == d,
                  label: label,
                  onTap: () {
                    model.equationBasis = d;
                    onChanged();
                  },
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// SystemUnderTestNode — Atom / Atoms chamber with red sphere(s).
class BlochSystemUnderTest extends StatelessWidget {
  const BlochSystemUnderTest({
    super.key,
    required this.isSingle,
    this.showField = false,
    this.fieldStrength = 1.0,
  });

  final bool isSingle;
  final bool showField;
  final double fieldStrength;

  static const _atomR = 18.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF777777)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(
            isSingle ? QmStrings.atom : QmStrings.atoms,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showField)
                  CustomPaint(
                    size: const Size(120, 110),
                    painter: _FieldLinesPainter(strength: fieldStrength),
                  ),
                if (isSingle)
                  const _RedAtom(radius: _atomR)
                else
                  const _MultiAtoms(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RedAtom extends StatelessWidget {
  const _RedAtom({required this.radius});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFFFFAAAA), Color(0xFFE53935), Color(0xFFB71C1C)],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

class _MultiAtoms extends StatelessWidget {
  const _MultiAtoms();

  @override
  Widget build(BuildContext context) {
    // lattice rows 3/2/3/2 — SystemUnderTestNode
    Widget row(int n) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              const _RedAtom(radius: 14),
            ],
          ],
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(3),
        const SizedBox(height: 8),
        row(2),
        const SizedBox(height: 8),
        row(3),
        const SizedBox(height: 8),
        row(2),
      ],
    );
  }
}

class _FieldLinesPainter extends CustomPainter {
  _FieldLinesPainter({required this.strength});
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x88E53935)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    final dir = strength >= 0 ? 1.0 : -1.0;
    for (var i = 0; i < 5; i++) {
      final x = cx - 40 + i * 20.0;
      canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), paint);
      final tipY = dir > 0 ? 8.0 : size.height - 8;
      final baseY = tipY + dir * 8;
      canvas.drawPath(
        Path()
          ..moveTo(x, tipY)
          ..lineTo(x - 4, baseY)
          ..lineTo(x + 4, baseY)
          ..close(),
        Paint()..color = const Color(0x88E53935),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FieldLinesPainter oldDelegate) =>
      oldDelegate.strength != strength;
}
