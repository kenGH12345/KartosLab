import 'package:flutter/material.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_layout.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';

/// Absolute-positioned gun + beam + foil matching PhET RSBaseScreenView.
class RsGunAssembly extends StatelessWidget {
  const RsGunAssembly({
    super.key,
    required this.gunOn,
    required this.onToggle,
    this.beamColor = RsColors.atomBeam,
  });

  final bool gunOn;
  final VoidCallback onToggle;
  final Color beamColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Foil (decorative)
        Positioned(
          left: RsLayout.foilLeft,
          top: RsLayout.foilTop,
          width: RsLayout.foilW,
          height: RsLayout.foilH,
          child: IgnorePointer(
            child: CustomPaint(painter: _FoilPainter()),
          ),
        ),
        // Tiny zoom box (on foil center)
        Positioned(
          left: RsLayout.foilCenterX - 5,
          top: RsLayout.foilCenterY - 2,
          width: 10,
          height: 4,
          child: IgnorePointer(
            child: CustomPaint(painter: _TinyBoxPainter()),
          ),
        ),
        // Beam (non-interactive)
        Positioned(
          left: RsLayout.beamLeft,
          top: RsLayout.beamTop,
          width: RsLayout.beamW,
          height: RsLayout.beamH,
          child: IgnorePointer(
            child: gunOn
                ? ColoredBox(color: beamColor)
                : const SizedBox.expand(),
          ),
        ),
        // Laser pointer (gun) — entire body toggles emission
        Positioned(
          left: RsLayout.gunLeft,
          top: RsLayout.gunTop,
          width: RsLayout.gunW,
          height: RsLayout.gunH,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              customBorder: const StadiumBorder(),
              child: CustomPaint(
                painter: _LaserPainter(on: gunOn),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        // Label under gun
        Positioned(
          left: RsLayout.gunCenterX - 70,
          top: RsLayout.gunTop + RsLayout.gunH + 15,
          width: 140,
          child: IgnorePointer(
            child: Text(
              RsStrings.alphaParticles,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RsColors.panelLabel,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FoilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TargetMaterialNode: trapezoid top face, BACK_OFFSET=0.10, BACK_DEPTH=height
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0.10 * w, 0)
      ..lineTo(0.90 * w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [RsColors.foilBack, RsColors.foilFront],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TinyBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.9, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LaserPainter extends CustomPainter {
  _LaserPainter({required this.on});
  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Nozzle at top (points up), body below — matches rotated LaserPointerNode
    final nozzle = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, 12), width: 60, height: 20),
      const Radius.circular(3),
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 20, size.width - 4, size.height - 22),
      const Radius.circular(10),
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          RsColors.laserPointerBottom,
          RsColors.laserPointerHighlight,
          RsColors.laserPointerTop,
          RsColors.laserPointerBottom,
        ],
        stops: const [0.0, 0.35, 0.55, 1.0],
      ).createShader(body.outerRect);

    canvas.drawRRect(nozzle, bodyPaint);
    canvas.drawRRect(body, bodyPaint);

    final btn = Offset(cx, size.height * 0.58);
    canvas.drawCircle(
      btn,
      14,
      Paint()
        ..color = on
            ? RsColors.laserPointerButton
            : RsColors.laserPointerButton.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      btn.translate(-4, -4),
      4.5,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _LaserPainter oldDelegate) =>
      oldDelegate.on != on;
}
