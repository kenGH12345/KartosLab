import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../model/screen_models.dart';
import '../vector_addition_colors.dart';
import '../vector_addition_strings.dart';
import '../widgets/va_screen_body.dart';

class VectorAdditionHome extends StatefulWidget {
  const VectorAdditionHome({super.key});

  static const String title = VectorAdditionStrings.title;
  static const Color accentColor = VectorAdditionColors.accent;

  @override
  State<VectorAdditionHome> createState() => VectorAdditionHomeState();
}

/// Public state for lifecycle tests (AC-1).
class VectorAdditionHomeState extends State<VectorAdditionHome>
    with SingleTickerProviderStateMixin {
  late Explore1DModel explore1d;
  late Explore2DModel explore2d;
  late LabModel lab;
  late EquationsModel equations;
  int generation = 0;
  late final TabController _tabs;

  static const _tabLabels = [
    VectorAdditionStrings.explore1d,
    VectorAdditionStrings.explore2d,
    VectorAdditionStrings.lab,
    VectorAdditionStrings.equations,
  ];

  @override
  void initState() {
    super.initState();
    _createModels();
    _tabs = TabController(length: 4, vsync: this);
  }

  void _createModels() {
    explore1d = Explore1DModel();
    explore2d = Explore2DModel();
    lab = LabModel();
    equations = EquationsModel();
    generation++;
  }

  /// PhET Screen re-entry: fresh models (no cross-visit residue).
  void reinitializeForTest() {
    setState(_createModels);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PhET Joist: simulation viewport starts immediately; screen selector is a
    // bottom navbar — not a Material TabBar above the Equations UI.
    return Scaffold(
      appBar: AppBar(
        title: const Text(VectorAdditionHome.title),
        backgroundColor: VectorAdditionHome.accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: KratosTabSwitcher(
              controller: _tabs,
              children: [
                VaScreenBody(model: explore1d, embedded: true),
                VaScreenBody(model: explore2d, embedded: true),
                VaScreenBody(model: lab, embedded: true),
                VaScreenBody(model: equations, embedded: true),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            elevation: 4,
            child: SafeArea(
              top: false,
              child: KratosTabBar(
                controller: _tabs,
                accentColor: VectorAdditionHome.accentColor,
                tabs: [
                  for (final label in _tabLabels)
                    KratosTab(label: label, child: const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
