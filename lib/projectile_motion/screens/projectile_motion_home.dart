import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/projectile_motion/controller/projectile_motion_controller.dart';
import 'package:kratos/projectile_motion/model/screen_models.dart';
import 'package:kratos/projectile_motion/pm_assets.dart';
import 'package:kratos/projectile_motion/pm_colors.dart';
import 'package:kratos/projectile_motion/pm_strings.dart';
import 'package:kratos/projectile_motion/view/pm_image_cache.dart';
import 'package:kratos/projectile_motion/widgets/pm_screen_layout.dart';
import 'package:kratos/projectile_motion/widgets/pm_simulation_shell.dart';

class ProjectileMotionHome extends StatelessWidget {
  const ProjectileMotionHome({super.key});

  static const String title = PmStrings.title;
  static const String subtitle = PmStrings.subtitle;
  static const Color accentColor = PmColors.accent;

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      tabs: const [
        KratosTab(
          label: PmStrings.screenIntro,
          tabIcon: _TabIcon(PmAssets.introScreenIcon),
          child: _ScreenBody(kind: PmScreenKind.intro),
        ),
        KratosTab(
          label: PmStrings.screenVectors,
          tabIcon: _TabIcon(PmAssets.football),
          child: _ScreenBody(kind: PmScreenKind.vectors),
        ),
        KratosTab(
          label: PmStrings.screenDrag,
          tabIcon: _TabIcon(PmAssets.tankShell),
          child: _ScreenBody(kind: PmScreenKind.drag),
        ),
        KratosTab(
          label: PmStrings.screenLab,
          tabIcon: _TabIcon(PmAssets.cannonBarrel),
          child: _ScreenBody(kind: PmScreenKind.lab),
        ),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, height: 22, fit: BoxFit.contain);
  }
}

class _ScreenBody extends StatefulWidget {
  const _ScreenBody({required this.kind});

  final PmScreenKind kind;

  @override
  State<_ScreenBody> createState() => _ScreenBodyState();
}

class _ScreenBodyState extends State<_ScreenBody>
    with TickerProviderStateMixin {
  late final ProjectileMotionController controller;
  final PmImageCache images = PmImageCache.createDefault();

  @override
  void initState() {
    super.initState();
    final model = switch (widget.kind) {
      PmScreenKind.intro => IntroModel(),
      PmScreenKind.vectors => VectorsModel(),
      PmScreenKind.drag => DragModel(),
      PmScreenKind.lab => LabModel(),
    };
    final viewProperties = switch (widget.kind) {
      PmScreenKind.intro => PmViewProperties(
          hasForceVectors: false,
          hasAccelerationVectors: true,
          usesDisplayEnumeration: false,
        ),
      PmScreenKind.vectors => PmViewProperties(
          hasForceVectors: true,
          hasAccelerationVectors: true,
          usesDisplayEnumeration: true,
        ),
      PmScreenKind.drag => PmViewProperties(
          hasForceVectors: true,
          hasAccelerationVectors: false,
          usesDisplayEnumeration: true,
        ),
      PmScreenKind.lab => PmViewProperties(
          hasForceVectors: false,
          hasAccelerationVectors: false,
          usesDisplayEnumeration: false,
        ),
    };
    controller = ProjectileMotionController(model, viewProperties)
      ..attach(this);
    images.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PmSimulationShell(
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, _) => PmScreenLayout(
          controller: controller,
          images: images,
          kind: widget.kind,
        ),
      ),
    );
  }
}
