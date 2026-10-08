import 'package:flutter/material.dart';
import 'package:kratos/color_vision/cv_assets.dart';
import 'package:kratos/color_vision/view/rgb_screen_view.dart';
import 'package:kratos/color_vision/view/single_bulb_screen_view.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/color_vision/color_vision_strings.dart';

/// Color Vision home — PhET tabs: Single Bulb | RGB Bulbs.
class ColorVisionHome extends StatelessWidget {
  const ColorVisionHome({super.key});

  static const String title = ColorVisionStrings.title;
  static const String subtitle = ColorVisionStrings.subtitle;
  static const Color accentColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      tabs: [
        KratosTab(
          label: ColorVisionStrings.singleBulb,
          tabIcon: Image.asset(
            CvAssets.singleColorLightIcon,
            width: 22,
            height: 22,
          ),
          child: const SingleBulbScreenView(),
        ),
        KratosTab(
          label: ColorVisionStrings.rgbBulbs,
          tabIcon: Image.asset(
            CvAssets.flashlightIcon,
            width: 22,
            height: 22,
          ),
          child: const RgbScreenView(),
        ),
      ],
    );
  }
}
