import 'package:flutter/material.dart';

import '../layout/membrane_transport_layout.dart';

/// Zoom rectangle + rays to observation — PhET `ThumbnailNode.ts`.
class MembraneThumbnailNode extends StatelessWidget {
  const MembraneThumbnailNode({
    super.key,
    required this.slots,
  });

  final MembraneTransportLayoutSlots slots;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        MembraneTransportLayoutPrimitives.designWidth,
        MembraneTransportLayoutPrimitives.designHeight,
      ),
      painter: _ThumbnailPainter(slots: slots),
    );
  }
}

class _ThumbnailPainter extends CustomPainter {
  _ThumbnailPainter({required this.slots});

  final MembraneTransportLayoutSlots slots;

  @override
  void paint(Canvas canvas, Size size) {
    final tw = MembraneTransportLayoutPrimitives.thumbnailWidth;
    final th = MembraneTransportLayoutPrimitives.thumbnailHeight;
    final c = slots.thumbnailCenter;
    final rect = Rect.fromCenter(center: c, width: tw, height: th);
    final stroke = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, stroke);

    final line = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const inset = 0.5;
    final obs = slots.observation;
    const cr = MembraneTransportLayoutPrimitives.observationCornerRadius;
    canvas.drawLine(
      Offset(rect.left + inset, rect.top + inset),
      Offset(obs.left + cr / 2, obs.top + cr / 2),
      line,
    );
    canvas.drawLine(
      Offset(rect.left + inset, rect.bottom - inset),
      Offset(obs.left + cr / 2, obs.bottom - cr / 2),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _ThumbnailPainter oldDelegate) =>
      oldDelegate.slots.thumbnailCenter != slots.thumbnailCenter;
}
