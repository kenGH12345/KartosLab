import 'package:flutter/material.dart';

import '../john_travoltage_assets.dart';
import 'jt_view_layout.dart';

/// Static scene — PhET `BackgroundNode.js`.
///
/// Layer: wallpaper → window → floor → rug → door → body.
class BackgroundNode extends StatelessWidget {
  const BackgroundNode({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Wallpaper Pattern tile
          Positioned(
            left: JtViewLayout.wallpaperLeft,
            top: JtViewLayout.wallpaperTop,
            width: JtViewLayout.wallpaperWidth,
            height: JtViewLayout.wallpaperHeight,
            child: Image.asset(
              JohnTravoltageAssets.wallpaper,
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              alignment: Alignment.topLeft,
              filterQuality: FilterQuality.medium,
            ),
          ),
          // Window
          Positioned(
            left: JtViewLayout.windowX,
            top: JtViewLayout.windowY,
            child: Transform.scale(
              scale: JtViewLayout.windowScale,
              alignment: Alignment.topLeft,
              child: Image.asset(
                JohnTravoltageAssets.window,
                width: JtViewLayout.windowImageSize.width,
                height: JtViewLayout.windowImageSize.height,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          // Floor Pattern tile
          Positioned(
            left: JtViewLayout.floorLeft,
            top: JtViewLayout.floorTop,
            width: JtViewLayout.floorWidth,
            height: JtViewLayout.floorHeight,
            child: Image.asset(
              JohnTravoltageAssets.floor,
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              alignment: Alignment.topLeft,
              filterQuality: FilterQuality.medium,
            ),
          ),
          // Rug
          Positioned(
            left: JtViewLayout.rugX,
            top: JtViewLayout.rugY,
            child: Transform.scale(
              scale: JtViewLayout.rugScale,
              alignment: Alignment.topLeft,
              child: Image.asset(
                JohnTravoltageAssets.rug,
                width: JtViewLayout.rugImageSize.width,
                height: JtViewLayout.rugImageSize.height,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          // Door (knob is part of this PNG — do not draw separately)
          Positioned(
            left: JtViewLayout.doorX,
            top: JtViewLayout.doorY,
            child: Transform.scale(
              scale: JtViewLayout.doorScale,
              alignment: Alignment.topLeft,
              child: Image.asset(
                JohnTravoltageAssets.door,
                width: JtViewLayout.doorImageSize.width,
                height: JtViewLayout.doorImageSize.height,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          // John body (static)
          Positioned(
            left: JtViewLayout.bodyX,
            top: JtViewLayout.bodyY,
            child: Transform.scale(
              scale: JtViewLayout.bodyScale,
              alignment: Alignment.topLeft,
              child: Image.asset(
                JohnTravoltageAssets.body,
                width: JtViewLayout.bodyImageSize.width,
                height: JtViewLayout.bodyImageSize.height,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
