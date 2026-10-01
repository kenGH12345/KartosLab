import 'package:flutter/material.dart';

import 'net_force_screen.dart';
import 'motion_screen_v2.dart';
import '../../common/widgets/kratos_tab_bar.dart';

/// Forces and Motion: Basics — 4 PhET screens.
class ForcesHome extends StatelessWidget {
  const ForcesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const KratosTabbedScreen(
      title: 'Forces and Motion: Basics',
      accentColor: Color(0xFF166534),
      tabBarPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      tabs: [
        KratosTab(
          label: 'Net Force',
          child: NetForceScreen(),
        ),
        KratosTab(
          label: 'Motion',
          child: MotionScreenV2(style: MotionScreenStyleTab.motion),
        ),
        KratosTab(
          label: 'Friction',
          child: MotionScreenV2(style: MotionScreenStyleTab.friction),
        ),
        KratosTab(
          label: 'Acceleration',
          child: MotionScreenV2(style: MotionScreenStyleTab.acceleration),
        ),
      ],
    );
  }
}
