/// 从 Flutter assets 加载核素数据表。
///
/// 资产路径与 pubspec.yaml 的 `assets/data/` 声明对应。
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import 'nuclide_repository.dart';
import 'nuclide_table.dart';

class NuclideDataLoader {
  const NuclideDataLoader._();

  static const String assetPath = 'assets/data/nuclide_table.json';

  static Future<NuclideRepository> load({AssetBundle? bundle}) async {
    final jsonStr =
        await (bundle ?? rootBundle).loadString(assetPath);
    return NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  }
}
