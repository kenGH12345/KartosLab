/// Balancing Act — PHASE 2 Chinese (synced with `loc.*`).
abstract final class BaStrings {
  static const String title = '平衡木';
  static const String subtitle = '介绍 · 平衡实验室 · 游戏';
  static const String screenIntro = '介绍';
  static const String screenBalanceLab = '平衡实验室';
  static const String screenGame = '游戏';

  static const String show = '显示';
  static const String massLabels = '质量标签';
  static const String forcesFromObjects = '物体的力';
  static const String level = '关卡';
  static const String position = '位置';
  static const String none = '无';
  static const String rulers = '尺子';
  static const String marks = '刻度';
  static const String kg = 'kg';
  static const String meters = '米';
  static const String bricks = '砖块';
  static const String people = '人物';
  static const String mysteryObjects = '神秘物体';
  static const String unknownMassLabel = '?';

  static const String selectLevel = '选择关卡';
  static const String startOver = '重新开始';
  static const String check = '检查';
  static const String next = '下一步';
  static const String tryAgain = '再试一次';
  static const String showAnswer = '显示答案';
  static const String balanceMe = '让我平衡！';
  static const String whatIsTheMass = '质量是多少？';
  static const String whatWillHappen = '会发生什么？';
  static const String continueLabel = '继续';
  static const String score = '得分';

  static String massLabel(double kg) {
    final v = kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toString();
    return '$v $kgUnit';
  }

  static const String kgUnit = 'kg';

  static String challengeBanner(
          int level1Based, int challenge1Based, int total) =>
      '第 $level1Based 关，挑战 $challenge1Based / $total';
}
