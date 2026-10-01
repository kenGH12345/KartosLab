import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../capacitance/model/capacitance_model.dart';
import '../capacitance/screens/capacitance_interactive_screen_body.dart';
import '../clb_colors.dart';
import '../clb_constants.dart';
import '../clb_strings.dart';
import '../common/model/clb_model.dart';
import '../light_bulb/model/clb_light_bulb_model.dart';
import '../light_bulb/screens/light_bulb_interactive_screen_body.dart';

/// Capacitor Lab: Basics — Home entry (Capacitance | Light Bulb).
///
/// Shared [ClbSharedState] mirrors PhET `switchUsedProperty` across screens.
/// Each tab owns its own circuit model; business logic stays in ScreenBodies.
class CapacitorLabBasicsHome extends StatefulWidget {
  const CapacitorLabBasicsHome({super.key});

  static const String title = ClbStrings.title;
  static const Color accentColor = Color(0xFF2563EB);

  @override
  State<CapacitorLabBasicsHome> createState() => CapacitorLabBasicsHomeState();
}

class CapacitorLabBasicsHomeState extends State<CapacitorLabBasicsHome> {
  late ClbSharedState shared;
  late CapacitanceModel capacitance;
  late ClbLightBulbModel lightBulb;

  @override
  void initState() {
    super.initState();
    shared = ClbSharedState();
    capacitance = CapacitanceModel(shared: shared);
    lightBulb = ClbLightBulbModel(shared: shared);
  }

  @override
  void dispose() {
    capacitance.dispose();
    lightBulb.dispose();
    shared.dispose();
    super.dispose();
  }

  /// Test hook — simulates pop/push re-entry by recreating models.
  void reinitializeForTest() {
    capacitance.dispose();
    lightBulb.dispose();
    shared.dispose();
    shared = ClbSharedState();
    capacitance = CapacitanceModel(shared: shared);
    lightBulb = ClbLightBulbModel(shared: shared);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: CapacitorLabBasicsHome.title,
      accentColor: CapacitorLabBasicsHome.accentColor,
      tabs: [
        KratosTab(
          label: ClbStrings.screenCapacitance,
          tabIcon: const _ClbTabIcon(ClbConstants.assetCapacitanceScreenIcon),
          color: ClbColors.capacitance,
          child: CapacitanceInteractiveScreenBody(model: capacitance),
        ),
        KratosTab(
          label: ClbStrings.screenLightBulb,
          tabIcon: const _ClbTabIcon(ClbConstants.assetLightBulbBase),
          color: ClbColors.screenBackground,
          child: LightBulbInteractiveScreenBody(model: lightBulb),
        ),
      ],
    );
  }
}

class _ClbTabIcon extends StatelessWidget {
  const _ClbTabIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 28,
      height: 28,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
