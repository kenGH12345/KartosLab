/// Build-a-Molecule 入口：Single | Multiple | Playground。
///
/// [已确认] `build-a-molecule-main.ts` 顺序；Tab 文案对齐用户基线 /
/// PhET `title.single|multiple|playground`。
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../controller/bam_controller.dart';
import '../data/bam_molecule_catalog.dart';
import '../model/bam_complete_molecule.dart';
import '../widgets/bam_molecule_thumbnail.dart';
import 'multiple_screen.dart';
import 'playground_screen.dart';
import 'single_screen.dart';

class BuildAMoleculeHome extends StatelessWidget {
  const BuildAMoleculeHome({
    super.key,
    this.singleController,
    this.multipleController,
    this.playgroundController,
  });

  final BamController? singleController;
  final BamController? multipleController;
  final BamController? playgroundController;

  static const String title = '搭建分子';
  static const String singleTabLabel = '单个';
  static const String multipleTabLabel = '多个';
  static const String playgroundTabLabel = '练习场';
  static const Color accentColor = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    BamCompleteMolecule? h2o;
    BamCompleteMolecule? o2;
    BamCompleteMolecule? acetic;
    try {
      final common = BamMoleculeCatalog.commonMolecules;
      h2o = common['H2O'];
      o2 = common['O2'];
      acetic = common['C2H4O2'];
    } catch (_) {
      // Catalog not loaded yet (first paint) — fallback icons.
    }

    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: singleTabLabel,
          tabIcon: _tabIcon(h2o),
          child: SingleScreen(
            embedded: true,
            controller: singleController,
          ),
        ),
        KratosTab(
          label: multipleTabLabel,
          tabIcon: _tabIcon(o2),
          child: MultipleScreen(
            embedded: true,
            controller: multipleController,
          ),
        ),
        KratosTab(
          label: playgroundTabLabel,
          tabIcon: _tabIcon(acetic),
          child: PlaygroundScreen(
            embedded: true,
            controller: playgroundController,
          ),
        ),
      ],
    );
  }

  static Widget _tabIcon(BamCompleteMolecule? molecule) {
    if (molecule == null) {
      return const Icon(Icons.science, size: 22);
    }
    return SizedBox(
      width: 28,
      height: 28,
      child: ClipOval(
        child: BamMoleculeThumbnail(molecule: molecule),
      ),
    );
  }
}
