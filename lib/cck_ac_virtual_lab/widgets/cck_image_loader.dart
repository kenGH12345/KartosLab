import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../cck_assets.dart';

Future<Map<String, ui.Image>> loadCckImages() async {
  const paths = <String, String>{
    'battery': CckAssets.battery,
    'resistor': CckAssets.resistor,
    'fuse': CckAssets.fuse,
    'coin': CckAssets.coin,
    'paperClip': CckAssets.paperClip,
    'pencil': CckAssets.pencil,
    'thinPencil': CckAssets.thinPencil,
    'eraser': CckAssets.eraser,
    'dollar': CckAssets.dollar,
    'wireIcon': CckAssets.wireIcon,
    'lightBulbBack': CckAssets.lightBulbBack,
    'lightBulbFront': CckAssets.lightBulbFront,
    'lightBulbMiddle': CckAssets.lightBulbMiddle,
    'lightBulbMiddleIcon': CckAssets.lightBulbMiddleIcon,
    'voltmeterBody': CckAssets.voltmeterBody,
    'probeRed': CckAssets.probeRed,
    'probeBlack': CckAssets.probeBlack,
    'ammeterBody': CckAssets.ammeterBody,
    'fire': CckAssets.fire,
  };
  final out = <String, ui.Image>{};
  for (final e in paths.entries) {
    final data = await rootBundle.load(e.value);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    out[e.key] = frame.image;
  }
  return out;
}
