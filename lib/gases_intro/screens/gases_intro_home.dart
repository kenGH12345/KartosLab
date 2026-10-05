import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../model/ideal_gas_law_model.dart';
import '../view/layout_policy.dart';
import '../widgets/gases_intro_shell.dart';

/// Gases Intro — Intro | Laws tabs.
///
/// V5: no FittedBox. [LayoutBuilder] computes uniform [layoutScale] from
/// [GasesIntroLayoutPolicy.fitScale], then sizes the shell to physical
/// layoutBounds × scale (letterboxed if needed).
class GasesIntroHome extends StatefulWidget {
  const GasesIntroHome({super.key});

  static const String title = 'Gases Intro';
  static const Color accentColor = Color(0xFF0284C7);

  @override
  State<GasesIntroHome> createState() => _GasesIntroHomeState();
}

class _GasesIntroHomeState extends State<GasesIntroHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final IdealGasLawModel introModel;
  late final IdealGasLawModel lawsModel;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );
    introModel = IdealGasLawModel(hasHoldConstantControls: false);
    lawsModel = IdealGasLawModel(hasHoldConstantControls: true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    introModel.dispose();
    lawsModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(GasesIntroHome.title),
        backgroundColor: GasesIntroHome.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          tabs: const [
            Tab(text: 'Intro'),
            Tab(text: 'Laws'),
          ],
        ),
      ),
      body: ColoredBox(
        color: const Color(0xFF000000),
        child: NineGridLayout(
          backgroundColor: const Color(0xFF000000),
          center: LayoutBuilder(
            builder: (context, constraints) {
              final scale = GasesIntroLayoutPolicy.fitScale(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final size = GasesIntroLayoutPolicy.physicalSize(scale);
              return Center(
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: KratosTabSwitcher(
                    controller: _tabs,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    backdropColor: const Color(0xFF000000),
                    incomingScale: 0.985,
                    children: [
                      GasesIntroShell(
                        model: introModel,
                        showHoldConstant: false,
                        layoutScale: scale,
                      ),
                      GasesIntroShell(
                        model: lawsModel,
                        showHoldConstant: true,
                        layoutScale: scale,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
