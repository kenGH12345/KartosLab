import 'package:flutter/material.dart';

import '../../domain/detector_mode.dart';
import '../../render_data/experiment/detector_render_data.dart';
import '../../render_data/experiment/hit_render_data.dart';
import '../../view/common/qwi_coordinate_transform.dart';
import 'fraunhofer_renderer.dart';
import 'hit_renderer.dart';

/// Composites intensity or hits into the Experiment detector frame.
class DetectorRenderer {
  const DetectorRenderer();

  void paint(
    Canvas canvas,
    Size size,
    DetectorRenderData data,
    QwiCoordinateTransform transform,
  ) {
    final rect = transform.detectorRect;

    // Frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(2)),
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (data.mode == DetectorMode.intensity) {
      const FraunhoferRenderer().paint(canvas, size, data.fraunhofer, transform);
    } else {
      canvas.drawRect(rect, Paint()..color = Colors.black);
      if (data.isEmitting || data.hits.isNotEmpty) {
        const HitRenderer().paint(
          canvas,
          HitRenderData.fromHits(
            allHits: data.hits,
            sourceType: data.sourceType,
            wavelengthNm: data.wavelengthNm,
            brightness: data.brightness,
          ),
          transform,
        );
      }
    }
  }
}

class DetectorPainter extends CustomPainter {
  DetectorPainter({
    required this.data,
    required this.transform,
  });

  final DetectorRenderData data;
  final QwiCoordinateTransform transform;

  @override
  void paint(Canvas canvas, Size size) {
    const DetectorRenderer().paint(canvas, size, data, transform);
  }

  @override
  bool shouldRepaint(covariant DetectorPainter oldDelegate) {
    return oldDelegate.data.mode != data.mode ||
        oldDelegate.data.isEmitting != data.isEmitting ||
        oldDelegate.data.hits.length != data.hits.length ||
        oldDelegate.data.brightness != data.brightness ||
        oldDelegate.data.wavelengthNm != data.wavelengthNm ||
        oldDelegate.data.scaleIndex != data.scaleIndex ||
        oldDelegate.data.fraunhofer.visibleHalfWidthM != data.fraunhofer.visibleHalfWidthM ||
        oldDelegate.data.fraunhofer.slitConfiguration != data.fraunhofer.slitConfiguration ||
        oldDelegate.data.fraunhofer.slitSeparationMm != data.fraunhofer.slitSeparationMm ||
        oldDelegate.data.fraunhofer.screenDistanceM != data.fraunhofer.screenDistanceM ||
        oldDelegate.data.fraunhofer.effectiveWavelengthM != data.fraunhofer.effectiveWavelengthM ||
        oldDelegate.data.fraunhofer.sourceStrength != data.fraunhofer.sourceStrength ||
        oldDelegate.transform.scaleIndex != transform.scaleIndex ||
        !_sameIntensities(oldDelegate.data.fraunhofer.intensities, data.fraunhofer.intensities);
  }

  static bool _sameIntensities(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    if (a.isEmpty) return true;
    return a.first == b.first && a.last == b.last && a[a.length ~/ 2] == b[b.length ~/ 2];
  }
}
