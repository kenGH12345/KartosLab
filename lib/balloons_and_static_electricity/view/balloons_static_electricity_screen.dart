import 'package:flutter/material.dart';

import '../model/balloons_static_electricity_model.dart';
import 'base_view_layout.dart';
import 'balloons_static_electricity_view.dart';

/// Single-screen Balloons and Static Electricity — PhET `BASEScreen`.
///
/// Home entry (物理 → 电学与电路) pushes this widget directly.
class BalloonsStaticElectricityScreen extends StatefulWidget {
  const BalloonsStaticElectricityScreen({
    super.key,
    this.model,
    this.autoStartClock = true,
    this.enableAudio = true,
  });

  final BalloonsStaticElectricityModel? model;
  final bool autoStartClock;
  final bool enableAudio;

  static const String title = 'Balloons and Static Electricity';
  static const String subtitle = '摩擦起电 · 诱导电荷 · 静电吸引';
  static const Color accentColor = Color(0xFFF79722);

  /// Home card icon — peer Material style (JT / CAF); not a custom Home system.
  static const IconData homeIcon = Icons.bubble_chart_rounded;

  @override
  State<BalloonsStaticElectricityScreen> createState() =>
      BalloonsStaticElectricityScreenState();
}

class BalloonsStaticElectricityScreenState
    extends State<BalloonsStaticElectricityScreen> {
  late final BalloonsStaticElectricityModel model;
  late final bool _ownsModel;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      model = widget.model!;
      _ownsModel = false;
    } else {
      model = BalloonsStaticElectricityModel();
      _ownsModel = true;
    }
  }

  @override
  void dispose() {
    if (_ownsModel) {
      model.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaseViewLayout.backgroundColor,
      appBar: AppBar(
        title: const Text(
          BalloonsStaticElectricityScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: BalloonsStaticElectricityScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sx = constraints.maxWidth / BaseViewLayout.layoutWidth;
            final sy = constraints.maxHeight / BaseViewLayout.layoutHeight;
            final s = sx < sy ? sx : sy;
            return Align(
              // PhET custom layout: pin to bottom so tether/wall cut by nav bar.
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: BaseViewLayout.layoutWidth * s,
                height: BaseViewLayout.layoutHeight * s,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  child: BalloonsStaticElectricityPlayArea(
                    model: model,
                    autoStartClock: widget.autoStartClock,
                    enableAudio: widget.enableAudio,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
