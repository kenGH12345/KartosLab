/// Buoyancy UI strings — Chinese defaults (PHASE 3).
/// Physics / model / renderer unchanged; bags only.
class BuoyancyStrings {
  BuoyancyStrings._();

  static const String title = '浮力';
  static const String subtitle = '比较 · 探索 · 实验室 · 形状 · 应用';
  static const String compare = '比较';
  static const String explore = '探索';
  static const String lab = '实验室';
  static const String shapes = '形状';
  static const String applications = '应用';
  static const String resetAll = '全部重置';

  static const String mass = '质量';
  static const String volume = '体积';
  static const String density = '密度';
  static const String material = '材料';
  static const String gravity = '重力';
  static const String forces = '力';
  static const String buoyancy = '浮力';
  static const String contact = '接触力';
  static const String forceValues = '力数值';
  static const String massValues = '质量数值';
  static const String depthLines = '深度线';
  static const String vectorZoom = '矢量缩放';

  static const String blocks = '物块';
  static const String sameMass = '相同质量';
  static const String sameVolume = '相同体积';
  static const String sameDensity = '相同密度';
  static const String oneBlock = '一个物块';
  static const String twoBlocks = '两个物块';

  static const String fluidDensity = '流体密度';
  static const String fluidDisplaced = '排开的流体';
  static const String objectDensity = '物体密度';
  static const String percentSubmerged = '浸没百分比';
  static const String densityComparison = '密度比较';
  static const String custom = '自定义';
  static const String shape = '形状';
  static const String width = '宽度';
  static const String height = '高度';

  static const String earth = '地球';
  static const String moon = '月球';
  static const String jupiter = '木星';
  static const String planetX = '行星 X';

  static const String water = '水';
  static const String seawater = '海水';
  static const String oil = '油';
  static const String gasoline = '汽油';
  static const String honey = '蜂蜜';
  static const String mercury = '汞';
  static const String brick = '砖';

  static String massWithUnit(String value) => '质量 $value kg';
  static String volumeWithUnit(String value) => '体积 $value L';
  static String widthPercent(String value) => '宽度 $value%';
  static String heightPercent(String value) => '高度 $value%';
  static String blockDensity(String tag, String value) =>
      '物块 $tag: $value kg/m³';
  static String fluidDensityValue(String value) => '流体: $value kg/m³';
  static String submergedPercent(String tag, String value) =>
      '物块 $tag: $value %';

  static String fluidLabel(String id) {
    return switch (id) {
      'gasoline' => gasoline,
      'oil' => oil,
      'water' => water,
      'seawater' => seawater,
      'honey' => honey,
      'mercury' => mercury,
      'fluidA' => '流体 A',
      'fluidB' => '流体 B',
      'fluidC' => '流体 C',
      'fluidD' => '流体 D',
      'fluidE' => '流体 E',
      'fluidF' => '流体 F',
      _ => id,
    };
  }

  static String gravityLabel(String id) {
    return switch (id) {
      'moon' => moon,
      'earth' => earth,
      'jupiter' => jupiter,
      'planetX' => planetX,
      _ => id,
    };
  }

  static String shapeKindLabel(String kindName) {
    return switch (kindName) {
      'block' => '方块',
      'ellipsoid' => '椭球',
      'verticalCylinder' => '竖圆柱',
      'horizontalCylinder' => '横圆柱',
      'cone' => '圆锥',
      'invertedCone' => '倒圆锥',
      'duck' => '鸭子',
      'bottle' => '瓶子',
      'boat' => '船',
      _ => kindName,
    };
  }
}
