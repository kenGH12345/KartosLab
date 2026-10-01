/// Build an Atom 正式入口：Atom | Symbol | Game。
///
/// PhET `build-an-atom-main.ts` 顺序：AtomScreen → SymbolScreen → GameScreen。
/// 工程先例：一张 Home 卡 + [KratosTabbedScreen]（见构建原子核 / 同位素）。
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import 'atom_screen.dart';
import 'game_screen.dart';
import 'symbol_screen.dart';

class BuildAnAtomHome extends StatelessWidget {
  const BuildAnAtomHome({super.key, this.initialTab = 0});

  /// 0 = Atom, 1 = Symbol, 2 = Game.
  final int initialTab;

  /// Home 卡 title（中文命名规范，对齐「构建原子核」）。
  static const String title = '构建原子';

  static const String subtitle = '质子 · 中子 · 电子 · 符号 · 游戏';

  /// PhET Atom / accent used on Home card.
  static const Color accentColor = Color(0xFF1177AA);

  /// Original PhET `atomIcon.png` for Home thumbnail.
  static const String homeIconAsset = 'assets/build_an_atom/images/atomIcon.png';

  static const String atomTabLabel = '原子';
  static const String symbolTabLabel = '符号';
  static const String gameTabLabel = '游戏';

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      initialIndex: initialTab.clamp(0, 2),
      tabs: const [
        KratosTab(
          label: atomTabLabel,
          icon: Icons.blur_on,
          child: BuildAnAtomAtomScreen(embedded: true),
        ),
        KratosTab(
          label: symbolTabLabel,
          icon: Icons.text_fields,
          child: BuildAnAtomSymbolScreen(embedded: true),
        ),
        KratosTab(
          label: gameTabLabel,
          icon: Icons.sports_esports_outlined,
          child: BuildAnAtomGameScreen(embedded: true),
        ),
      ],
    );
  }
}
