import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import 'intro_screen.dart';
import 'more_tools_screen.dart';
import 'prisms_screen.dart';

/// Production entry. Demo hub and QA AppBars stay off this route.
class BendingLightHome extends StatelessWidget {
  const BendingLightHome({super.key});

  static const String title = 'Bending Light';
  static const String subtitle = '折射 · 棱镜 · 传感器';
  static const Color accentColor = Color(0xFF1D4ED8);

  @override
  Widget build(BuildContext context) {
    return const KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      tabs: [
        KratosTab(label: 'Intro', child: IntroScreen(embedded: true)),
        KratosTab(label: 'Prisms', child: PrismsScreen(embedded: true)),
        KratosTab(label: 'More Tools', child: MoreToolsScreen(embedded: true)),
      ],
    );
  }
}
