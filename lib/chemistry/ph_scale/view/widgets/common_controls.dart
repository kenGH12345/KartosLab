import 'package:flutter/material.dart';

import '../../model/beaker.dart';
import '../../model/ph_scale_constants.dart';
import '../../model/solute.dart';
import '../../ph_scale_assets.dart';
import '../ph_scale_fonts.dart';
import 'package:kratos/chemistry/ph_scale/phs_strings.dart';

/// Volume arrow + label — PhET `VolumeIndicatorNode.ts`.
class VolumeIndicator extends StatelessWidget {
  const VolumeIndicator({
    super.key,
    required this.beaker,
    required this.volume,
  });

  final Beaker beaker;
  final double volume;

  @override
  Widget build(BuildContext context) {
    final height = volume <= 0
        ? 0.0
        : beaker.size.height * (volume / beaker.volume);
    final y = beaker.position.dy - height;
    final x = beaker.right + 48;
    final label =
        '${volume.toStringAsFixed(PhScaleConstants.volumeDecimalPlaces)} L';

    return Positioned(
      left: x,
      top: y - 14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(21, 28),
            painter: _ArrowPainter(),
          ),
          const SizedBox(width: 3),
          Text(label, style: PhScaleFonts.volume),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Neutral badge inside beaker — PhET `NeutralIndicatorNode.ts`.
class NeutralIndicator extends StatelessWidget {
  const NeutralIndicator({
    super.key,
    required this.beaker,
    required this.visible,
  });

  final Beaker beaker;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    // Source: centerX = beaker.centerX; bottom = beaker.bottom − 30
    const badgeW = 140.0;
    const badgeH = 44.0;
    return Positioned(
      left: beaker.position.dx - badgeW / 2,
      top: beaker.position.dy - 30 - badgeH,
      child: Container(
        width: badgeW,
        height: badgeH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 200, 200, 200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(PhsStrings.neutral, style: PhScaleFonts.neutral),
      ),
    );
  }
}

/// Solute combo — PhET `SoluteComboBox.ts` (simplified PhET styling).
class SoluteComboBox extends StatelessWidget {
  const SoluteComboBox({
    super.key,
    required this.value,
    required this.solutes,
    required this.onChanged,
  });

  final Solute value;
  final List<Solute> solutes;
  final ValueChanged<Solute> onChanged;

  @override
  Widget build(BuildContext context) {
    // PhET SoluteComboBox: maxWidth 400, PhetFont(22)
    return Container(
      constraints: const BoxConstraints(maxWidth: 400, minWidth: 220),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Solute>(
          value: value,
          isExpanded: true,
          style: PhScaleFonts.combo,
          icon: CustomPaint(
            size: const Size(16, 16),
            painter: _ComboChevronPainter(),
          ),
          items: solutes
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: s.stockColor,
                          border: Border.all(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          s.name,
                          overflow: TextOverflow.ellipsis,
                          style: PhScaleFonts.combo,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (s) {
            if (s != null) onChanged(s);
          },
        ),
      ),
    );
  }
}

/// Eye dropper — scenery-phet assets, scale 0.85.
class DropperNode extends StatelessWidget {
  const DropperNode({
    super.key,
    required this.position,
    required this.soluteColor,
    required this.isDispensing,
    required this.enabled,
    required this.onPressed,
    required this.onReleased,
  });

  final Offset position;
  final Color soluteColor;
  final bool isDispensing;
  final bool enabled;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  static const double scale = 0.85;

  @override
  Widget build(BuildContext context) {
    // Approximate eye-dropper intrinsic ~60×160; center tip near position.
    const iw = 60.0;
    const ih = 160.0;
    final w = iw * scale;
    final h = ih * scale;

    return Positioned(
      left: position.dx - w / 2,
      top: position.dy - h * 0.15,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Listener(
          onPointerDown: enabled ? (_) => onPressed() : null,
          onPointerUp: enabled ? (_) => onReleased() : null,
          onPointerCancel: enabled ? (_) => onReleased() : null,
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (isDispensing)
                  Positioned(
                    top: h * 0.35,
                    child: Container(
                      width: 12,
                      height: h * 0.4,
                      color: soluteColor.withValues(alpha: 0.7),
                    ),
                  ),
                Image.asset(
                  PhScaleAssets.eyeDropperBackground,
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                ),
                Image.asset(
                  PhScaleAssets.eyeDropperForeground,
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                ),
                Positioned(
                  top: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDispensing
                          ? const Color(0xFFCC0000)
                          : const Color(0xFFFF2222),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComboChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(2, 5)
      ..lineTo(size.width / 2, size.height - 4)
      ..lineTo(size.width - 2, 5)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
