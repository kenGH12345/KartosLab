import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_screen.dart';

/// Acid-Base Solutions Home shell — PhET 2 screens (Intro + My Solution).
///
/// Wired into KartosLab Home under 化学 → 溶液与浓度.
/// Does not alter Intro / My Solution chemistry or view internals.
class AcidBaseSolutionsHome extends StatelessWidget {
  const AcidBaseSolutionsHome({super.key});

  static const String title = '酸碱溶液';
  static const String subtitle = 'Intro · My Solution · 酸碱电离';
  static const Color accentColor = Color(0xFF155E75);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: AcidBaseSolutionsHome.title,
      accentColor: AcidBaseSolutionsHome.accentColor,
      tabs: const [
        KratosTab(label: 'Intro', child: AbsIntroScreen()),
        KratosTab(label: 'My Solution', child: AbsMySolutionScreen()),
      ],
    );
  }
}
