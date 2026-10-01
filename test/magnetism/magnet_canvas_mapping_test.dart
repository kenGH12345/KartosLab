import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/magnetism/magnet_and_compass/magnet_and_compass_constants.dart';
import 'package:kratos/magnetism/magnet_and_compass/model/magnet_canvas_mapping.dart';

void main() {
  group('MagnetCanvasMapping · Pixel Tablet 1280×800', () {
    // Origin / canvas size measured in M5-1 (NineGrid center after AppBar 44).
    const window = Size(1280, 800);
    const origin = Offset(104.53758301819164, 105.74250997011944);
    const canvas = Size(1070.924833963617, 632.514980059761);
    const mapping = MagnetCanvasMapping(
      windowSize: window,
      canvasSize: canvas,
      canvasOriginInWindow: origin,
    );

    test('window positions match original MediaQuery fractions', () {
      expect(mapping.magnetWindowPos.dx, closeTo(537.6, 1e-9));
      expect(mapping.magnetWindowPos.dy, closeTo(400.0, 1e-9));
      expect(mapping.compassWindowPos.dx, closeTo(768.0, 1e-9));
      expect(mapping.compassWindowPos.dy, closeTo(528.0, 1e-9));
      expect(mapping.fieldMeterWindowPos.dx, closeTo(358.4, 1e-9));
      expect(mapping.fieldMeterWindowPos.dy, closeTo(240.0, 1e-9));
    });

    test('canvas translation preserves magnet↔compass pixel vector', () {
      expect(mapping.magnetCanvasPos.dx, closeTo(537.6 - origin.dx, 1e-9));
      expect(mapping.magnetCanvasPos.dy, closeTo(400.0 - origin.dy, 1e-9));
      expect(mapping.compassCanvasPos.dx, closeTo(768.0 - origin.dx, 1e-9));
      expect(mapping.compassCanvasPos.dy, closeTo(528.0 - origin.dy, 1e-9));

      final windowVec = mapping.compassWindowPos - mapping.magnetWindowPos;
      final canvasVec = mapping.compassCanvasPos - mapping.magnetCanvasPos;
      expect(canvasVec.dx, closeTo(windowVec.dx, 1e-9));
      expect(canvasVec.dy, closeTo(windowVec.dy, 1e-9));
      expect(windowVec.dx, closeTo(230.4, 1e-9));
      expect(windowVec.dy, closeTo(128.0, 1e-9));
    });

    test('canvas translation preserves magnet↔field-meter pixel vector', () {
      expect(mapping.fieldMeterCanvasPos.dx, closeTo(358.4 - origin.dx, 1e-9));
      expect(mapping.fieldMeterCanvasPos.dy, closeTo(240.0 - origin.dy, 1e-9));
      final v = mapping.magnetCanvasPos - mapping.fieldMeterCanvasPos;
      expect(v.dx, closeTo(179.2, 1e-9));
      expect(v.dy, closeTo(160.0, 1e-9));
    });

    test('Pixel Tablet does not clamp magnet, compass, or field meter', () {
      final rawMagnet = mapping.windowToCanvas(mapping.magnetWindowPos);
      final rawCompass = mapping.windowToCanvas(mapping.compassWindowPos);
      final rawMeter = mapping.windowToCanvas(mapping.fieldMeterWindowPos);
      expect(mapping.magnetCanvasPos, rawMagnet);
      expect(mapping.compassCanvasPos, rawCompass);
      expect(mapping.fieldMeterCanvasPos, rawMeter);
    });

    test('object sizes are not part of the mapping', () {
      expect(kMagnetWidth, 500.0);
      expect(kMagnetHeight, 128.0);
      expect(kCompassRadius, 76.0);
    });

    test('field meter uses window fraction, not canvas fraction', () {
      expect(
        mapping.fieldMeterCanvasPos.dx,
        isNot(closeTo(canvas.width * 0.28, 1)),
      );
      expect(mapping.fieldMeterWindowPos.dx, closeTo(window.width * 0.28, 1e-9));
      expect(mapping.fieldMeterWindowPos.dy, closeTo(window.height * 0.30, 1e-9));
    });
  });

  group('MagnetCanvasMapping · clamp', () {
    test('1024×768 window-fraction vector (unclamped)', () {
      const mapping = MagnetCanvasMapping(
        windowSize: Size(1024, 768),
        canvasSize: Size(856.7, 605.7),
        canvasOriginInWindow: Offset(83.65, 103.15),
      );
      final v = mapping.magnetCanvasPos - mapping.fieldMeterCanvasPos;
      expect(v.dx, closeTo(1024 * 0.14, 0.5));
      expect(v.dy, closeTo(768 * 0.20, 0.5));
    });

    test('640×360 field meter may clamp to canvas', () {
      const mapping = MagnetCanvasMapping(
        windowSize: Size(640, 360),
        canvasSize: Size(535.5, 220),
        canvasOriginInWindow: Offset(52.25, 92),
      );
      expect(
        mapping.fieldMeterCanvasPos.dx,
        inInclusiveRange(
          MagnetCanvasMapping.fieldMeterWidth / 2,
          535.5 - MagnetCanvasMapping.fieldMeterWidth / 2,
        ),
      );
      expect(
        mapping.fieldMeterCanvasPos.dy,
        inInclusiveRange(
          MagnetCanvasMapping.fieldMeterHeight / 2,
          220 - MagnetCanvasMapping.fieldMeterHeight / 2,
        ),
      );
    });

    test('magnet clamps to canvas when window point sits outside center', () {
      const mapping = MagnetCanvasMapping(
        windowSize: Size(640, 360),
        canvasSize: Size(535.5, 220),
        canvasOriginInWindow: Offset(52.25, 92),
      );
      // window magnet (268.8, 180) → canvas (216.55, 88); half-width 250
      // is left of the in-canvas clamp range → x = 250.
      expect(mapping.magnetCanvasPos.dx, closeTo(kMagnetWidth / 2, 1e-9));
      expect(
        mapping.magnetCanvasPos.dy,
        inInclusiveRange(kMagnetHeight / 2, 220 - kMagnetHeight / 2),
      );
    });
  });
}
