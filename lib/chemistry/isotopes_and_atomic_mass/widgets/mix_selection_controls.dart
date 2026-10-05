/// Mix selection radios: My/Nature + Bucket/Slider mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/mixtures_controller.dart';
import '../model/interactivity_mode.dart';

class IsotopeMixtureSelection extends StatelessWidget {
  const IsotopeMixtureSelection({super.key, required this.controller});

  final MixturesController controller;

  @override
  Widget build(BuildContext context) {
    final nature = controller.model.showingNaturesMix;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Isotope Mixture:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 3),
        _AquaRadio(
          selected: !nature,
          label: 'My Mix',
          onTap: () => controller.setShowingNaturesMix(false),
        ),
        const SizedBox(height: 8),
        _AquaRadio(
          selected: nature,
          label: "Nature's Mix",
          onTap: () => controller.setShowingNaturesMix(true),
        ),
      ],
    );
  }
}

class InteractivityModeSelection extends StatelessWidget {
  const InteractivityModeSelection({super.key, required this.controller});

  final MixturesController controller;

  @override
  Widget build(BuildContext context) {
    final mode = controller.model.interactivityMode;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeButton(
          selected: mode == InteractivityMode.bucketsAndLargeAtoms,
          onTap: () => controller.setInteractivityMode(
            InteractivityMode.bucketsAndLargeAtoms,
          ),
          child: CustomPaint(
            size: const Size(28, 18),
            painter: _MiniBucketIconPainter(),
          ),
        ),
        const SizedBox(width: 5),
        _ModeButton(
          selected: mode == InteractivityMode.slidersAndSmallAtoms,
          onTap: () => controller.setInteractivityMode(
            InteractivityMode.slidersAndSmallAtoms,
          ),
          child: CustomPaint(
            size: const Size(28, 18),
            painter: _MiniSliderIconPainter(),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1.0 : 0.2,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: selected
                    ? const Color(0xFF3291B8)
                    : Colors.black26,
                width: selected ? 2 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AquaRadio extends StatelessWidget {
  const _AquaRadio({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(12, 12),
            painter: _AquaPainter(selected: selected),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _AquaPainter extends CustomPainter {
  _AquaPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black87,
    );
    if (selected) {
      canvas.drawCircle(c, r * 0.55, Paint()..color = const Color(0xFF0099FF));
    }
  }

  @override
  bool shouldRepaint(covariant _AquaPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

/// PhET scenery-phet EraserButton: yellow RectangularPushButton + eraser.svg.
class MixEraserButton extends StatelessWidget {
  const MixEraserButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  /// scenery-phet `PhetColorScheme.BUTTON_YELLOW`
  static const Color _baseYellow = Color(0xFFEEF422);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(5),
        child: CustomPaint(
          painter: const _YellowPushButtonPainter(_baseYellow),
          child: SizedBox(
            width: 42,
            height: 36,
            child: Center(
              child: SvgPicture.asset(
                'assets/phet/vector_addition/scenery_phet/eraser.svg',
                width: 24,
                height: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YellowPushButtonPainter extends CustomPainter {
  const _YellowPushButtonPainter(this.base);

  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(5),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFF505050));
    final inner = r.deflate(1);
    canvas.drawRRect(
      inner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(base, Colors.white, 0.45)!,
            base,
            Color.lerp(base, Colors.black, 0.18)!,
          ],
        ).createShader(inner.outerRect),
    );
  }

  @override
  bool shouldRepaint(covariant _YellowPushButtonPainter oldDelegate) =>
      oldDelegate.base != base;
}

class _MiniBucketIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(2, 6)
      ..lineTo(4, size.height - 2)
      ..lineTo(size.width - 4, size.height - 2)
      ..lineTo(size.width - 2, 6)
      ..close();
    canvas.drawPath(body, Paint()..color = Colors.grey);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, 6),
        width: size.width - 2,
        height: 6,
      ),
      Paint()..color = const Color(0xFF555555),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniSliderIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, cy - 1.5, size.width - 2, 3),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFF555555),
    );
    // End ticks
    canvas.drawLine(
      Offset(2, cy - 6),
      Offset(2, cy + 6),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(size.width - 2, cy - 6),
      Offset(size.width - 2, cy + 6),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.2,
    );
    // Thumb (tall rectangle — not a plus)
    final thumb = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width * 0.55, cy), width: 5, height: 14),
      const Radius.circular(1),
    );
    canvas.drawRRect(thumb, Paint()..color = const Color(0xFF159CC4));
    canvas.drawRRect(
      thumb,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
