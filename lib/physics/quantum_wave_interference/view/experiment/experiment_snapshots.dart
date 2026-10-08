import 'package:flutter/material.dart';

import 'experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// Camera / gallery + 4 snapshot dots (PhET FrontFacingDetectorScreenNode).
class ExperimentSnapshotIconColumn extends StatelessWidget {
  const ExperimentSnapshotIconColumn({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.scene.snapshots.length;
    final canTake = count < 4;
    final canView = count > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            return Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < count ? const Color(0xFF337AB7) : const Color(0xFFCCCCCC),
                  border: Border.all(color: const Color(0xFF888888), width: 0.8),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        _IconBtn(
          key: const Key('qwi_take_snapshot'),
          tooltip: QwiStrings.takeSnapshot,
          enabled: canTake,
          onTap: canTake ? () => controller.takeSnapshot() : null,
          child: const CustomPaint(size: Size(18, 14), painter: _CameraIconPainter()),
        ),
        const SizedBox(height: 4),
        _IconBtn(
          key: const Key('qwi_view_snapshots'),
          tooltip: QwiStrings.viewSnapshots,
          enabled: canView,
          onTap: canView ? () => controller.setSnapshotPanelOpen(true) : null,
          child: const CustomPaint(size: Size(18, 14), painter: _GalleryIconPainter()),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    super.key,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? const Color(0xFFE8E8E8) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 32,
            height: 28,
            child: Opacity(opacity: enabled ? 1 : 0.35, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

class _CameraIconPainter extends CustomPainter {
  const _CameraIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, 3, size.width - 2, size.height - 4), const Radius.circular(2)),
      p,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2 + 1), 3.2, p);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.55, 1, 5, 2.5), Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GalleryIconPainter extends CustomPainter {
  const _GalleryIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawRect(Rect.fromLTWH(3, 1, size.width - 5, size.height - 4), p);
    canvas.drawRect(Rect.fromLTWH(1, 3, size.width - 5, size.height - 4), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExperimentSnapshotPanel extends StatelessWidget {
  const ExperimentSnapshotPanel({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.snapshotPanelOpen) {
      return const SizedBox.shrink();
    }
    final snaps = controller.scene.snapshots.snapshots;
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            key: const Key('qwi_snapshot_panel'),
            width: 420,
            height: 280,
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(QwiStrings.snapshots, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      key: const Key('qwi_snapshot_close'),
                      onPressed: () => controller.setSnapshotPanelOpen(false),
                      child: Text(QwiStrings.close),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snaps.length,
                    itemBuilder: (context, i) {
                      final s = snaps[i];
                      return ListTile(
                        key: Key('qwi_snapshot_$i'),
                        title: Text(QwiStrings.snapshotN(s.snapshotNumber)),
                        subtitle: Text(
                          '${s.sourceType.name} · λ=${s.wavelengthNm.toStringAsFixed(0)} · '
                          'hits=${s.hits.length}',
                        ),
                        trailing: TextButton(
                          key: Key('qwi_snapshot_delete_$i'),
                          onPressed: () => controller.deleteSnapshot(i),
                          child: Text(QwiStrings.delete, style: const TextStyle(fontSize: 11)),
                        ),
                      );
                    },
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
