import 'package:flutter/material.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../curve_fitting_colors.dart';
import '../curve_fitting_strings.dart';
import '../model/curve_fitting_model.dart';
import '../widgets/cf_page_shell.dart';
import 'cf_screen_body.dart';

/// Home entry for Curve Fitting (single screen).
class CurveFittingHome extends StatefulWidget {
  const CurveFittingHome({super.key});

  static const String title = CurveFittingStrings.title;
  static const Color accentColor = CurveFittingColors.accent;

  @override
  State<CurveFittingHome> createState() => CurveFittingHomeState();
}

/// Public state for lifecycle tests (AC-1).
class CurveFittingHomeState extends State<CurveFittingHome> {
  late CurveFittingModel model;
  int generation = 0;

  @override
  void initState() {
    super.initState();
    _createModel();
  }

  void _createModel() {
    model = CurveFittingModel();
    generation++;
  }

  /// PhET Screen re-entry: fresh model (no cross-visit residue).
  void reinitializeForTest() {
    setState(_createModel);
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(CurveFittingHome.title),
        backgroundColor: CurveFittingHome.accentColor,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ColoredBox(
        color: CurveFittingColors.screenBackground,
        child: NineGridLayout(
          backgroundColor: CurveFittingColors.screenBackground,
          center: CfPageShell(
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) => CfScreenBody(model: model),
            ),
          ),
        ),
      ),
    );
  }
}
