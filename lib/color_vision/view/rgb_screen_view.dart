import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';
import 'package:kratos/color_vision/cv_assets.dart';
import 'package:kratos/color_vision/model/cv_photon.dart';
import 'package:kratos/color_vision/model/rgb_model.dart';
import 'package:kratos/color_vision/view/cv_icon_radio.dart';
import 'package:kratos/color_vision/view/cv_thought_bubbles.dart';
import 'package:kratos/color_vision/view/cv_time_controls.dart';
import 'package:kratos/color_vision/view/painters/photon_canvas_painter.dart';
import 'package:kratos/color_vision/view/rgb_slider.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// PhET `RGBScreenView` — FittedBox 768×504, always photon-style beams.
class RgbScreenView extends StatefulWidget {
  const RgbScreenView({
    super.key,
    this.model,
    this.autoStartClock = true,
  });

  final RgbModel? model;
  final bool autoStartClock;

  @override
  State<RgbScreenView> createState() => _RgbScreenViewState();
}

class _RgbScreenViewState extends State<RgbScreenView>
    with TickerProviderStateMixin {
  late final RgbModel _model;
  late final SimulationClock _clock;
  late final bool _ownsModel;

  static const double _layoutW = ColorVisionConstants.layoutWidth;
  static const double _layoutH = ColorVisionConstants.layoutHeight;
  static const double _cy = ColorVisionConstants.contentCenterY;
  static const double _beamAngle = math.pi / 6;
  static const double _flashlightScale = 0.73;
  static const double _headScale = 0.96;

  static const double _headIw = 300;
  static const double _headIh = 434;
  static const double _silIw = 296;
  static const double _silIh = 427;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? RgbModel();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => _model.step(dt);
    if (widget.autoStartClock) {
      _clock.play();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    if (_ownsModel) {
      _model.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : _layoutW;
          final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
              ? constraints.maxHeight
              : _layoutH;
          return SizedBox(
            width: w,
            height: h,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _layoutW,
                height: _layoutH,
                child: ListenableBuilder(
                  listenable: _model,
                  builder: (context, _) => _buildPlayArea(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayArea() {
    final m = _model;
    final headIsExterior = m.headMode == HeadMode.noBrain;
    final headW = (headIsExterior ? _headIw : _silIw) * _headScale;
    final headH = (headIsExterior ? _headIh : _silIh) * _headScale;
    final headLeft = headIsExterior ? 75.0 : 78.0;
    final headBottom = _layoutH + 15;
    final headTop = headBottom - headH;

    // Flashlight intrinsic sizes
    const redIw = 177.0, redIh = 131.0;
    const greenIw = 173.0, greenIh = 67.0;
    const blueIw = 178.0, blueIh = 129.0;
    final redH = redIh * _flashlightScale;
    final greenH = greenIh * _flashlightScale;
    final blueH = blueIh * _flashlightScale;
    final redW = redIw * _flashlightScale;
    final greenW = greenIw * _flashlightScale;
    final blueW = blueIw * _flashlightScale;

    // VBox spacing 85, right: 684 (= maxX - 84), centerY: 232
    const flashlightSpacing = 85.0;
    final vboxHeight = redH + greenH + blueH + flashlightSpacing * 2;
    final vboxTop = _cy - vboxHeight / 2;
    final vboxRight = _layoutW - 84;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 20,
          top: 5,
          child: CvThoughtBubbles(perceivedColor: m.perceivedColor),
        ),

        // Head back
        Positioned(
          left: headLeft,
          top: headTop,
          width: headW,
          height: headH,
          child: Image.asset(
            headIsExterior ? CvAssets.head : CvAssets.silhouette,
            fit: BoxFit.fill,
          ),
        ),

        // Photon beams (between head layers)
        // Red: x:280,y:190, rot -π/6, len 300
        _photonBeam(
          left: 280,
          top: 190,
          length: ColorVisionConstants.redBeamLength,
          rotation: -_beamAngle,
          color: const Color(0xFFFF0000),
          photons: m.redBeam.photons,
        ),
        // Blue: x:320,y:145, rot +π/6, len 330
        _photonBeam(
          left: 320,
          top: 145,
          length: ColorVisionConstants.blueBeamLength,
          rotation: _beamAngle,
          color: const Color(0xFF0000FF),
          photons: m.blueBeam.photons,
        ),
        // Green: x:320, centerY:232, rot 0, len 250
        _photonBeam(
          left: 320,
          top: _cy - ColorVisionConstants.beamHeight / 2,
          length: ColorVisionConstants.greenBeamLength,
          rotation: 0,
          color: const Color(0xFF00FF00),
          photons: m.greenBeam.photons,
        ),

        // Head front
        Positioned(
          left: headLeft,
          top: headTop,
          width: headW,
          height: headH,
          child: Image.asset(
            headIsExterior ? CvAssets.headFront : CvAssets.silhouetteFront,
            fit: BoxFit.fill,
          ),
        ),

        // Flashlights VBox
        Positioned(
          right: _layoutW - vboxRight,
          top: vboxTop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _flashlightWithLabel(
                asset: CvAssets.flashlightNeg45Deg,
                width: redW,
                height: redH,
                label: 'Red',
                labelRotation: -29 * math.pi / 180,
                labelDx: 45,
                labelDy: 3,
              ),
              SizedBox(height: flashlightSpacing),
              _flashlightWithLabel(
                asset: CvAssets.flashlight0Deg,
                width: greenW,
                height: greenH,
                label: '绿',
                labelRotation: 0,
                labelDx: 45,
                labelDy: 10,
              ),
              SizedBox(height: flashlightSpacing),
              _flashlightWithLabel(
                asset: CvAssets.flashlightPos45Deg,
                width: blueW,
                height: blueH,
                label: 'Blue',
                labelRotation: 7 * math.pi / 45,
                labelDx: 46,
                labelDy: 32,
              ),
            ],
          ),
        ),

        // RGB sliders VBox — spacing 15, right: 738 (= maxX - 30)
        Positioned(
          right: 30,
          top: vboxTop + (vboxHeight - 3 * 140 - 30) / 2,
          child: Column(
            children: [
              RgbSlider(
                value: m.redIntensity,
                onChanged: m.setRedIntensity,
                channelColor: Colors.red,
              ),
              const SizedBox(height: 15),
              RgbSlider(
                value: m.greenIntensity,
                onChanged: m.setGreenIntensity,
                channelColor: Colors.green,
              ),
              const SizedBox(height: 15),
              RgbSlider(
                value: m.blueIntensity,
                onChanged: m.setBlueIntensity,
                channelColor: Colors.blue,
              ),
            ],
          ),
        ),

        // Exterior / Interior
        Positioned(
          left: headLeft + headW / 2 - 42 - 40,
          bottom: 22,
          child: CvIconRadioGroup<HeadMode>(
            values: const [HeadMode.noBrain, HeadMode.brain],
            assetPaths: const [CvAssets.headIcon, CvAssets.silhouetteIcon],
            groupValue: m.headMode,
            onChanged: m.setHeadMode,
            iconScale: 0.6,
            xMargin: 4,
            yMargin: 4,
          ),
        ),

        Positioned(
          left: 381 - 40,
          bottom: 20,
          child: CvTimeControls(
            isPlaying: m.playing,
            onPlayPause: () => m.setPlaying(!m.playing),
            onStep: m.manualStep,
          ),
        ),

        Positioned(
          right: 30,
          bottom: 5,
          child: KratosResetAllButton(
            key: const Key('color_vision_rgb_reset_all'),
            radius: ColorVisionConstants.resetAllRadius,
            onPressed: m.reset,
          ),
        ),
      ],
    );
  }

  Widget _photonBeam({
    required double left,
    required double top,
    required double length,
    required double rotation,
    required Color color,
    required List<RgbPhoton> photons,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        alignment: Alignment.topLeft,
        child: CustomPaint(
          size: Size(length, ColorVisionConstants.beamHeight),
          painter: PhotonCanvasPainter(
            photons: photons,
            fixedColor: color,
            skipZeroIntensity: true,
          ),
        ),
      ),
    );
  }

  Widget _flashlightWithLabel({
    required String asset,
    required double width,
    required double height,
    required String label,
    required double labelRotation,
    required double labelDx,
    required double labelDy,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(asset, width: width, height: height, fit: BoxFit.fill),
          Positioned(
            left: width / 2 + labelDx - 52.5,
            top: height / 2 + labelDy - 16.5,
            child: Transform.rotate(
              angle: labelRotation,
              child: Container(
                width: 105,
                height: 33,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
