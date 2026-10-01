import 'package:flutter/material.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../gflb_colors.dart';
import '../gflb_strings.dart';
import '../model/gravity_model.dart';
import '../widgets/gflb_page_shell.dart';
import 'gflb_screen_body.dart';

/// Home entry for Gravity Force Lab: Basics (single screen).
class GflbHome extends StatefulWidget {
  const GflbHome({super.key});

  static const String title = GflbStrings.title;
  static const Color accentColor = GflbColors.accent;

  @override
  State<GflbHome> createState() => GflbHomeState();
}

/// Public state for lifecycle tests (AC-1).
class GflbHomeState extends State<GflbHome> {
  late GravityModel model;
  int generation = 0;

  @override
  void initState() {
    super.initState();
    _createModel();
  }

  void _createModel() {
    model = GravityModel();
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
        title: const Text(GflbHome.title),
        backgroundColor: GflbHome.accentColor,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ColoredBox(
        color: GflbColors.screenBackground,
        child: NineGridLayout(
          backgroundColor: GflbColors.screenBackground,
          center: GflbPageShell(
            child: GflbScreenBody(model: model),
          ),
        ),
      ),
    );
  }
}
