/// PhET Density strings — Chinese defaults (PHASE 3).
/// Keys remain stable for adapters / tests; units preserved.
class DensityStrings {
  DensityStrings._();

  static const String title = '密度';
  static const String intro = '介绍';
  static const String compare = '比较';
  static const String mystery = '神秘材料';
  static const String mass = '质量';
  static const String volume = '体积';
  static const String density = '密度';
  static const String material = '材料';
  static const String resetAll = '全部重置';
  static const String oneBlock = '一个物块';
  static const String twoBlocks = '两个物块';
  static const String sameMass = '相同质量';
  static const String sameVolume = '相同体积';
  static const String sameDensity = '相同密度';
  static const String set1 = '组 1';
  static const String set2 = '组 2';
  static const String set3 = '组 3';
  static const String random = '随机';
  static const String densityTable = '密度表';
  static const String kg = 'kg';
  static const String liters = 'L';
  static const String kgPerL = 'kg/L';
  static const String refreshRandom = '刷新';
  static const String grabHint = '抓取';
  static const String aboutTitle = '关于密度';
  static const String aboutBody =
      '改编自 PhET Interactive Simulations\n'
      'https://phet.colorado.edu/en/simulations/density\n\n'
      'Density simulation source: GPL-3.0\n'
      'Shared model/view (density-buoyancy-common): GPL-3.0\n\n'
      'Material textures: CC0 (cc0textures.com)\n\n'
      '本 Flutter 移植并非 PhET 官方应用。';

  static String materialName(String stringKey) {
    const names = <String, String>{
      'density.material.styrofoam': '泡沫塑料',
      'density.material.wood': '木材',
      'density.material.ice': '冰',
      'density.material.pvc': 'PVC',
      'density.material.brick': '砖',
      'density.material.aluminum': '铝',
      'density.material.custom': '自定义',
      'density.material.gasoline': '汽油',
      'density.material.apple': '苹果',
      'density.material.human': '人体',
      'density.material.water': '水',
      'density.material.glass': '玻璃',
      'density.material.diamond': '金刚石',
      'density.material.titanium': '钛',
      'density.material.steel': '钢',
      'density.material.copper': '铜',
      'density.material.lead': '铅',
      'density.material.gold': '金',
    };
    return names[stringKey] ?? stringKey;
  }

  static String grabMass(String tag) => '抓取质量 $tag';
}
