import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/view/under_pressure_screen.dart';

/// Home entry shell for Under Pressure (物理 → 密度与浮力).
///
/// Owns [UnderPressureController] for the route lifetime; dispose on Back.
/// Production play area remains [UnderPressureScreen] (4 internal scenes).
class UnderPressureHome extends StatefulWidget {
  const UnderPressureHome({super.key, this.controller});

  /// Injected only for tests; Home creates a fresh controller.
  final UnderPressureController? controller;

  static const String title = 'Under Pressure';
  static const String subtitle = '压强 · 深度 · 密度';
  static const Color accentColor = Color(0xFF155E75);

  /// Home card Material icon (KartosLab strategy — not a PhET PNG substitute).
  static const IconData homeIcon = Icons.compress_rounded;

  @override
  State<UnderPressureHome> createState() => UnderPressureHomeState();
}

class UnderPressureHomeState extends State<UnderPressureHome> {
  late final UnderPressureController controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      controller = widget.controller!;
      _ownsController = false;
    } else {
      controller = UnderPressureController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          UnderPressureHome.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: UnderPressureHome.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        top: false,
        child: UnderPressureScreen(controller: controller),
      ),
    );
  }
}
