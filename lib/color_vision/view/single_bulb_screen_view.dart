import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';
import 'package:kratos/color_vision/cv_assets.dart';
import 'package:kratos/color_vision/model/single_bulb_model.dart';
import 'package:kratos/color_vision/model/visible_color.dart';
import 'package:kratos/color_vision/view/cv_gaussian_slider.dart';
import 'package:kratos/color_vision/view/cv_icon_radio.dart';
import 'package:kratos/color_vision/view/cv_spectrum_slider.dart';
import 'package:kratos/color_vision/view/cv_thought_bubbles.dart';
import 'package:kratos/color_vision/view/cv_time_controls.dart';
import 'package:kratos/color_vision/view/painters/photon_canvas_painter.dart';
import 'package:kratos/color_vision/view/painters/solid_beam_painter.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// PhET `SingleBulbScreenView` — FittedBox 768×504 black play area.
class SingleBulbScreenView extends StatefulWidget {
  const SingleBulbScreenView({
    super.key,
    this.model,
    this.autoStartClock = true,
  });

  final SingleBulbModel? model;
  final bool autoStartClock;

  @override
  State<SingleBulbScreenView> createState() => _SingleBulbScreenViewState();
}

class _SingleBulbScreenViewState extends State<SingleBulbScreenView>
    with TickerProviderStateMixin {
  late final SingleBulbModel _model;
  late final SimulationClock _clock;
  late final bool _ownsModel;

  static const double _layoutW = ColorVisionConstants.layoutWidth;
  static const double _layoutH = ColorVisionConstants.layoutHeight;
  static const double _cy = ColorVisionConstants.contentCenterY;

  // Intrinsic PNG sizes
  static const double _flashlightIw = 173;
  static const double _flashlightIh = 67;
  static const double _filterIw = 74;
  static const double _filterIh = 194;
  static const double _headIw = 300;
  static const double _headIh = 434;
  static const double _silIw = 296;
  static const double _silIh = 427;

  static const double _flashlightScale = 0.85;
  static const double _filterScale = 0.7;
  static const double _headScale = 0.96;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? SingleBulbModel();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => _model.step(dt);
    if (widget.autoStartClock) {
      _clock.play();
    }
    _applyFilterOffset();
  }

  void _applyFilterOffset() {
    final flashlightW = _flashlightIw * _flashlightScale;
    final flashlightLeft = (_layoutW - 40) - flashlightW;
    final filterW = _filterIw * _filterScale;
    final filterRight = flashlightLeft - 100;
    final filterLeft = filterRight - filterW;
    final filterCenterX = filterLeft + filterW / 2;
    _model.photonBeam.filterOffset =
        filterCenterX - ColorVisionConstants.photonBeamStartX;
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
    final flashlightW = _flashlightIw * _flashlightScale;
    final flashlightH = _flashlightIh * _flashlightScale;
    final flashlightRight = _layoutW - 40;
    final flashlightLeft = flashlightRight - flashlightW;
    final flashlightTop = (_cy + 3) - flashlightH / 2;

    final filterW = _filterIw * _filterScale;
    final filterH = _filterIh * _filterScale;
    final filterRight = flashlightLeft - 100;
    final filterLeft = filterRight - filterW;
    final filterTop = _cy - filterH / 2;
    final filterCenterX = filterLeft + filterW / 2;

    final beamVisible = m.flashlightOn && m.beamType == BeamType.beam;
    final photonVisible = m.beamType == BeamType.photon;
    final coloredLight = m.lightType == LightType.colored;

    // Solid beam colors
    final flashColor = VisibleColor.wavelengthToColor(m.flashlightWavelength);
    final filterColor = VisibleColor.wavelengthToColor(m.filterWavelength);
    late final Color leftBeam;
    late final Color rightBeam;
    late final Color wholeBeam;
    if (m.lightType == LightType.white && m.filterVisible) {
      leftBeam = filterColor;
      rightBeam = Colors.white;
      wholeBeam = Colors.white;
    } else if (m.lightType == LightType.white && !m.filterVisible) {
      leftBeam = m.perceivedColor;
      rightBeam = Colors.white;
      wholeBeam = Colors.white;
    } else if (m.lightType == LightType.colored && m.filterVisible) {
      leftBeam = m.perceivedColor;
      rightBeam = flashColor;
      wholeBeam = flashColor;
    } else {
      leftBeam = m.perceivedColor;
      rightBeam = flashColor;
      wholeBeam = flashColor;
    }

    final beamBounds = Rect.fromLTRB(
      filterCenterX - (_filterWRadiusX(filterW)) - 130,
      _cy - 48,
      flashlightLeft + 15,
      _cy + 54,
    );

    final headIsExterior = m.headMode == HeadMode.noBrain;
    final headW = (headIsExterior ? _headIw : _silIw) * _headScale;
    final headH = (headIsExterior ? _headIh : _silIh) * _headScale;
    final headLeft = headIsExterior ? 75.0 : 78.0;
    final headBottom = _layoutH + 15;
    final headTop = headBottom - headH;

    final radiusX = filterW / 2 - 13;
    final radiusY = filterH / 2 - 12;

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
            filterQuality: FilterQuality.medium,
          ),
        ),

        // Filter right PNG + half-ellipse (behind beams)
        if (m.filterVisible) ...[
          Positioned(
            left: filterLeft,
            top: filterTop,
            width: filterW,
            height: filterH,
            child: Image.asset(CvAssets.filterRight, fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FilterHalfEllipsePainter(
                  center: Offset(filterCenterX - 1, _cy),
                  radiusX: radiusX,
                  radiusY: radiusY,
                  color: filterColor,
                  left: false,
                ),
              ),
            ),
          ),
        ],

        // Solid beam
        if (beamVisible)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SolidBeamPainter(
                  bounds: beamBounds,
                  cutoffX: filterCenterX,
                  filterVisible: m.filterVisible,
                  leftColor: leftBeam,
                  rightColor: rightBeam,
                  wholeColor: wholeBeam,
                ),
              ),
            ),
          ),

        // Photon beam canvas
        if (photonVisible)
          Positioned(
            left: ColorVisionConstants.photonBeamStartX,
            top: _cy - ColorVisionConstants.beamHeight / 2,
            width: ColorVisionConstants.singleBeamLength,
            height: ColorVisionConstants.beamHeight,
            child: CustomPaint(
              painter: PhotonCanvasPainter(photons: m.photonBeam.photons),
            ),
          ),

        // Head front (nose cutout over beams)
        Positioned(
          left: headLeft,
          top: headTop,
          width: headW,
          height: headH,
          child: Image.asset(
            headIsExterior ? CvAssets.headFront : CvAssets.silhouetteFront,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        ),

        // Filter left PNG + half-ellipse (above beams)
        if (m.filterVisible) ...[
          Positioned(
            left: filterLeft,
            top: filterTop,
            width: filterW,
            height: filterH,
            child: Image.asset(CvAssets.filterLeft, fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FilterHalfEllipsePainter(
                  center: Offset(filterCenterX + 1, _cy),
                  radiusX: radiusX,
                  radiusY: radiusY,
                  color: filterColor,
                  left: true,
                ),
              ),
            ),
          ),
        ],

        // Flashlight wire (colored mode)
        if (coloredLight)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FlashlightWirePainter(
                  start: Offset(flashlightRight - 15, (_cy + 3) + 2),
                  end: Offset(
                    (_layoutW - 70) - 25,
                    40 + 15 - 21,
                  ),
                  extend: 25,
                ),
              ),
            ),
          ),

        // Bulb Color slider
        if (coloredLight)
          Positioned(
            top: 40,
            right: 70,
            child: CvSpectrumSlider(
              wavelength: m.flashlightWavelength,
              onChanged: m.setFlashlightWavelength,
              label: '灯泡颜色',
            ),
          ),

        // White / Monochromatic radios
        Positioned(
          left: flashlightLeft,
          top: flashlightTop - 20 - 43 * 0.74 - 8,
          child: CvIconRadioGroup<LightType>(
            values: const [LightType.white, LightType.colored],
            assetPaths: const [
              CvAssets.whiteLightIcon,
              CvAssets.singleColorLightIcon,
            ],
            groupValue: m.lightType,
            onChanged: m.setLightType,
          ),
        ),

        // Beam / Photon radios
        Positioned(
          left: flashlightLeft,
          top: flashlightTop + flashlightH + 20,
          child: CvIconRadioGroup<BeamType>(
            values: const [BeamType.beam, BeamType.photon],
            assetPaths: const [
              CvAssets.beamViewIcon,
              CvAssets.photonViewIcon,
            ],
            groupValue: m.beamType,
            onChanged: m.setBeamType,
          ),
        ),

        // Flashlight + on/off
        Positioned(
          left: flashlightLeft,
          top: flashlightTop,
          width: flashlightW,
          height: flashlightH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(CvAssets.flashlight0Deg, fit: BoxFit.fill),
              Positioned(
                left: flashlightW / 2 + 15 - 15,
                top: flashlightH / 2 - 15,
                child: _FlashlightToggle(
                  key: const Key('color_vision_flashlight_toggle'),
                  on: m.flashlightOn,
                  onChanged: m.setFlashlightOn,
                ),
              ),
            ],
          ),
        ),

        // Filter wire + OnOffSwitch
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _FilterWirePainter(
                start: Offset(filterCenterX, filterTop + filterH),
                end: Offset(
                  (_layoutW - 70) - 200 + 16,
                  _layoutH - 20 - 15 - 21,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: filterCenterX - 17,
          top: filterTop + filterH + ( (_layoutH - 20 - 15 - 21) - (filterTop + filterH) ) / 3,
          child: _CvOnOffSwitch(
            key: const Key('color_vision_filter_switch'),
            value: m.filterVisible,
            onChanged: m.setFilterVisible,
          ),
        ),

        // Filter Color gaussian slider
        Positioned(
          bottom: 20,
          right: 70,
          child: CvGaussianSlider(
            wavelength: m.filterWavelength,
            onChanged: m.setFilterWavelength,
            label: '滤光片颜色',
          ),
        ),

        // Exterior / Interior radios
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

        // Time controls — bottom:484 centerX:381
        Positioned(
          left: 381 - 40,
          bottom: 20,
          child: CvTimeControls(
            isPlaying: m.playing,
            onPlayPause: () => m.setPlaying(!m.playing),
            onStep: m.manualStep,
          ),
        ),

        // Reset All — bottom:499 right:738 r=18
        Positioned(
          right: 30,
          bottom: 5,
          child: KratosResetAllButton(
            key: const Key('color_vision_reset_all'),
            radius: ColorVisionConstants.resetAllRadius,
            onPressed: () {
              m.reset();
              _applyFilterOffset();
            },
          ),
        ),
      ],
    );
  }

  double _filterWRadiusX(double filterW) => filterW / 2 - 13;
}

