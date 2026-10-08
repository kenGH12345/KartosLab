/// Build a Nucleus 入口：Decay | Chart Intro。
///
/// [已确认] 原版 `new Sim(..., [new DecayScreen(), new ChartIntroScreen()])`
/// 顺序：Decay 在前，默认第一屏。
/// [已确认] 工程多屏先例：一张 Home 卡 + [KratosTabbedScreen]，无第二 Navigator。
///
/// Tab 切走会 dispose 子 State（工程无 AutomaticKeepAlive）。
/// [有意差异] 原版 joist Screen 常驻、切屏保留粒子；本工程退出 Tab / 返回 Home
/// 即销毁 Controller + Clock，再进入是新实例。不复制 issue #220。
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../chart_intro/controller/chart_intro_controller.dart';
import '../controller/build_a_nucleus_controller.dart';
import 'build_a_nucleus_screen.dart';
import 'chart_intro_screen.dart';

class BuildANucleusHome extends StatelessWidget {
  const BuildANucleusHome({
    super.key,
    this.decayController,
    this.chartIntroController,
  });

  /// 测试可注入；生产路径为 null，由各 Screen 自行加载。
  final BuildANucleusController? decayController;
  final ChartIntroController? chartIntroController;

  /// [已确认] Home 卡 title + 原版 `build-a-nucleus.title`
  static const String title = '构建原子核';

  /// [已确认] 现有 Decay AppBar「构建原子核 · 衰变」+ 原版 `screen.decay` = Decay
  static const String decayTabLabel = '衰变';

  /// [已确认] 原版 `screen.chartIntro` = "Chart Intro" → 图表介绍
  static const String chartIntroTabLabel = '图表介绍';

  /// Home 卡同色。[已确认] `home_screen.dart` 构建原子核卡片
  static const Color accentColor = Color(0xFFB45309);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: decayTabLabel,
          icon: Icons.blur_circular,
          child: BuildANucleusScreen(
            embedded: true,
            controller: decayController,
          ),
        ),
        KratosTab(
          label: chartIntroTabLabel,
          icon: Icons.grid_on,
          child: ChartIntroScreen(
            embedded: true,
            controller: chartIntroController,
            tickOnClock: chartIntroController == null,
          ),
        ),
      ],
    );
  }
}
