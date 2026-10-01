import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_wave_visualization_chrome.dart';

void main() {
  group('QwiWaveScale.computeNiceScale', () {
    test('photon-scale region (~7 µm) yields µm bar near 50 px', () {
      // DISPLAY_WAVELENGTHS * 700 nm ≈ 7e-6 m across 420 px.
      final s = QwiWaveScale.computeNiceScale(
        regionWidthMeters: 7e-6,
        regionWidthPixels: 420,
      );
      expect(s.barPixels, inInclusiveRange(25, 100));
      expect(s.barPixels, closeTo(50, 30));
      final label = QwiWaveScale.formatDistance(s.distanceMeters);
      expect(label, contains('µm'));
    });

    test('formatDistance switches units', () {
      expect(QwiWaveScale.formatDistance(2e-3), '2 mm');
      expect(QwiWaveScale.formatDistance(5e-6), '5 µm');
      expect(QwiWaveScale.formatDistance(400e-9), '400 nm');
    });
  });
}
