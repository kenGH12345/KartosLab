import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'buoyancy_texture_asset.dart';

/// Loads PhET material color maps once for [BuoyancyScenePainter].
class BuoyancyTextureCache {
  BuoyancyTextureCache._();

  static final BuoyancyTextureCache instance = BuoyancyTextureCache._();

  final Map<String, ui.Image> _images = {};
  Future<void>? _loading;

  bool get isReady => _images.isNotEmpty;

  Iterable<String> get paths => _images.keys;

  ui.Image? operator [](String? assetPath) =>
      assetPath == null ? null : _images[assetPath];

  Future<void> ensureLoaded() {
    return _loading ??= _loadAll();
  }

  Future<void> _loadAll() async {
    for (final path in BuoyancyTextureAsset.materialColorMaps) {
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _images[path] = frame.image;
      } catch (_) {
        // Keep fallback solid colors when an asset is missing.
      }
    }
  }
}
