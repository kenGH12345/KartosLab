import 'package:flutter/material.dart';

import 'applications/model/buoyancy_applications_model.dart';
import 'applications/view/buoyancy_applications_screen.dart';
import 'compare/model/buoyancy_compare_model.dart';
import 'compare/view/buoyancy_compare_screen.dart';
import 'explore/model/buoyancy_explore_model.dart';
import 'explore/view/buoyancy_explore_screen.dart';
import 'lab/model/buoyancy_lab_model.dart';
import 'lab/view/buoyancy_lab_screen.dart';
import 'shapes/model/buoyancy_shapes_model.dart';
import 'shapes/view/buoyancy_shapes_screen.dart';

enum BuoyancySimScreen { compare, explore, lab, shapes, applications }

/// Five-screen host. Each screen owns a persistent Model (no cross-leak).
/// Only the active screen mounts a PlayArea ticker — inactive models pause.
/// Not Home integration.
class BuoyancySimHost extends StatefulWidget {
  const BuoyancySimHost({super.key, this.initial = BuoyancySimScreen.compare});
  final BuoyancySimScreen initial;

  @override
  State<BuoyancySimHost> createState() => _BuoyancySimHostState();
}

class _BuoyancySimHostState extends State<BuoyancySimHost> {
  late BuoyancySimScreen _screen = widget.initial;

  late final BuoyancyCompareModel compare = BuoyancyCompareModel();
  late final BuoyancyExploreModel explore = BuoyancyExploreModel();
  late final BuoyancyLabModel lab = BuoyancyLabModel();
  late final BuoyancyShapesModel shapes = BuoyancyShapesModel();
  late final BuoyancyApplicationsModel applications =
      BuoyancyApplicationsModel();

  @override
  void initState() {
    super.initState();
    _applyVisibility();
  }

  @override
  void dispose() {
    compare.dispose();
    explore.dispose();
    lab.dispose();
    shapes.dispose();
    applications.dispose();
    super.dispose();
  }

  void _select(BuoyancySimScreen next) {
    if (next == _screen) {
      return;
    }
    setState(() {
      _screen = next;
      _applyVisibility();
    });
  }

  void _applyVisibility() {
    compare.pause();
    explore.pause();
    lab.pause();
    shapes.pause();
    applications.pause();
    switch (_screen) {
      case BuoyancySimScreen.compare:
        compare.resume();
      case BuoyancySimScreen.explore:
        explore.resume();
      case BuoyancySimScreen.lab:
        lab.resume();
      case BuoyancySimScreen.shapes:
        shapes.resume();
      case BuoyancySimScreen.applications:
        applications.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 19, 165, 224),
      child: Column(
        children: [
          Material(
            color: const Color(0xFF1A1A1A),
            elevation: 4,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    for (final s in BuoyancySimScreen.values)
                      Expanded(
                        child: InkWell(
                          key: Key('buoyancy_tab_${s.name}'),
                          onTap: () => _select(s),
                          child: ColoredBox(
                            color: _screen == s
                                ? const Color(0xFF333333)
                                : Colors.transparent,
                            child: Center(
                              child: Text(
                                s.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _screen == s
                                      ? const Color(0xFFFFEE58)
                                      : Colors.white,
                                  fontWeight: _screen == s
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _screen.index,
              sizing: StackFit.expand,
              children: [
                BuoyancyCompareScreen(model: compare),
                BuoyancyExploreScreen(model: explore),
                BuoyancyLabScreen(model: lab),
                BuoyancyShapesScreen(model: shapes),
                BuoyancyApplicationsScreen(model: applications),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
