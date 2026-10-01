import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:kratos/energy_skate_park/model/skater_image_set.dart';

/// Loads and caches PhET skater PNG assets for all characters.
class SkaterImageCache {
  SkaterImageCache._();

  static final SkaterImageCache instance = SkaterImageCache._();

  final Map<String, ui.Image> _cache = {};

  Future<ui.Image?> load(String assetPath) async {
    if (_cache.containsKey(assetPath)) return _cache[assetPath];
    try {
      final data = await rootBundle.load(assetPath);
      final codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _cache[assetPath] = frame.image;
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  Future<({ui.Image? left, ui.Image? right})> loadSet(int index) async {
    final set = SkaterImageSet.at(index);
    final left = await load(set.leftAsset);
    final right = await load(set.rightAsset);
    return (left: left, right: right);
  }

  Future<ui.Image?> loadHeadshot(int index) async {
    return load(SkaterImageSet.at(index).headshotAsset);
  }

  void clear() => _cache.clear();
}
