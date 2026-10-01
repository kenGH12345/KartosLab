import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../blackbody_spectrum_colors.dart';
import '../blackbody_spectrum_constants.dart';
import '../blackbody_spectrum_strings.dart';
import '../model/blackbody_spectrum_model.dart';
import '../render/blackbody_render_data.dart';

/// Main screen body for Blackbody Spectrum.
///
/// Uses a single CustomPaint canvas sized to PhET's logical viewport (1024×768)
/// with all components drawn in PhET logical coordinates.
/// This ensures exact visual alignment with the original simulation.
///
/// PhET layoutBounds = Bounds2(0, 0, 1024, 768)
/// [来源: BlackbodySpectrumScreenView.js:102-116]
class BlackbodySpectrumScreenBody extends StatefulWidget {
  const BlackbodySpectrumScreenBody({super.key, required this.model});

  final BlackbodySpectrumModel model;

  @override
  State<BlackbodySpectrumScreenBody> createState() =>
      _BlackbodySpectrumScreenBodyState();
}

enum _DragTarget { none, thermometer, graphPoint }

enum _ZoomHit { hIn, hOut, vIn, vOut }

class _BlackbodySpectrumScreenBodyState
    extends State<BlackbodySpectrumScreenBody> {
  double _graphPointWavelength = 0;
  bool _cueingArrowsVisible = true;
  _DragTarget _dragTarget = _DragTarget.none;
  double _lastTemperature = 0;

  @override
  void initState() {
    super.initState();
    _graphPointWavelength = widget.model.mainBody.peakWavelength;
    _lastTemperature = widget.model.temperature;
    widget.model.addListener(_onModelChanged);
  }

  @override
  void didUpdateWidget(BlackbodySpectrumScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      oldWidget.model.removeListener(_onModelChanged);
      widget.model.addListener(_onModelChanged);
      _lastTemperature = widget.model.temperature;
      _graphPointWavelength = widget.model.mainBody.peakWavelength;
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelChanged);
    super.dispose();
  }

  void _onModelChanged() {
    // PhET: temperature change snaps graph point to peak wavelength
    // [来源: GraphValuesPointNode.js:108-113]
    if (widget.model.temperature == _lastTemperature) return;
    _lastTemperature = widget.model.temperature;
    if (_dragTarget == _DragTarget.graphPoint) return;
    final peak = widget.model.mainBody.peakWavelength;
    if (_graphPointWavelength == peak) return;
    setState(() => _graphPointWavelength = peak);
  }

  // Hit regions mirror _BlackbodySpectrumPainter draw coords (1024x768).
  // [来源: GraphValuesPointNode.js:117-135, BlackbodySpectrumThermometer.js:91-108]

  void _handleTapDown(TapDownDetails details, double scale) {
    final phetX = details.localPosition.dx / scale;
    final phetY = details.localPosition.dy / scale;
    final m = widget.model;

    final zoom = _hitZoomButton(phetX, phetY);
    if (zoom != null) {
      switch (zoom) {
        case _ZoomHit.hIn:
          m.zoomHorizontalIn();
        case _ZoomHit.hOut:
          m.zoomHorizontalOut();
        case _ZoomHit.vIn:
          m.zoomVerticalIn();
        case _ZoomHit.vOut:
          m.zoomVerticalOut();
      }
      _hideCueing();
      return;
    }

    final checkbox = _hitCheckbox(phetX, phetY);
    if (checkbox != null) {
      switch (checkbox) {
        case 0:
          m.setGraphValuesVisible(!m.graphValuesVisible);
        case 1:
          m.setLabelsVisible(!m.labelsVisible);
        case 2:
          m.setIntensityVisible(!m.intensityVisible);
      }
      _hideCueing();
      return;
    }

    if (_hitSave(phetX, phetY)) {
      m.saveMainBody();
      _hideCueing();
      return;
    }
    if (_hitErase(phetX, phetY) && m.savedBodyOne.temperature != null) {
      m.clearSavedGraphs();
      _hideCueing();
      return;
    }
    if (_hitReset(phetX, phetY)) {
      m.reset();
      setState(() {
        _graphPointWavelength = m.mainBody.peakWavelength;
        _cueingArrowsVisible = true;
      });
      return;
    }

    _hideCueing();
  }

  void _handlePanStart(DragStartDetails details, double scale) {
    final phetX = details.localPosition.dx / scale;
    final phetY = details.localPosition.dy / scale;

    if (_hitThermometerThumb(phetX, phetY)) {
      _dragTarget = _DragTarget.thermometer;
      return;
    }
    if (widget.model.graphValuesVisible && _hitGraphPoint(phetX, phetY)) {
      _dragTarget = _DragTarget.graphPoint;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, double scale) {
    final local = details.localPosition;
    switch (_dragTarget) {
      case _DragTarget.thermometer:
        widget.model.temperature = _yPosToTemperature(local.dy / scale);
      case _DragTarget.graphPoint:
        setState(() {
          _graphPointWavelength = _viewXToWavelength(local.dx / scale);
        });
      case _DragTarget.none:
        break;
    }
  }

  void _handlePanEnd() {
    if (_dragTarget == _DragTarget.graphPoint) {
      _hideCueing();
    }
    _dragTarget = _DragTarget.none;
  }

  void _hideCueing() {
    if (!_cueingArrowsVisible) return;
    setState(() => _cueingArrowsVisible = false);
  }

  bool _hitThermometerThumb(double phetX, double phetY) {
    final thermCenterX = _BlackbodySpectrumPainter._thermometerRight - 35;
    const thermTop = 60.0;
    const tubeH = 400.0;
    final thumbY =
        thermTop + tubeH - _temperatureToYPos(widget.model.temperature);
    const thumbSize = 25.0;
    final thumbCx = thermCenterX + 20 / 2 + 2;
    final dx = phetX - thumbCx;
    final dy = phetY - thumbY;
    final hitRadius = thumbSize * 2 + 10;
    return dx * dx + dy * dy < hitRadius * hitRadius;
  }

  bool _hitGraphPoint(double phetX, double phetY) {
    final wl = _graphPointWavelength;
    final spd = widget.model.mainBody.getSpectralPowerDensityAt(wl);
    if (spd == 0) return false;
    final x = _BlackbodySpectrumPainter._graphLeft +
        (wl / widget.model.wavelengthMax) * _BlackbodySpectrumPainter._axesWidth;
    final y = _BlackbodySpectrumPainter._graphBottom +
        -1e33 *
            (spd / widget.model.verticalZoom) *
            _BlackbodySpectrumPainter._axesHeight;
    if (x < _BlackbodySpectrumPainter._graphLeft ||
        x >
            _BlackbodySpectrumPainter._graphLeft +
                _BlackbodySpectrumPainter._axesWidth ||
        y > _BlackbodySpectrumPainter._graphBottom ||
        y <
            _BlackbodySpectrumPainter._graphBottom -
                _BlackbodySpectrumPainter._axesHeight) {
      return false;
    }
    final dx = phetX - x;
    final dy = phetY - y;
    const hitR = 28.0;
    return dx * dx + dy * dy < hitR * hitR;
  }

  _ZoomHit? _hitZoomButton(double phetX, double phetY) {
    const r = _BlackbodySpectrumPainter._zoomButtonIconRadius;
    const spacing = _BlackbodySpectrumPainter._zoomButtonSpacing;
    const margin = _BlackbodySpectrumPainter._zoomButtonAxesMargin;
    final step = spacing + r * 2;

    final hCy = _BlackbodySpectrumPainter._graphBottom + margin;
    final hInCx = _BlackbodySpectrumPainter._graphLeft +
        _BlackbodySpectrumPainter._axesWidth -
        step;
    final hOutCx = _BlackbodySpectrumPainter._graphLeft +
        _BlackbodySpectrumPainter._axesWidth;

    final vCy = _BlackbodySpectrumPainter._graphBottom -
        _BlackbodySpectrumPainter._axesHeight -
        margin;
    final vInCx = _BlackbodySpectrumPainter._graphLeft;
    final vOutCx = _BlackbodySpectrumPainter._graphLeft + step;

    bool near(double cx, double cy) {
      final rect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: r * 2 + 12,
        height: r * 2 + 12,
      );
      return rect.contains(Offset(phetX, phetY));
    }

    if (near(hInCx, hCy)) return _ZoomHit.hIn;
    if (near(hOutCx, hCy)) return _ZoomHit.hOut;
    if (near(vInCx, vCy)) return _ZoomHit.vIn;
    if (near(vOutCx, vCy)) return _ZoomHit.vOut;
    return null;
  }

  int? _hitCheckbox(double phetX, double phetY) {
    final panel = _controlPanelGeom();
    var y = panel.top + 15;
    for (var i = 0; i < 3; i++) {
      final hit = Rect.fromLTWH(panel.left + 8, y - 12, panel.width - 16, 24);
      if (hit.contains(Offset(phetX, phetY))) return i;
      y += i == 2 ? 35 : 30;
    }
    return null;
  }

  bool _hitSave(double phetX, double phetY) {
    return _buttonRowGeom().save.contains(Offset(phetX, phetY));
  }

  bool _hitErase(double phetX, double phetY) {
    return _buttonRowGeom().erase.contains(Offset(phetX, phetY));
  }

  bool _hitReset(double phetX, double phetY) {
    const left = 1024.0 - 10 - 100;
    const top = 768.0 - 10 - 40;
    return Rect.fromLTWH(left, top, 100, 40).contains(Offset(phetX, phetY));
  }

  ({double left, double top, double width, double height}) _controlPanelGeom() {
    // Clear thermometer tick labels (e.g. "Sirius A") — panel right stays left of them.
    final thermCenterX = _BlackbodySpectrumPainter._thermometerRight - 35;
    final labelRight = thermCenterX -
        _BlackbodySpectrumPainter._tubeWidth / 2 -
        2 -
        10 -
        5;
    const labelMaxWidth = 100.0;
    final panelRight = labelRight - labelMaxWidth - 20;
    const panelWidth = 160.0;
    const panelTop = 50.0;
    var contentBottom = panelTop + 15;
    contentBottom += 30 + 30 + 35; // checkboxes
    if (widget.model.intensityVisible) contentBottom += 40;
    contentBottom += 5 + 20; // separator gap
    contentBottom += 35; // buttons
    contentBottom += 15; // bottom padding
    return (
      left: panelRight - panelWidth,
      top: panelTop,
      width: panelWidth,
      height: contentBottom - panelTop,
    );
  }

  ({Rect save, Rect erase}) _buttonRowGeom() {
    final panel = _controlPanelGeom();
    var y = panel.top + 15;
    y += 30 + 30 + 35;
    if (widget.model.intensityVisible) y += 40;
    y += 5 + 20;
    return (
      save: Rect.fromLTWH(panel.left + 15, y, 50, 35),
      erase: Rect.fromLTWH(panel.left + 75, y, 50, 35),
    );
  }

  double _yPosToTemperature(double phetY) {
    const thermTop = 60.0;
    const tubeHeight = 400.0;
    final yFromBottom = (thermTop + tubeHeight) - phetY;
    final ratio = (yFromBottom / tubeHeight).clamp(0.0, 1.0);
    final temp = BlackbodySpectrumConstants.minTemperature +
        ratio *
            (BlackbodySpectrumConstants.maxTemperature -
                BlackbodySpectrumConstants.minTemperature);
    return (temp / 50).round() * 50.0;
  }

  double _temperatureToYPos(double temp) {
    return ((temp - BlackbodySpectrumConstants.minTemperature) /
            (BlackbodySpectrumConstants.maxTemperature -
                BlackbodySpectrumConstants.minTemperature)) *
        400.0;
  }

  double _viewXToWavelength(double phetX) {
    final rel = phetX - _BlackbodySpectrumPainter._graphLeft;
    final wl = (rel / _BlackbodySpectrumPainter._axesWidth) *
        widget.model.wavelengthMax;
    return wl.clamp(0.0, widget.model.wavelengthMax);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, _) {
        final render = BlackbodyRenderData(
          mainBody: widget.model.mainBody,
          savedBodyOne: widget.model.savedBodyOne,
          savedBodyTwo: widget.model.savedBodyTwo,
          graphValuesVisible: widget.model.graphValuesVisible,
          intensityVisible: widget.model.intensityVisible,
          labelsVisible: widget.model.labelsVisible,
          wavelengthMax: widget.model.wavelengthMax,
          verticalZoom: widget.model.verticalZoom,
          graphPointWavelength: _graphPointWavelength,
          cueingArrowsVisible: _cueingArrowsVisible,
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(
              constraints.maxWidth / 1024,
              constraints.maxHeight / 768,
            );
            return Center(
              child: SizedBox(
                width: 1024 * scale,
                height: 768 * scale,
                child: GestureDetector(
                  onTapDown: (details) => _handleTapDown(details, scale),
                  onPanStart: (details) => _handlePanStart(details, scale),
                  onPanUpdate: (details) => _handlePanUpdate(details, scale),
                  onPanEnd: (_) => _handlePanEnd(),
                  onPanCancel: _handlePanEnd,
                  child: CustomPaint(
                    painter: _BlackbodySpectrumPainter(
                      render: render,
                      model: widget.model,
                      scale: scale,
                    ),
                    size: Size(1024 * scale, 768 * scale),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Single painter that draws the entire simulation in PhET logical coordinates.
/// All positions are in PhET's 1024×768 coordinate space.
class _BlackbodySpectrumPainter extends CustomPainter {
  _BlackbodySpectrumPainter({
    required this.render,
    required this.model,
    required this.scale,
  });

  final BlackbodyRenderData render;
  final BlackbodySpectrumModel model;
  final double scale;

  // PhET logical constants
  static const double _phetWidth = 1024;
  static const double _phetHeight = 768;
  static const double _inset = 10;
  static const double _temperatureLabelSpacing = 5;

  // Graph constants — axes right edge aligns under control-panel left
  // (平行右移：保持 PhET axesWidth=550，整体右移)
  // [来源: ZoomableAxesView.options.axesWidth = 550]
  static const double _axesWidth = 550;
  static const double _axesHeight = 400;
  /// controlPanelLeft ≈ 672; graphRight = graphLeft + axesWidth
  static const double _graphLeft = 122; // 672 - 550
  static const double _graphBottom = _phetHeight - _inset - 80; // 678

  // Thermometer constants from PhET
  static const double _thermometerRight = _phetWidth - _inset; // 1014
  static const double _bulbDiameter = 35;
  static const double _tubeWidth = 20;
  static const double _tubeHeight = 400;
  static const double _glassThickness = 5;
  static const double _thermometerLineWidth = 3;
  static const double _thumbSize = 25;

  // Zoom button constants from PhET
  static const double _zoomButtonIconRadius = 8;
  static const double _zoomButtonSpacing = 10;
  static const double _zoomButtonAxesMargin = 35;

  // BGR constants from PhET
  static const double _circleRadius = 15;
  static const double _starInnerRadius = 20;
  static const double _starOuterRadius = 35;
  static const double _starSpacing = 50;
  static const double _bgrLeft = 225;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale, scale);

    // Draw background
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _phetWidth, _phetHeight),
      Paint()..color = BlackbodySpectrumColors.background,
    );

    // 1. Graph (under axes)
    _drawGraphUnderAxes(canvas);

    // 2. Axes
    _drawAxes(canvas);

    // 3. Zoom buttons
    _drawZoomButtons(canvas);

    // 4. Graph curves (over axes)
    _drawGraphCurves(canvas);

    // 5. Graph values point
    if (model.graphValuesVisible) {
      _drawGraphValuesPoint(canvas);
    }

    // 6. Thermometer
    _drawThermometer(canvas);

    // 7. Temperature labels
    _drawTemperatureLabels(canvas);

    // 8. BGR + Star
    _drawBgrAndStar(canvas);

    // 9. Control panel
    _drawControlPanel(canvas);

    // 10. Reset button
    _drawResetButton(canvas);

    canvas.restore();
  }

  // ===== GRAPH UNDER AXES =====
  void _drawGraphUnderAxes(Canvas canvas) {
    // Visible light spectrum band
    // [来源: GraphDrawingNode.js:103-112]
    final uvX = _wavelengthToViewX(BlackbodySpectrumConstants.ultravioletWavelength);
    final visX = _wavelengthToViewX(BlackbodySpectrumConstants.visibleWavelength);
    final spectrumWidth = visX - uvX;

    if (spectrumWidth > 0) {
      final rect = Rect.fromLTWH(
        _graphLeft + uvX,
        _graphBottom - _axesHeight,
        spectrumWidth,
        _axesHeight,
      );
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Color(0xFF8B00FF),
          Color(0xFF0000FF),
          Color(0xFF00FFFF),
          Color(0xFF00FF00),
          Color(0xFFFFFF00),
          Color(0xFFFF7F00),
          Color(0xFFFF0000),
        ],
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.fill,
      );
    }

    // Intensity fill area
    // [来源: GraphDrawingNode.js:237-242]
    if (model.intensityVisible) {
      final points = render.sampleCurvePoints(model.mainBody);
      if (points.length >= 2) {
        final path = Path();
        path.moveTo(_graphLeft + points.first.dx, _graphBottom + points.first.dy);
        for (final p in points) {
          path.lineTo(_graphLeft + p.dx, _graphBottom + p.dy);
        }
        path.lineTo(_graphLeft + points.last.dx, _graphBottom);
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color.fromRGBO(100, 100, 100, 0.75)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  // ===== AXES =====
  void _drawAxes(Canvas canvas) {
    // L-shaped axes with end hooks
    // [来源: ZoomableAxesView.js:120-128]
    final path = Path()
      ..moveTo(_graphLeft + _axesWidth, _graphBottom - 5)
      ..lineTo(_graphLeft + _axesWidth, _graphBottom)
      ..lineTo(_graphLeft, _graphBottom)
      ..lineTo(_graphLeft, _graphBottom - _axesHeight)
      ..lineTo(_graphLeft - 5, _graphBottom - _axesHeight);

    canvas.drawPath(
      path,
      Paint()
        ..color = BlackbodySpectrumColors.graphAxesStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Horizontal ticks
    // [来源: ZoomableAxesView.js:270-285]
    final wpt = BlackbodySpectrumConstants.wavelengthPerTick;
    final minorPerMajor = BlackbodySpectrumConstants.minorTicksPerMajorTick;
    final minorLen = BlackbodySpectrumConstants.minorTickLength;
    final majorLen = BlackbodySpectrumConstants.majorTickLength;
    final maxWl = model.wavelengthMax;

    final tickPaint = Paint()
      ..color = BlackbodySpectrumColors.graphAxesStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final minorTickZero = (maxWl > BlackbodySpectrumConstants.minorTickMaxHorizontalZoom) ? 0.0 : minorLen;

    final count = (maxWl / wpt).floor();
    for (var i = 0; i < count; i++) {
      final tickHeight = (i % minorPerMajor == 0) ? majorLen : minorTickZero;
      if (tickHeight == 0) continue;
      final x = _graphLeft + _wavelengthToViewX(i * wpt);
      canvas.drawLine(
        Offset(x, _graphBottom),
        Offset(x, _graphBottom - tickHeight),
        tickPaint,
      );
    }

    // EM spectrum labels
    if (model.labelsVisible) {
      _drawEmSpectrumLabels(canvas);
    }

    // Axis labels
    _drawAxisLabels(canvas);

    // Axis bound numbers
    _drawAxisBoundsNumbers(canvas);
  }

  void _drawEmSpectrumLabels(Canvas canvas) {
    // [来源: ZoomableAxesView.js:138-149, 291-325]
    final regions = [
      (BlackbodySpectrumStrings.xRay, BlackbodySpectrumConstants.xRayWavelength),
      (BlackbodySpectrumStrings.ultraviolet, BlackbodySpectrumConstants.ultravioletWavelength),
      (BlackbodySpectrumStrings.visible, BlackbodySpectrumConstants.visibleWavelength),
      (BlackbodySpectrumStrings.infrared, BlackbodySpectrumConstants.infraredWavelength),
    ];

    // Top axis line
    final axisY = _graphBottom - _axesHeight;
    canvas.drawLine(
      Offset(_graphLeft, axisY),
      Offset(_graphLeft + _axesWidth, axisY),
      Paint()
        ..color = BlackbodySpectrumColors.graphAxesStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final visibleRegions = regions.where((r) => r.$2 <= model.wavelengthMax).toList();
    final tickPositions = visibleRegions.map((r) => _graphLeft + _wavelengthToViewX(r.$2)).toList();

    // Ticks
    for (final x in tickPositions) {
      final bottomY = axisY + BlackbodySpectrumConstants.minorTickLength / 2;
      canvas.drawLine(
        Offset(x, bottomY),
        Offset(x, bottomY - BlackbodySpectrumConstants.minorTickLength),
        Paint()
          ..color = BlackbodySpectrumColors.graphAxesStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Labels between successive bounds; name from full region list so the
    // last open interval (e.g. after Visible tick) still reads Infrared.
    final labelBounds = [_graphLeft, ...tickPositions, _graphLeft + _axesWidth];
    for (var i = 0; i < labelBounds.length - 1 && i < regions.length; i++) {
      final lower = labelBounds[i];
      final upper = labelBounds[i + 1];
      if (upper - lower < 20) continue;
      final label = regions[i].$1;
      _drawText(canvas, label, (upper + lower) / 2, axisY - 15,
          BlackbodySpectrumColors.titlesText, 14, upper - lower);
    }
  }

  void _drawAxisLabels(Canvas canvas) {
    // [来源: ZoomableAxesView.js:159-180]
    // Wavelength label
    _drawText(canvas, BlackbodySpectrumStrings.wavelengthLabel,
        _graphLeft + _axesWidth / 2, _graphBottom + 45,
        BlackbodySpectrumColors.titlesText, 18, _axesWidth * 0.8);

    // Subtitle
    _drawText(canvas, BlackbodySpectrumStrings.subtitleLabel,
        _graphLeft + _axesWidth / 2, _graphBottom + 70,
        BlackbodySpectrumColors.titlesText, 16, _axesWidth * 0.8);

    // SPD label (rotated)
    canvas.save();
    canvas.translate(_graphLeft - 90, _graphBottom - _axesHeight / 2);
    canvas.rotate(-math.pi / 2);
    _drawText(canvas, BlackbodySpectrumStrings.spectralPowerDensityLabel,
        0, 0, BlackbodySpectrumColors.titlesText, 18, _axesHeight);
    canvas.restore();
  }

  void _drawAxisBoundsNumbers(Canvas canvas) {
    // 0 label
    _drawText(canvas, '0', _graphLeft - 8, _graphBottom + 8,
        BlackbodySpectrumColors.titlesText, 14, 30, align: TextAlign.right);

    // Max wavelength (nm → µm)
    final maxWlText = (model.wavelengthMax / 1000).toStringAsFixed(0);
    _drawText(canvas, maxWlText, _graphLeft + _axesWidth + 8, _graphBottom + 8,
        BlackbodySpectrumColors.titlesText, 14, 50);

    // Max SPD label
    final vZoom = model.verticalZoom;
    String maxSpdText;
    if (vZoom < 0.01) {
      maxSpdText = _formatVerticalLabel(vZoom);
    } else {
      maxSpdText = vZoom.toStringAsFixed(2);
    }
    _drawText(canvas, maxSpdText, _graphLeft - 8, _graphBottom - _axesHeight,
        BlackbodySpectrumColors.titlesText, 14, 60, align: TextAlign.right);
  }

  // ===== GRAPH CURVES =====
  void _drawGraphCurves(Canvas canvas) {
    // Clip to graph area
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
      _graphLeft, _graphBottom - _axesHeight + 1, _graphLeft + _axesWidth, _graphBottom));

    // Saved curve 2 (dashed gray)
    if (model.savedBodyTwo.temperature != null) {
      _drawCurve(canvas, render.sampleCurvePoints(model.savedBodyTwo),
          Colors.grey, 3, true);
    }

    // Saved curve 1 (solid gray)
    if (model.savedBodyOne.temperature != null) {
      _drawCurve(canvas, render.sampleCurvePoints(model.savedBodyOne),
          Colors.grey, 3, false);
    }

    // Main curve (red colorblind)
    _drawCurve(canvas, render.sampleCurvePoints(model.mainBody),
        BlackbodySpectrumColors.mainCurve, 3, false);

    canvas.restore();
  }

  void _drawCurve(Canvas canvas, List<Offset> points, Color color,
      double strokeWidth, bool dashed) {
    if (points.length < 2) return;
    final path = Path();
    path.moveTo(_graphLeft + points.first.dx, _graphBottom + points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(_graphLeft + points[i].dx, _graphBottom + points[i].dy);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    if (dashed) {
      _drawDashedPath(canvas, path, paint, 5, 5);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  // ===== GRAPH VALUES POINT =====
  void _drawGraphValuesPoint(Canvas canvas) {
    // [来源: GraphValuesPointNode.js:168-260]
    final wl = render.graphPointWavelength;
    final spd = model.mainBody.getSpectralPowerDensityAt(wl);
    if (spd == 0) return;

    final x = _graphLeft + _wavelengthToViewX(wl);
    final y = _graphBottom + _spectralPowerDensityToViewY(spd);

    if (x < _graphLeft || x > _graphLeft + _axesWidth ||
        y > _graphBottom || y < _graphBottom - _axesHeight) {
      return;
    }

    // Dashed crosshairs
    final dashPaint = Paint()
      ..color = BlackbodySpectrumColors.graphValuesDashedLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawDashedLine(canvas, Offset(x, _graphBottom), Offset(x, y), dashPaint, 4, 4);
    _drawDashedLine(canvas, Offset(_graphLeft, y), Offset(x, y), dashPaint, 4, 4);

    // Point circle
    canvas.drawCircle(Offset(x, y), 5,
        Paint()..color = BlackbodySpectrumColors.graphValuesPoint);
    canvas.drawCircle(Offset(x, y), 5,
        Paint()
          ..color = BlackbodySpectrumColors.graphValuesPoint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // Wavelength label
    final wlText = (wl / 1000).toStringAsFixed(3);
    _drawText(canvas, wlText, x, _graphBottom + 18,
        BlackbodySpectrumColors.graphValuesLabels, 18, 50);

    // SPD label
    final spdValue = spd * 1e33;
    String spdText;
    if (spdValue < 0.01 && spdValue != 0) {
      spdText = _formatScientific(spdValue);
    } else {
      spdText = spdValue.toStringAsPrecision(4);
    }
    _drawText(canvas, spdText, x + 10, y - 8,
        BlackbodySpectrumColors.graphValuesLabels, 18, 80);

    // Cueing arrows (ew-resize hint) [来源: GraphValuesPointNode.js:87-96]
    if (render.cueingArrowsVisible) {
      _drawCueingArrows(canvas, Offset(x, y));
    }
  }

  void _drawCueingArrows(Canvas canvas, Offset center) {
    // [来源: GraphValuesPointNode.js:87-96] arrowSpacing=30, arrowLength=20, fill=#64dc64
    const halfSpacing = 15.0;
    const length = 20.0;
    final paint = Paint()..color = const Color(0xFF64DC64);

    void arrow({required bool pointingRight}) {
      final baseX =
          pointingRight ? center.dx + halfSpacing : center.dx - halfSpacing;
      final tipX = pointingRight ? baseX + length : baseX - length;
      final shaftEnd = pointingRight ? tipX - 10 : tipX + 10;
      canvas.drawRect(
        Rect.fromLTRB(
          math.min(baseX, shaftEnd),
          center.dy - 3,
          math.max(baseX, shaftEnd),
          center.dy + 3,
        ),
        paint,
      );
      final tip = Path()
        ..moveTo(tipX, center.dy)
        ..lineTo(pointingRight ? tipX - 12 : tipX + 12, center.dy - 7)
        ..lineTo(pointingRight ? tipX - 12 : tipX + 12, center.dy + 7)
        ..close();
      canvas.drawPath(tip, paint);
    }

    arrow(pointingRight: true);
    arrow(pointingRight: false);
  }

  // ===== ZOOM BUTTONS =====
  void _drawZoomButtons(Canvas canvas) {
    // Both groups laid out horizontally (user QA + scenery-phet default row).
    // [来源: GraphDrawingNode.js:175-178]
    final r = _zoomButtonIconRadius.toDouble();
    final step = _zoomButtonSpacing + r * 2;

    // Horizontal zoom: below x-axis, near right end, + then - left-to-right
    final hCy = _graphBottom + _zoomButtonAxesMargin;
    final hInCx = _graphLeft + _axesWidth - step;
    final hOutCx = _graphLeft + _axesWidth;
    _drawZoomButton(canvas, hInCx, hCy, true, true);
    _drawZoomButton(canvas, hOutCx, hCy, false, true);

    // Vertical zoom: above y-axis top-left, + then - left-to-right
    final vCy = _graphBottom - _axesHeight - _zoomButtonAxesMargin;
    final vInCx = _graphLeft;
    final vOutCx = _graphLeft + step;
    _drawZoomButton(canvas, vInCx, vCy, true, false);
    _drawZoomButton(canvas, vOutCx, vCy, false, false);
  }

  void _drawZoomButton(Canvas canvas, double cx, double cy, bool isIn, bool isHorizontal) {
    final r = _zoomButtonIconRadius.toDouble();
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: r * 2 + 4, height: r * 2 + 4);

    // Button background (light blue)
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(3)),
      Paint()..color = const Color(0xFFADD8E6),
    );

    // Magnifying glass circle
    canvas.drawCircle(
      Offset(cx - 2, cy - 2),
      r - 2,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Handle
    final handleAngle = isHorizontal ? math.pi / 4 : -math.pi / 4;
    canvas.drawLine(
      Offset(cx + (r - 3) * math.cos(handleAngle), cy + (r - 3) * math.sin(handleAngle)),
      Offset(cx + (r + 2) * math.cos(handleAngle), cy + (r + 2) * math.sin(handleAngle)),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );

    // Plus/minus sign
    final signPaint = Paint()..color = Colors.black..strokeWidth = 2;
    if (isHorizontal) {
      // Horizontal: + / -
      canvas.drawLine(Offset(cx - 4, cy), Offset(cx + 4, cy), signPaint);
      if (isIn) {
        canvas.drawLine(Offset(cx, cy - 4), Offset(cx, cy + 4), signPaint);
      }
    } else {
      // Vertical: + / -
      canvas.drawLine(Offset(cx - 4, cy), Offset(cx + 4, cy), signPaint);
      if (isIn) {
        canvas.drawLine(Offset(cx, cy - 4), Offset(cx, cy + 4), signPaint);
      }
    }
  }

  // ===== THERMOMETER =====
  void _drawThermometer(Canvas canvas) {
    // [来源: BlackbodySpectrumThermometer.js:49-118]
    // PhET: thermometerNode is a standalone node positioned in ScreenView.
    // Its tube is in local coords: y ∈ [-tubeHeight, 0], bulb below.
    // ScreenView positions it: thermometerNode.top = temperatureText.bottom + 5
    final T = model.temperature;
    final tubeW = _tubeWidth;
    final tubeH = _tubeHeight;
    final bulbD = _bulbDiameter;
    final glassT = _glassThickness;

    // Thermometer right edge at _thermometerRight
    // Tube center X: thermometerCenterXFromRight = -thumbSize - tubeWidth/2 = -35
    final thermCenterX = _thermometerRight - 35;

    // Thermometer top position: below temperature labels
    // PhET: thermometerNode.top = temperatureText.bottom + TEMPERATURE_LABEL_SPACING
    // temperatureText.top = thermometerText.bottom + 5 ≈ 33
    // temperatureText.bottom ≈ 33 + 22 = 55
    // thermometerNode.top = 55 + 5 = 60
    final thermTop = 60.0; // Absolute Y position of thermometer tube top
    final tubeBottom = thermTop + tubeH;
    final bulbCy = tubeBottom + bulbD / 2;

    // Tube background (black fill)
    final tubeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(thermCenterX, thermTop + tubeH / 2),
          width: tubeW, height: tubeH),
      Radius.circular(tubeW / 2),
    );
    canvas.drawRRect(tubeRect, Paint()..color = BlackbodySpectrumColors.thermometerTrack);

    // Inner red fill
    // PhET: higher temp = more fluid = fills from bottom up
    // ratio = (T - min) / (max - min), fillHeight = ratio * tubeH
    // fillTop = tubeBottom - fillHeight
    final ratio = (T - BlackbodySpectrumConstants.minTemperature) /
        (BlackbodySpectrumConstants.maxTemperature - BlackbodySpectrumConstants.minTemperature);
    final fillHeight = tubeH * ratio;
    final fillTop = tubeBottom - fillHeight;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(thermCenterX - tubeW / 2 + glassT, fillTop,
          thermCenterX + tubeW / 2 - glassT, tubeBottom),
      Radius.circular((tubeW - 2 * glassT) / 2),
    );
    canvas.drawRRect(innerRect, Paint()..color = const Color.fromRGBO(220, 50, 50, 1));

    // Bulb
    canvas.drawCircle(Offset(thermCenterX, bulbCy), bulbD / 2 - glassT,
        Paint()..color = const Color.fromRGBO(220, 50, 50, 1));

    // Tube outline
    canvas.drawRRect(tubeRect, Paint()
      ..color = BlackbodySpectrumColors.thermometerTubeStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thermometerLineWidth);

    // Bulb outline
    canvas.drawCircle(Offset(thermCenterX, bulbCy), bulbD / 2, Paint()
      ..color = BlackbodySpectrumColors.thermometerTubeStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thermometerLineWidth);

    // Tick marks
    final tickMarks = [
      (BlackbodySpectrumConstants.siriusATemperature, BlackbodySpectrumStrings.siriusA, 10.0),
      (BlackbodySpectrumConstants.sunTemperature, BlackbodySpectrumStrings.sun, 10.0),
      (BlackbodySpectrumConstants.lightBulbTemperature, BlackbodySpectrumStrings.lightBulb, 10.0),
      (BlackbodySpectrumConstants.earthTemperature, BlackbodySpectrumStrings.earth, 10.0),
    ];

    final tickPaint = Paint()
      ..color = BlackbodySpectrumColors.thermometerTubeStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final (temp, label, tickLen) in tickMarks) {
      // PhET: y = thermTop + tubeH - temperatureToYPos(temp)
      // Higher temp = higher up (smaller Y)
      final y = thermTop + tubeH - _temperatureToYPos(temp);
      canvas.drawLine(
        Offset(thermCenterX - tubeW / 2 - 2, y),
        Offset(thermCenterX - tubeW / 2 - 2 - tickLen, y),
        tickPaint,
      );
      _drawText(canvas, label, thermCenterX - tubeW / 2 - 2 - tickLen - 5, y,
          BlackbodySpectrumColors.titlesText, 18, 100, align: TextAlign.right);
    }

    // Minor ticks every 500K
    for (double t = BlackbodySpectrumConstants.minTemperature;
        t <= BlackbodySpectrumConstants.maxTemperature;
        t += BlackbodySpectrumConstants.tickSpacingTemperature) {
      final isMajor = tickMarks.any((e) => (e.$1 - t).abs() < 1);
      if (isMajor) continue;
      final y = thermTop + tubeH - _temperatureToYPos(t);
      canvas.drawLine(
        Offset(thermCenterX - tubeW / 2 - 2, y),
        Offset(thermCenterX - tubeW / 2 - 2 - 5, y),
        tickPaint,
      );
    }

    // Triangle thumb
    // [来源: TriangleSliderThumb.js:28-71]
    final thumbY = thermTop + tubeH - _temperatureToYPos(T);
    final thumbSize = _thumbSize.toDouble();
    final thumbColor = BlackbodySpectrumColors.triangleFill;

    canvas.save();
    canvas.translate(thermCenterX + tubeW / 2 + 2, thumbY);
    canvas.rotate(-math.pi / 2);

    final thumbPath = Path()
      ..moveTo(-thumbSize / 2, -thumbSize / 2)
      ..lineTo(thumbSize / 2, 0)
      ..lineTo(-thumbSize / 2, thumbSize / 2)
      ..close();

    canvas.drawPath(thumbPath, Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill);
    canvas.drawPath(thumbPath, Paint()
      ..color = BlackbodySpectrumColors.triangleStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    canvas.restore();
  }

  double _temperatureToYPos(double temp) {
    return ((temp - BlackbodySpectrumConstants.minTemperature) /
            (BlackbodySpectrumConstants.maxTemperature - BlackbodySpectrumConstants.minTemperature)) *
        _tubeHeight;
  }

  // ===== TEMPERATURE LABELS =====
  void _drawTemperatureLabels(Canvas canvas) {
    // [来源: BlackbodySpectrumScreenView.js:53-110]
    final thermCenterX = _thermometerRight - 35;

    // "Blackbody Temperature" label
    _drawText(canvas, BlackbodySpectrumStrings.blackbodyTemperature,
        thermCenterX, _inset + _temperatureLabelSpacing,
        BlackbodySpectrumColors.titlesText, 18, 180);

    // Temperature value
    final tempY = _inset + _temperatureLabelSpacing + 25;
    _drawText(canvas, '${model.temperature.round()} ${BlackbodySpectrumStrings.kelvinUnits}',
        thermCenterX, tempY,
        BlackbodySpectrumColors.temperatureText, 22, 130);
  }

  // ===== BGR + STAR =====
  void _drawBgrAndStar(Canvas canvas) {
    // [来源: BGRAndStarDisplay.js:35-89]
    // PhET: circleBlue.centerY = STAR_SPACING (= 50)
    // This is an ABSOLUTE coordinate, NOT relative to graph.
    final body = model.mainBody;
    final r = _circleRadius.toDouble();
    final spacing = _starSpacing.toDouble();

    final blueCx = _bgrLeft + r;
    final circleCy = spacing; // = 50, absolute Y
    final greenCx = blueCx + spacing;
    final redCx = greenCx + spacing;
    final starCx = redCx + r + spacing + _starOuterRadius;

    // Halo
    final haloR = body.glowingStarHaloRadius;
    if (haloR > 0) {
      final haloRect = Rect.fromCircle(center: Offset(starCx, circleCy), radius: haloR);
      canvas.drawCircle(Offset(starCx, circleCy), haloR,
          Paint()
            ..shader = RadialGradient(colors: [
              body.glowingStarHaloColor,
              body.glowingStarHaloColor.withValues(alpha: 0),
            ]).createShader(haloRect));
    }

    // RGB circles
    canvas.drawCircle(Offset(blueCx, circleCy), r, Paint()..color = body.blueColor);
    canvas.drawCircle(Offset(greenCx, circleCy), r, Paint()..color = body.greenColor);
    canvas.drawCircle(Offset(redCx, circleCy), r, Paint()..color = body.redColor);

    // Labels
    final labelY = circleCy - r + spacing;
    _drawText(canvas, BlackbodySpectrumStrings.labelB, blueCx, labelY,
        BlackbodySpectrumColors.titlesText, 18, 36);
    _drawText(canvas, BlackbodySpectrumStrings.labelG, greenCx, labelY,
        BlackbodySpectrumColors.titlesText, 18, 36);
    _drawText(canvas, BlackbodySpectrumStrings.labelR, redCx, labelY,
        BlackbodySpectrumColors.titlesText, 18, 36);

    // Star (9-point)
    final starPath = _starPath(Offset(starCx, circleCy), _starOuterRadius, _starInnerRadius, 5);
    canvas.drawPath(starPath, Paint()..color = body.starColor);
    canvas.drawPath(starPath, Paint()
      ..color = BlackbodySpectrumColors.starStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  Path _starPath(Offset center, double outer, double inner, int points) {
    final path = Path();
    final angleStep = math.pi / points;
    for (var i = 0; i < points * 2; i++) {
      final radius = (i % 2 == 0) ? outer : inner;
      final angle = -math.pi / 2 + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // ===== CONTROL PANEL =====
  void _drawControlPanel(Canvas canvas) {
    // [来源: BlackbodySpectrumScreenView.js:112-115]
    // controlPanel.right clears thermometer labels; savedGraphs below panel + 55.
    final thermCenterX = _thermometerRight - 35;
    final labelRight = thermCenterX - _tubeWidth / 2 - 2 - 10 - 5;
    const labelMaxWidth = 100.0;
    final panelRight = labelRight - labelMaxWidth - 20;
    const panelWidth = 160.0;
    final panelLeft = panelRight - panelWidth;
    const panelTop = 50.0;

    var y = panelTop + 15;

    // Checkboxes
    _drawCheckbox(canvas, panelLeft + 10, y, model.graphValuesVisible, BlackbodySpectrumStrings.graphValues);
    y += 30;
    _drawCheckbox(canvas, panelLeft + 10, y, model.labelsVisible, BlackbodySpectrumStrings.labels);
    y += 30;
    _drawCheckbox(canvas, panelLeft + 10, y, model.intensityVisible, BlackbodySpectrumStrings.intensity);
    y += 35;

    // Intensity display
    if (model.intensityVisible) {
      final intensityText = render.intensityText;
      final textWidth = intensityText.length * 8.0 + 20;
      final boxWidth = math.max(140.0, textWidth);
      final boxRect = Rect.fromLTWH(panelLeft + (panelWidth - boxWidth) / 2, y, boxWidth, 30.0);
      canvas.drawRect(boxRect, Paint()..color = Colors.grey);
      canvas.drawRect(boxRect, Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
      _drawText(canvas, intensityText, boxRect.center.dx, boxRect.center.dy,
          Colors.white, 18, boxWidth);
      y += 40;
    }

    // Separator
    y += 5;
    canvas.drawLine(
      Offset(panelLeft + 10, y),
      Offset(panelRight - 10, y),
      Paint()..color = const Color(0xFFD4D4D4)..strokeWidth = 1,
    );
    y += 20;

    // Buttons (Save + Erase)
    final buttonY = y;
    final saveRect = Rect.fromLTWH(panelLeft + 15, buttonY, 50, 35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(saveRect, Radius.circular(4)),
      Paint()..color = const Color(0xFFFFFF00),
    );
    _drawCameraIcon(canvas, saveRect.center);

    final eraseRect = Rect.fromLTWH(panelLeft + 75, buttonY, 50, 35);
    final eraseEnabled = model.savedBodyOne.temperature != null;
    canvas.drawRRect(
      RRect.fromRectAndRadius(eraseRect, Radius.circular(4)),
      Paint()..color = eraseEnabled ? const Color(0xFFADD8E6) : Colors.grey,
    );
    _drawEraserIcon(canvas, eraseRect.center);

    // Panel border wraps checkboxes + buttons only (not saved graphs).
    final panelBottom = buttonY + 35 + 15;
    final panelRect = Rect.fromLTRB(panelLeft, panelTop, panelRight, panelBottom);
    canvas.drawRect(panelRect, Paint()
      ..color = BlackbodySpectrumColors.panelStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);

    // Saved graphs sit below the control panel [来源: ScreenView.js:114-115]
    if (model.savedBodyOne.temperature != null) {
      _drawSavedGraphPanel(canvas, panelLeft, panelBottom + 55, panelWidth);
    }
  }

  void _drawCheckbox(Canvas canvas, double x, double y, bool value, String label) {
    // Checkbox square
    final rect = Rect.fromLTWH(x, y - 8, 16, 16);
    canvas.drawRect(rect, Paint()..color = Colors.transparent);
    canvas.drawRect(rect, Paint()
      ..color = BlackbodySpectrumColors.panelStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    if (value) {
      // Check mark
      final checkPath = Path()
        ..moveTo(x + 3, y)
        ..lineTo(x + 7, y + 5)
        ..lineTo(x + 13, y - 3);
      canvas.drawPath(checkPath, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }
    // Label
    _drawText(canvas, label, x + 22, y,
        BlackbodySpectrumColors.panelText, 18, 110, align: TextAlign.left);
  }

  void _drawCameraIcon(Canvas canvas, Offset center) {
    // Simplified camera icon
    final bodyRect = Rect.fromCenter(center: center, width: 24, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(2)),
      Paint()..color = Colors.black,
    );
    // Lens
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);
    canvas.drawCircle(center, 3, Paint()..color = Colors.black);
  }

  void _drawEraserIcon(Canvas canvas, Offset center) {
    // Simplified eraser icon
    final rect = Rect.fromCenter(center: center, width: 20, height: 14);
    canvas.drawRect(rect, Paint()..color = Colors.black);
    canvas.drawLine(
      Offset(center.dx - 8, center.dy - 4),
      Offset(center.dx + 8, center.dy - 4),
      Paint()..color = Colors.white..strokeWidth = 2,
    );
  }

  void _drawSavedGraphPanel(Canvas canvas, double left, double top, double width) {
    final curveW = 50.0;
    final y = top;

    // Row 1: main (red)
    _drawSavedGraphRow(canvas, left + 10, y, curveW, model.mainBody.temperature,
        BlackbodySpectrumColors.mainCurve, false);

    // Row 2: saved 1 (gray solid)
    if (model.savedBodyOne.temperature != null) {
      _drawSavedGraphRow(canvas, left + 10, y + 25, curveW, model.savedBodyOne.temperature,
          Colors.grey, false);
    }

    // Row 3: saved 2 (gray dashed)
    if (model.savedBodyTwo.temperature != null) {
      _drawSavedGraphRow(canvas, left + 10, y + 50, curveW, model.savedBodyTwo.temperature,
          Colors.grey, true);
    }
  }

  void _drawSavedGraphRow(Canvas canvas, double x, double y, double curveW,
      double? temperature, Color color, bool dashed) {
    final path = Path()
      ..moveTo(x, y)
      ..cubicTo(x + curveW * 0.3, y - 10, x + curveW * 0.7, y + 10, x + curveW, y);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (dashed) {
      _drawDashedPath(canvas, path, paint, 5, 5);
    } else {
      canvas.drawPath(path, paint);
    }

    final tempStr = temperature != null
        ? '${temperature.round()} ${BlackbodySpectrumStrings.kelvinUnits}'
        : '';
    _drawText(canvas, tempStr, x + curveW + 10, y,
        BlackbodySpectrumColors.titlesText, 16, 80, align: TextAlign.left);
  }

  // ===== RESET BUTTON =====
  void _drawResetButton(Canvas canvas) {
    // [来源: BlackbodySpectrumScreenView.js:104-105]
    // resetAllButton.right = layoutBounds.maxX - INSET = 1014
    // resetAllButton.bottom = layoutBounds.maxY - INSET = 758
    final buttonWidth = 100.0;
    final buttonHeight = 40.0;
    final left = _phetWidth - _inset - buttonWidth;
    final top = _phetHeight - _inset - buttonHeight;

    final rect = Rect.fromLTWH(left, top, buttonWidth, buttonHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4)),
      Paint()..color = const Color(0xFFFF6F6F),
    );

    _drawText(canvas, BlackbodySpectrumStrings.resetAll, left + buttonWidth / 2, top + buttonHeight / 2,
        Colors.black, 16, buttonWidth.toDouble());
  }

  // ===== COORDINATE TRANSFORMS =====
  double _wavelengthToViewX(double wavelength) {
    return (wavelength / model.wavelengthMax) * _axesWidth;
  }

  double _spectralPowerDensityToViewY(double spd) {
    return -1e33 * (spd / model.verticalZoom) * _axesHeight;
  }

  // ===== UTILITIES =====
  void _drawText(Canvas canvas, String text, double x, double y,
      Color color, double fontSize, double maxWidth,
      {TextAlign align = TextAlign.center}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamilyFallback: const ['Arial', 'sans-serif'],
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    tp.layout(maxWidth: maxWidth);
    double dx;
    switch (align) {
      case TextAlign.right:
        dx = x - tp.width;
        break;
      case TextAlign.left:
        dx = x;
        break;
      default:
        dx = x - tp.width / 2;
    }
    tp.paint(canvas, Offset(dx, y - tp.height / 2));
  }

  String _formatVerticalLabel(double value) {
    if (value == 0) return '0';
    final log10 = math.log(value.abs()) / math.ln10;
    final exponent = log10.floor();
    final mantissa = value / math.pow(10, exponent);
    return '${mantissa.toStringAsFixed(0)} × 10^$exponent';
  }

  String _formatScientific(double value) {
    if (value == 0) return '0';
    final log10 = math.log(value.abs()) / math.ln10;
    final exponent = log10.floor();
    final mantissa = value / math.pow(10, exponent);
    return '${mantissa.toStringAsFixed(0)} × 10^$exponent';
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end,
      Paint paint, double dashLen, double gapLen) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final ux = dx / dist;
    final uy = dy / dist;
    var pos = 0.0;
    while (pos < dist) {
      final segEnd = math.min(pos + dashLen, dist);
      canvas.drawLine(
        Offset(start.dx + ux * pos, start.dy + uy * pos),
        Offset(start.dx + ux * segEnd, start.dy + uy * segEnd),
        paint,
      );
      pos = segEnd + gapLen;
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      double dashLen, double gapLen) {
    for (final metric in path.computeMetrics()) {
      var pos = 0.0;
      while (pos < metric.length) {
        final segEnd = math.min(pos + dashLen, metric.length);
        canvas.drawPath(metric.extractPath(pos, segEnd), paint);
        pos = segEnd + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BlackbodySpectrumPainter oldDelegate) =>
      oldDelegate.render != render ||
      oldDelegate.model.temperature != model.temperature ||
      oldDelegate.model.graphValuesVisible != model.graphValuesVisible ||
      oldDelegate.model.intensityVisible != model.intensityVisible ||
      oldDelegate.model.labelsVisible != model.labelsVisible ||
      oldDelegate.model.wavelengthMax != model.wavelengthMax ||
      oldDelegate.model.verticalZoom != model.verticalZoom ||
      oldDelegate.model.savedBodyOne.temperature != model.savedBodyOne.temperature ||
      oldDelegate.model.savedBodyTwo.temperature != model.savedBodyTwo.temperature;
}
