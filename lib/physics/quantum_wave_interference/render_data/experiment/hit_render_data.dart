import '../../constants/qwi_constants.dart';
import '../../domain/hit.dart';
import '../../domain/source_type.dart';

/// Hits subset for canvas rendering (capped separately from model buffer).
class HitRenderData {
  const HitRenderData({
    required this.hits,
    required this.sourceType,
    required this.wavelengthNm,
    required this.brightness,
  });

  final List<DetectorHit> hits;
  final SourceType sourceType;
  final double wavelengthNm;
  final double brightness;

  factory HitRenderData.fromHits({
    required List<DetectorHit> allHits,
    required SourceType sourceType,
    required double wavelengthNm,
    required double brightness,
    int maxRendered = QwiConstants.maxRenderedHits,
  }) {
    final start = allHits.length > maxRendered ? allHits.length - maxRendered : 0;
    return HitRenderData(
      hits: allHits.sublist(start),
      sourceType: sourceType,
      wavelengthNm: wavelengthNm,
      brightness: brightness,
    );
  }
}
