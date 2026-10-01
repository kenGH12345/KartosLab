import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/model/data_sample.dart';
import 'package:kratos/energy_skate_park/widgets/probe_node_painter.dart';

/// Readout panel for Energy Sensor — values from [sample] only.
class EnergySensorReadout extends StatelessWidget {
  const EnergySensorReadout({super.key, required this.sample});

  final DataSample? sample;

  @override
  Widget build(BuildContext context) {
    String fmt(double? v, [String unit = 'J']) {
      if (v == null) return '—';
      return '${v.toStringAsFixed(1)} $unit';
    }

    Widget row(String label, Color c, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, color: c),
              const SizedBox(width: 6),
              SizedBox(
                width: 48,
                child: Text(label, style: const TextStyle(fontSize: 11)),
              ),
              Text(value, style: const TextStyle(fontSize: 11)),
            ],
          ),
        );

    final heightStr = sample == null
        ? '—'
        : '${(sample!.positionY - sample!.referenceHeight).toStringAsFixed(2)} m';

    return Material(
      elevation: 2,
      color: EspColors.panelFill,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: EspColors.panelStroke),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              EspStrings.energySensor,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            row(EspStrings.kinetic, EspColors.kineticEnergy,
                fmt(sample?.kineticEnergy)),
            row(EspStrings.potential, EspColors.potentialEnergy,
                fmt(sample?.potentialEnergy)),
            row(EspStrings.thermal, EspColors.thermalEnergy,
                fmt(sample?.thermalEnergy)),
            row(EspStrings.total, EspColors.totalEnergy,
                fmt(sample?.totalEnergy)),
            row(EspStrings.speed, Colors.black54, fmt(sample?.speed, 'm/s')),
            row(EspStrings.height, Colors.black54, heightStr),
          ],
        ),
      ),
    );
  }
}

/// Probe + halo painter layer (ProbeNode.ts + InspectedSampleHaloNode).
class EnergySensorPainter extends CustomPainter {
  EnergySensorPainter({
    required this.probeView,
    required this.haloView,
  });

  final Offset probeView;
  final Offset? haloView;

  static const Color _sensorColor = Color(0xFF675071);

  @override
  void paint(Canvas canvas, Size size) {
    if (haloView != null) {
      canvas.drawCircle(
        haloView!,
        8,
        Paint()..color = EspColors.haloFill,
      );
    }
    ProbeNodePainter(
      center: probeView,
      color: _sensorColor,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant EnergySensorPainter old) =>
      old.probeView != probeView || old.haloView != haloView;
}
