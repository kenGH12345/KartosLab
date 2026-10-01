import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../masb_constants.dart';
import 'bounce_screen.dart';
import 'lab_screen.dart';
import 'stretch_screen.dart';

class MasbHome extends StatelessWidget {
  const MasbHome({super.key});

  static const String title = 'Masses and Springs: Basics';
  static const String subtitle = 'Stretch · Bounce · Lab';
  static const Color accentColor = Color(0xFF1D4ED8);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(MasbConstants.simBackgroundArgb),
        appBar: AppBar(
          title: const Text(title),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFBFDBFE),
            tabs: [
              Tab(text: 'Stretch'),
              Tab(text: 'Bounce'),
              Tab(text: 'Lab'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            final tabs = DefaultTabController.of(context);
            return KratosTabSwitcher(
              controller: tabs,
              children: const [
                StretchScreen(),
                BounceScreen(),
                LabScreen(),
              ],
            );
          },
        ),
      ),
    );
  }
}
