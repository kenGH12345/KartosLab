import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../cck_assets.dart';
import '../cck_colors.dart';
import '../cck_strings.dart';
import '../controller/cck_ac_controller.dart';
import '../render/cck_mvt.dart';
import '../render/cck_render_builder.dart';
import '../render/cck_render_data.dart';
import '../widgets/cck_image_loader.dart';
import '../widgets/cck_panels.dart';
import '../widgets/circuit_canvas.dart';

class CckAcVirtualLabScreen extends StatefulWidget {
  const CckAcVirtualLabScreen({super.key});

  @override
  State<CckAcVirtualLabScreen> createState() => _CckAcVirtualLabScreenState();
}

class _CckAcVirtualLabScreenState extends State<CckAcVirtualLabScreen>
    with SingleTickerProviderStateMixin {
  late final CckAcController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  Map<String, ui.Image> _images = {};
  int _toolboxPage = 0;
  bool _advancedExpanded = false;
  final _canvasKey = GlobalKey<CircuitCanvasState>();

  @override
  void initState() {
    super.initState();
    _controller = CckAcController()..addListener(_onTick);
    _ticker = createTicker(_onFrame)..start();
    loadCckImages().then((imgs) {
      if (mounted) setState(() => _images = imgs);
    });
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _onFrame(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    _controller.tick(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CckColors.screenBackground,
      appBar: AppBar(
        title: const Text(CckStrings.title, style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF0C4A6E),
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: NineGridLayout(
        backgroundColor: CckColors.screenBackground,
        midLeft: _leftColumn(),
        center: _center(),
        midRight: _rightColumn(),
        bottomLeft: Padding(
          padding: const EdgeInsets.all(6),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ZoomButtons(controller: _controller),
          ),
        ),
      ),
    );
  }

  Widget _leftColumn() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: ElementToolbox(
              controller: _controller,
              page: _toolboxPage,
              onPageChanged: (p) => setState(() => _toolboxPage = p),
              onSpawn: (spec) {
                _canvasKey.currentState?.spawnAtCenter(spec);
              },
            ),
          ),
          const SizedBox(height: 4),
          ViewToggle(controller: _controller),
          const SizedBox(height: 4),
          ZoomButtons(controller: _controller),
        ],
      ),
    );
  }

  Widget _rightColumn() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ListView(
        children: [
          DisplayOptionsPanel(controller: _controller),
          const SizedBox(height: 6),
          SensorToolbox(controller: _controller),
          const SizedBox(height: 6),
          AdvancedPanel(
            controller: _controller,
            expanded: _advancedExpanded,
            onToggle: () => setState(() => _advancedExpanded = !_advancedExpanded),
          ),
          if (_controller.circuit.voltageChartVisible) ...[
            const SizedBox(height: 6),
            _miniChart(_controller.circuit.voltageChart, 'V'),
          ],
          if (_controller.circuit.currentChartVisible) ...[
            const SizedBox(height: 6),
            _miniChart(_controller.circuit.currentChart, 'A'),
          ],
        ],
      ),
    );
  }

  Widget _miniChart(List<double> samples, String unit) {
    return CckPanel(
      child: SizedBox(
        height: 72,
        child: CustomPaint(
          painter: _ChartPainter(samples),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(unit, style: const TextStyle(fontSize: 10)),
          ),
        ),
      ),
    );
  }

  Widget _center() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final data = buildRenderData(_controller.circuit);
        final mvt = CckMvt(canvasSize: size, zoom: _controller.zoomScale);
        return Stack(
          children: [
            ColoredBox(
              color: CckColors.screenBackground,
              child: CircuitCanvas(
                key: _canvasKey,
                controller: _controller,
                images: _images,
              ),
            ),
            for (final meter in data.voltmeters)
              if (meter.active) _voltmeterLayer(meter, mvt),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: EditBar(controller: _controller),
            ),
            Positioned(
              right: 10,
              bottom: 8,
              child: _bottomRightChrome(),
            ),
          ],
        );
      },
    );
  }

  Widget _voltmeterLayer(CckRenderVoltmeter meter, CckMvt mvt) {
    final body = mvt.toView(meter.body);
    final red = mvt.toView(meter.redProbe);
    final black = mvt.toView(meter.blackProbe);
    final reading = meter.reading;
    return Stack(
      children: [
        Positioned(
          left: body.dx - 50,
          top: body.dy - 36,
          child: Column(
            children: [
              Image.asset(CckAssets.voltmeterBody, width: 100, filterQuality: FilterQuality.medium),
              Text(
                reading == null ? '-' : '${reading.toStringAsFixed(2)} V',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Positioned(
          left: red.dx - 10,
          top: red.dy - 28,
          child: Image.asset(CckAssets.probeRed, width: 20, filterQuality: FilterQuality.medium),
        ),
        Positioned(
          left: black.dx - 10,
          top: black.dy - 28,
          child: Image.asset(CckAssets.probeBlack, width: 20, filterQuality: FilterQuality.medium),
        ),
      ],
    );
  }

  Widget _bottomRightChrome() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TimeControlBar(controller: _controller),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                _controller.reset();
                setState(() => _advancedExpanded = false);
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CckColors.resetOrange,
                  boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                ),
                child: const Icon(Icons.refresh, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.samples);
  final List<double> samples;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;
    var minV = samples.first;
    var maxV = samples.first;
    for (final v in samples) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    if (minV == maxV) {
      minV -= 1;
      maxV += 1;
    }
    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = size.width * i / (samples.length - 1);
      final y = size.height -
          (samples[i] - minV) / (maxV - minV) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = CckColors.chartSeries
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
