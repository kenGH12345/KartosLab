/// Intro | Lab tabs. [MSS] `my-solar-system-main.ts` screen order.
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../my_solar_system_strings.dart';
import 'my_solar_system_screen.dart';

class MySolarSystemHome extends StatelessWidget {
  const MySolarSystemHome({super.key});

  static const String title = MySolarSystemStrings.title;
  static const Color accentColor = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      initialIndex: 0,
      tabs: const [
        KratosTab(
          label: MySolarSystemStrings.intro,
          icon: Icons.public,
          child: MySolarSystemScreen(isLab: false, embedded: true),
        ),
        KratosTab(
          label: MySolarSystemStrings.lab,
          icon: Icons.science_outlined,
          child: MySolarSystemScreen(isLab: true, embedded: true),
        ),
      ],
    );
  }
}
