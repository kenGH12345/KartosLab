import 'package:flutter/material.dart';

import '../../faradays_law_constants.dart';
import '../painters/voltmeter_painter.dart';

/// Voltmeter body + connecting wires to bulb — `VoltmeterAndWiresNode.js`.
class VoltmeterWidget extends StatelessWidget {
  const VoltmeterWidget({
    super.key,
    required this.visible,
    required this.needleAngle,
  });

  final bool visible;
  final double needleAngle;

  static const Size _bodySize = Size(190, 140);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final center = FaradaysLawConstants.voltmeterPosition;

    return Stack(
      children: [
        CustomPaint(
          size: FaradaysLawConstants.layoutSize,
          painter: _VoltmeterWiresPainter(),
        ),
        Positioned(
          left: center.dx - _bodySize.width / 2,
          top: center.dy - _bodySize.height / 2,
          width: _bodySize.width,
          height: _bodySize.height,
          child: CustomPaint(
            painter: VoltmeterPainter(needleAngle: needleAngle),
          ),
        ),
      ],
    );
  }
}

class _VoltmeterWiresPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(FaradaysLawConstants.voltmeterWireColorValue)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final vm = FaradaysLawConstants.voltmeterPosition;
    final bulb = FaradaysLawConstants.bulbPosition;
    // Approximate terminal offsets from VoltmeterNode (±18 at bottom)
    final leftX = vm.dx - 18;
    final rightX = vm.dx + 18;
    final wireTop = vm.dy + 107 / 2;
    final leftBottom = bulb.dy - 23;
    final rightBottom = bulb.dy - 10;

    canvas.drawLine(Offset(leftX, wireTop), Offset(leftX, leftBottom), paint);
    canvas.drawLine(Offset(rightX, wireTop), Offset(rightX, rightBottom), paint);

    _pad(canvas, Offset(leftX, leftBottom));
    _pad(canvas, Offset(rightX, rightBottom));
  }

  void _pad(Canvas canvas, Offset c) {
    canvas.drawCircle(
      c,
      6,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF888888), Color(0xFF333333)],
        ).createShader(Rect.fromCircle(center: c, radius: 6)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
