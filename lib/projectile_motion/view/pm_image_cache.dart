import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 原版 PNG 的 ui.Image 缓存（CustomPainter 绘制用）。
class PmImageCache {
  PmImageCache(this.paths);

  final List<String> paths;
  final Map<String, ui.Image> _images = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  ui.Image? operator [](String path) => _images[path];

  Future<void> load() async {
    await Future.wait(paths.map((path) async {
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _images[path] = frame.image;
      } catch (e) {
        debugPrint('PmImageCache: failed to load $path: $e');
      }
    }));
    _loaded = true;
  }

  /// 便捷工厂：本 sim 全部素材
  static PmImageCache createDefault() => PmImageCache(const [
        'assets/simulations/projectile_motion/cannonBarrel.png',
        'assets/simulations/projectile_motion/cannonBaseBottom.png',
        'assets/simulations/projectile_motion/cannonBaseTop.png',
        'assets/simulations/projectile_motion/fireButton.png',
        'assets/simulations/projectile_motion/measuringTape.png',
        'assets/simulations/projectile_motion/baseball.png',
        'assets/simulations/projectile_motion/car1.png',
        'assets/simulations/projectile_motion/car2.png',
        'assets/simulations/projectile_motion/david.png',
        'assets/simulations/projectile_motion/flatirons.png',
        'assets/simulations/projectile_motion/football.png',
        'assets/simulations/projectile_motion/human1.png',
        'assets/simulations/projectile_motion/human2.png',
        'assets/simulations/projectile_motion/piano1.png',
        'assets/simulations/projectile_motion/piano2.png',
        'assets/simulations/projectile_motion/pumpkin1.png',
        'assets/simulations/projectile_motion/pumpkin2.png',
        'assets/simulations/projectile_motion/tankShell.png',
      ]);
}
