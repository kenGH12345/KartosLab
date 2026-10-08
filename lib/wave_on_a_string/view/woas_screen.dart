import 'package:flutter/material.dart';

import '../model/woas_model.dart';
import 'woas_play_area.dart';
import 'package:kratos/wave_on_a_string/woas_strings.dart';

/// Single-screen Wave on a String — PhET `WOASScreen`.
///
/// Home entry (物理 → 光学与波动) pushes this widget directly
/// (Faraday's Law / Sound peer — no intermediate Hub).
///
/// Ownership:
/// - [WoasModel] owned here when [model] is null (disposed on Back).
/// - [SimulationClock] owned by [WoasPlayArea] (disposed with PlayArea).
class WoasScreen extends StatefulWidget {
  const WoasScreen({
    super.key,
    this.model,
    this.autoStartClock = true,
  });

  /// Home card / AppBar title (PhET English name).
  static const String title = WoasStrings.title;

  /// Home card subtitle.
  static const String subtitle = '绳波 · 反射 · 阻尼 · 张力';

  /// Home card accent (KartosLab Material card chrome).
  static const Color accentColor = Color(0xFF0E7490);

  /// Optional injected model for tests. When null, Screen owns a fresh model.
  final WoasModel? model;
  final bool autoStartClock;

  @override
  State<WoasScreen> createState() => WoasScreenState();
}

class WoasScreenState extends State<WoasScreen> {
  late final WoasModel model;
  late final bool _ownsModel;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      model = widget.model!;
      _ownsModel = false;
    } else {
      model = WoasModel();
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
      backgroundColor: const Color(0xFFFFFFB7),
      appBar: AppBar(
        title: const Text(
          WoasScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: WoasScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        // Top already accounted by AppBar; keep left/right/bottom insets.
        top: false,
        child: WoasPlayArea(
          model: model,
          autoStartClock: widget.autoStartClock,
        ),
      ),
    );
  }
}
