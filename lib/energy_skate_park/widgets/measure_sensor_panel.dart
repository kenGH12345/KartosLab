import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/measure_controller.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';
import 'package:kratos/energy_skate_park/widgets/energy_sensor.dart';

/// Left-side Energy Sensor panel (Measure screen — SkaterPathSensorNode.ts).
class MeasureSensorPanel extends StatelessWidget {
  const MeasureSensorPanel({super.key, required this.controller});

  final MeasureController controller;

  @override
  Widget build(BuildContext context) {
    final mvt = EspMvt.forPlayArea(const Size(600, 400));
    final mm = controller.measureModel;
    final sample = mm.findNearestSample(mm.sensorProbePosition, mvt);

    return Material(
      elevation: 2,
      color: const Color(0xFFE8D4F8),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF9B59B6)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Energy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF5B2C6F),
              ),
            ),
            const SizedBox(height: 6),
            EnergySensorReadout(sample: sample),
            const SizedBox(height: 8),
            const Text(
              '拖曳探针至路径采样点',
              style: TextStyle(fontSize: 9, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
