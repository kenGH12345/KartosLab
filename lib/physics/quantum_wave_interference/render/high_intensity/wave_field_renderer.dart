import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../render_data/high_intensity/wave_field_render_data.dart';
import '../../view/common/qwi_layout.dart';

/// Paints cached [WaveFieldRenderData] into the 420×385 wave region.
///
/// Never evaluates WaveKernel — only blits the precomputed RGBA buffer.
class WaveFieldRenderer {
  const WaveFieldRenderer();

  Future<ui.Image> decodeImage(WaveFieldRenderData data) => _rawRgbaToImage(data);

  static Future<ui.Image> _rawRgbaToImage(WaveFieldRenderData data) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(data.rgba);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: data.gridWidth,
      height: data.gridHeight,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void paintImage(Canvas canvas, ui.Image image, Rect dest) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dest,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }
}

/// Synchronous painter using per-pixel draw when image not yet decoded — for tests use [WaveFieldImagePainter].
class WaveFieldPixelPainter extends CustomPainter {
  WaveFieldPixelPainter({required this.data, required this.dest});

  final WaveFieldRenderData data;
  final Rect dest;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(dest, Paint()..color = Colors.black);
    if (!data.isEmitting || data.rgba.isEmpty) {
      return;
    }
    final cellW = dest.width / data.gridWidth;
    final cellH = dest.height / data.gridHeight;
    for (var gy = 0; gy < data.gridHeight; gy++) {
      for (var gx = 0; gx < data.gridWidth; gx++) {
        final i = (gy * data.gridWidth + gx) * 4;
        final color = Color.fromARGB(
          data.rgba[i + 3],
          data.rgba[i],
          data.rgba[i + 1],
          data.rgba[i + 2],
        );
        if (color.r == 0 && color.g == 0 && color.b == 0) {
          continue;
        }
        canvas.drawRect(
          Rect.fromLTWH(dest.left + gx * cellW, dest.top + gy * cellH, cellW + 0.5, cellH + 0.5),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaveFieldPixelPainter oldDelegate) {
    return oldDelegate.data.time != data.time ||
        oldDelegate.data.displayMode != data.displayMode ||
        oldDelegate.data.wavelengthNm != data.wavelengthNm ||
        oldDelegate.data.isEmitting != data.isEmitting;
  }
}

class WaveFieldImagePainter extends CustomPainter {
  WaveFieldImagePainter({required this.image, Rect? dest})
      : dest = dest ?? QwiLayout.hiWaveRegionRect;

  final ui.Image? image;
  final Rect dest;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(dest, Paint()..color = Colors.black);
    final img = image;
    if (img == null) {
      return;
    }
    const WaveFieldRenderer().paintImage(canvas, img, dest);
  }

  @override
  bool shouldRepaint(covariant WaveFieldImagePainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.dest != dest;
}