class _FlashlightToggle extends StatelessWidget {
  const _FlashlightToggle({
    super.key,
    required this.on,
    required this.onChanged,
  });

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on ? const Color(0xFFE53935) : const Color(0xFFB71C1C),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: on ? const Color(0xFFFF8A80) : const Color(0xFF4A0000),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _CvOnOffSwitch extends StatelessWidget {
  const _CvOnOffSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const h = 17.0;
    const w = 34.0;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h / 2),
          color: const Color(0xFFEEEEEE),
          border: Border.all(color: Colors.black),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: h - 2,
            height: h - 2,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.grey],
              ),
              border: Border.all(color: const Color(0xFF666666)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterHalfEllipsePainter extends CustomPainter {
  _FilterHalfEllipsePainter({
    required this.center,
    required this.radiusX,
    required this.radiusY,
    required this.color,
    required this.left,
  });

  final Offset center;
  final double radiusX;
  final double radiusY;
  final Color color;
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radiusY)
      ..arcTo(
        Rect.fromCenter(
          center: center,
          width: radiusX * 2,
          height: radiusY * 2,
        ),
        -math.pi / 2,
        left ? math.pi : -math.pi,
        false,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FilterHalfEllipsePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.left != left ||
      oldDelegate.center != center;
}

class _FlashlightWirePainter extends CustomPainter {
  _FlashlightWirePainter({
    required this.start,
    required this.end,
    required this.extend,
  });

  final Offset start;
  final Offset end;
  final double extend;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 5.0;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx + extend - radius, start.dy)
      ..arcToPoint(
        Offset(start.dx + extend, start.dy - radius),
        radius: const Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(start.dx + extend, end.dy + radius)
      ..arcToPoint(
        Offset(start.dx + extend - radius, end.dy),
        radius: const Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF999999),
    );
  }

  @override
  bool shouldRepaint(covariant _FlashlightWirePainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end;
}

class _FilterWirePainter extends CustomPainter {
  _FilterWirePainter({required this.start, required this.end});

  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    const holder = 10.0;
    const radius = 5.0;
    const switchWidth = 8.0;
    const switchHeight = 17.0;
    final switchDistance = (end.dy - start.dy) / 3;

    // Wire + U-holder (FilterWireNode.js)
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx + holder, start.dy)
      ..lineTo(start.dx + holder, start.dy - holder)
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx - holder, start.dy)
      ..lineTo(start.dx - holder, start.dy - holder)
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, end.dy - radius)
      ..arcToPoint(
        Offset(start.dx + radius, end.dy),
        radius: const Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFF999999),
    );

    // Switch outline (#666666, lineWidth 8) — PhET FilterWireNode
    final cy = start.dy + switchDistance + switchHeight / 2;
    final outline = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(start.dx + switchWidth, cy),
          radius: 10,
        ),
        -1.57079632679,
        3.14159265359,
      )
      ..addArc(
        Rect.fromCircle(
          center: Offset(start.dx - switchWidth, cy),
          radius: 10,
        ),
        1.57079632679,
        3.14159265359,
      );
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xFF666666),
    );
  }

  @override
  bool shouldRepaint(covariant _FilterWirePainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end;
}
