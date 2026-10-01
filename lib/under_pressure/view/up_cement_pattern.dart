import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Loads original FPAF `cementTextureDark.jpg` once for Pattern strokes.
///
/// Source: `new Pattern(cementTextureDark_jpg)` on pool cement borders.
class UpCementPattern {
  UpCementPattern._();

  static ui.Image? _image;
  static Future<ui.Image>? _loading;

  static const String assetPath =
      'assets/simulations/under_pressure/images/cementTextureDark.jpg';

  static Future<ui.Image> ensureLoaded() {
    if (_image != null) return Future.value(_image!);
    return _loading ??= _load();
  }

  static Future<ui.Image> _load() async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _image = frame.image;
    return _image!;
  }

  /// Paint a path with tiled cement texture stroke (source lineWidth 4).
  static void strokePath(
    Canvas canvas,
    Path path, {
    double lineWidth = 4,
    double patternScale = 0.5,
  }) {
    final img = _image;
    if (img == null) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineWidth
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFF6B6B6B),
      );
      return;
    }
    final matrix = Matrix4.diagonal3Values(patternScale, patternScale, 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeJoin = StrokeJoin.round
      ..shader = ImageShader(
        img,
        TileMode.repeated,
        TileMode.repeated,
        matrix.storage,
      );
    canvas.drawPath(path, paint);
  }
}
