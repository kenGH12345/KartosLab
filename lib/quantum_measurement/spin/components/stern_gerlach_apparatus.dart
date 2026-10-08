/// Stern–Gerlach apparatus visual (shared for SG0/1/2).
library;

import 'package:flutter/material.dart';

import '../composer/spin_composer.dart';
import '../model/spin_model.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class SternGerlachApparatus extends StatelessWidget {
  const SternGerlachApparatus({
    super.key,
    required this.geometry,
    this.blockingMode = BlockingMode.noBlocker,
    this.showBlockerControls = false,
    this.onBlockingChanged,
    this.onOrientationChanged,
  });

  final SpinSgGeometry geometry;
  final BlockingMode blockingMode;
  final bool showBlockerControls;
  final ValueChanged<BlockingMode>? onBlockingChanged;
  final ValueChanged<bool>? onOrientationChanged;

  @override
  Widget build(BuildContext context) {
    if (!geometry.visible) return const SizedBox.shrink();
    final size = geometry.sizeView;
    final label = geometry.isZOriented ? 'SGz' : 'SGx';

    // Blocker chips need ~200px; SG body alone is narrower — widen so
    // Block ↓ remains hittable (PHASE 8 hit-target; no visual redesign).
    final controlsExtra =
        showBlockerControls || geometry.directionControllable;
    final boxWidth = showBlockerControls
        ? (size.width + 40).clamp(200.0, 280.0)
        : size.width + 40;
    return SizedBox(
      width: boxWidth,
      height: size.height + (controlsExtra ? 88 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              size: size,
              painter: _SgPainter(label: label),
            ),
          ),
          if (geometry.directionControllable && onOrientationChanged != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AxisChip(
                  label: 'Z',
                  selected: geometry.isZOriented,
                  onTap: () => onOrientationChanged!(true),
                ),
                const SizedBox(width: 6),
                _AxisChip(
                  label: 'X',
                  selected: !geometry.isZOriented,
                  onTap: () => onOrientationChanged!(false),
                ),
              ],
            ),
          if (showBlockerControls && onBlockingChanged != null)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 2,
              children: [
                _BlockChip(
                  label: QmStrings.none,
                  selected: blockingMode == BlockingMode.noBlocker,
                  onTap: () => onBlockingChanged!(BlockingMode.noBlocker),
                ),
                _BlockChip(
                  label: QmStrings.blockUp,
                  selected: blockingMode == BlockingMode.blockUp,
                  onTap: () => onBlockingChanged!(BlockingMode.blockUp),
                ),
                _BlockChip(
                  label: QmStrings.blockDown,
                  selected: blockingMode == BlockingMode.blockDown,
                  onTap: () => onBlockingChanged!(BlockingMode.blockDown),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AxisChip extends StatelessWidget {
  const _AxisChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF99CDFF) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black45),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _BlockChip extends StatelessWidget {
  const _BlockChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, top: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFCC80) : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black38),
          ),
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }
}

class _SgPainter extends CustomPainter {
  _SgPainter({required this.label});
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = Colors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(4),
      ),
      body,
    );
    // Decoration curves (SternGerlachNode.ts) — full SGz visual.
    final curve = Paint()
      ..color = const Color(0xFF66CCFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final up = Path()..moveTo(0, size.height / 2);
    final down = Path()..moveTo(0, size.height / 2);
    for (var i = 0.0; i <= 1.0; i += 0.1) {
      final x = i * size.width;
      final yOff = i * i * size.height / 4;
      up.lineTo(x, size.height / 2 - yOff);
      down.lineTo(x, size.height / 2 + yOff);
    }
    canvas.drawPath(up, curve);
    canvas.drawPath(down, curve);

    // holes
    final hole = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey, Colors.black],
      ).createShader(Rect.fromLTWH(0, 0, 8, 16));
    canvas.drawRect(Rect.fromCenter(center: Offset(4, size.height / 2), width: 6, height: 14), hole);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width - 4, size.height / 2 - size.height / 4),
        width: 6,
        height: 14,
      ),
      hole,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width - 4, size.height / 2 + size.height / 4),
        width: 6,
        height: 14,
      ),
      hole,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(8, size.height - tp.height - 6));
  }

  @override
  bool shouldRepaint(covariant _SgPainter oldDelegate) => oldDelegate.label != label;
}
