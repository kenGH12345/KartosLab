import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../../data/graph_data.dart';
import '../../domain/detector_mode.dart';
import '../../domain/source_type.dart';
import '../../render/high_intensity/hi_detector_renderer.dart';
import '../../render/high_intensity/hi_graph_renderer.dart';
import '../../render/high_intensity/wave_field_renderer.dart';
import '../common/qwi_colors.dart';
import '../common/qwi_double_slit_barrier.dart';
import '../common/qwi_laser_pointer.dart';
import '../common/qwi_measuring_tape.dart';
import '../common/qwi_panel.dart';
import '../common/qwi_particle_selector.dart';
import '../common/qwi_position_plot.dart';
import '../common/qwi_stopwatch.dart';
import '../common/qwi_time_plot.dart';
import '../common/qwi_tools_panel.dart';
import '../common/qwi_wave_visualization_chrome.dart';
import '../high_intensity/high_intensity_controller.dart';
import '../high_intensity/high_intensity_controls.dart';
import 'high_intensity_layout_spec.dart';
import 'qwi_layout_primitives.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// Places existing High Intensity components per [HighIntensityLayoutSpec].
///
/// Geometry only — no Model / Solver / WaveKernel.
class HighIntensityLayoutComposer extends StatelessWidget {
  const HighIntensityLayoutComposer({
    super.key,
    required this.controller,
    this.spec,
  });

  final HighIntensityController controller;
  final HighIntensityLayoutSpec? spec;

  @override
  Widget build(BuildContext context) {
    final layout = spec ?? HighIntensityLayoutSpec.resolve();
    final wave = layout.waveRegion;
    final det = layout.detector;
    final graph = layout.graph;
    final waveField = controller.waveField;
    final detData = controller.detectorData;

    return SizedBox(
      width: layout.canvas.width,
      height: layout.canvas.height,
      child: Material(
        color: QwiColors.screenBackground,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // --- Display (z low) ---
            _box(
              wave,
              Stack(
                children: [
                  CustomPaint(
                    key: const Key('hi_wave_canvas'),
                    size: Size(wave.width, wave.height),
                    painter: WaveFieldPixelPainter(
                      data: waveField,
                      dest: Rect.fromLTWH(0, 0, wave.width, wave.height),
                    ),
                  ),
                  QwiWaveVisualizationChrome(
                    width: wave.width,
                    height: wave.height,
                    regionWidthMeters: controller.scene.solver.regionWidth,
                  ),
                ],
              ),
            ),
            Positioned(
              left: wave.left,
              top: wave.top,
              width: wave.width,
              height: wave.height + QwiDoubleSlitBarrier.belowWaveExtent,
              child: QwiDoubleSlitBarrier(
                waveSize: Size(wave.width, wave.height),
                barrierFraction: controller.scene.solver.barrierFractionX,
                slitSeparation: controller.scene.slitSeparationMm,
                slitSeparationMin: controller.scene.slitSeparationMinMm,
                slitSeparationMax: controller.scene.slitSeparationMaxMm,
                config: controller.scene.slitConfiguration,
                regionWidthMeters: controller.scene.solver.regionWidth,
                topDetectorHits: controller.scene.leftDetectorHits,
                bottomDetectorHits: controller.scene.rightDetectorHits,
                onBarrierFractionChanged: controller.setBarrierFractionX,
              ),
            ),
            if (!controller.graphVisible)
              _box(
                det,
                CustomPaint(
                  key: const Key('hi_detector_canvas'),
                  painter: HiDetectorPainter(
                    data: detData,
                    rect: Rect.fromLTWH(0, 0, det.width, det.height),
                  ),
                ),
              ),
            if (controller.graphVisible)
              _box(
                graph,
                CustomPaint(
                  key: const Key('hi_graph_canvas'),
                  painter: HiGraphPainter(
                    mode: controller.scene.detectionMode,
                    detector: detData,
                    histogram: HitsHistogramData.fromHits(controller.scene.hits.hits),
                    graphRect: Rect.fromLTWH(0, 0, graph.width, graph.height),
                    zoomLevel: controller.model.graphZoom.level,
                  ),
                ),
              ),

            // --- Functional (CONTENT_DRIVEN height: anchor L/T/W only) ---
            _anchor(
              layout.sourcePanel,
              QwiPanel(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: HiSourceControls(controller: controller),
              ),
            ),
            Positioned(
              left: layout.sceneRadios.left,
              top: layout.sceneRadios.top,
              width: layout.sceneRadios.width,
              height: layout.sceneRadios.height,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: QwiParticleSelector(
                  keyPrefix: 'hi_source',
                  active: controller.model.activeSource,
                  onSelect: controller.selectSource,
                  cellWidth: 54,
                  cellHeight: 48,
                ),
              ),
            ),
            // HI laser emitter (PhET source-beam thumbnail band).
            Positioned(
              left: layout.emitter.left,
              top: layout.emitter.top,
              width: layout.emitter.width,
              height: layout.emitter.height,
              child: KeyedSubtree(
                key: const Key('hi_emit_toggle'),
                child: QwiLaserPointer(
                  emitting: controller.scene.isEmitting,
                  onToggle: controller.toggleEmitting,
                  isPhoton: controller.scene.sourceType.isPhoton,
                  sourceScale: HighIntensityLayoutConstants.emitterScale,
                  width: layout.emitter.width,
                  height: layout.emitter.height,
                ),
              ),
            ),
            // Right rail (original): Wave Display → Screen → Tools.
            Positioned(
              left: layout.waveDisplayPanel.left,
              top: layout.waveDisplayPanel.top,
              width: HighIntensityLayoutConstants.rightPanelWidth,
              height: layout.toolsPanel.bottom - layout.waveDisplayPanel.top,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 32,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: HighIntensityLayoutConstants.rightPanelWidth,
                        child: QwiPanel(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                QwiStrings.waveDisplay,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              HiWaveModeControls(controller: controller),
                              const SizedBox(height: 4),
                              HiTimeControls(controller: controller),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: HighIntensityLayoutConstants.rightPanelStackGap),
                  Expanded(
                    flex: 40,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: HighIntensityLayoutConstants.rightPanelWidth,
                        child: QwiPanel(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HiDetectorControls(controller: controller),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  QwiPushButton(
                                    key: const Key('hi_take_snapshot'),
                                    label: QwiStrings.snap,
                                    enabled: !controller.scene.snapshots.isFull,
                                    onPressed: controller.scene.snapshots.isFull
                                        ? null
                                        : () => controller.takeSnapshot(),
                                    minWidth: 52,
                                    minHeight: 24,
                                  ),
                                  const SizedBox(width: 6),
                                  QwiPushButton(
                                    key: const Key('hi_view_snapshots'),
                                    label: QwiStrings.view,
                                    enabled: controller.scene.snapshots.length > 0,
                                    onPressed: controller.scene.snapshots.length == 0
                                        ? null
                                        : () => controller.setSnapshotPanelOpen(true),
                                    minWidth: 52,
                                    minHeight: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: HighIntensityLayoutConstants.rightPanelStackGap),
                  Expanded(
                    flex: 28,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: HighIntensityLayoutConstants.rightPanelWidth,
                        child: QwiPanel(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          child: QwiToolsPanel(
                            keyPrefix: 'hi',
                            measuringTape: controller.measuringTapeVisible,
                            onMeasuringTape: controller.setMeasuringTapeVisible,
                            stopwatch: controller.stopwatchVisible,
                            onStopwatch: controller.setStopwatchVisible,
                            timePlot: controller.timePlotVisible,
                            onTimePlot: controller.setTimePlotVisible,
                            positionPlot: controller.positionPlotVisible,
                            onPositionPlot: controller.setPositionPlotVisible,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Charts under small tools (PhET MeasurementToolsLayerNode layering).
            if (controller.timePlotVisible)
              QwiTimePlotOverlay(
                state: controller.model.plots,
                waveRect: wave.asRect,
                mode: controller.scene.waveDisplayMode,
                onChanged: controller.notifyPlotsChanged,
              ),
            if (controller.positionPlotVisible)
              QwiPositionPlotOverlay(
                state: controller.model.plots,
                waveRect: wave.asRect,
                regionWidthM: controller.scene.solver.regionWidth,
                mode: controller.scene.waveDisplayMode,
                onChanged: controller.notifyPlotsChanged,
              ),
            // --- Overlay: measuring tape / stopwatch ---
            if (controller.measuringTapeVisible)
              Positioned.fill(
                child: QwiMeasuringTapeOverlay(
                  state: controller.model.measuringTape,
                  waveRect: wave.asRect,
                  regionWidthM: controller.scene.solver.regionWidth,
                  onChanged: controller.notifyTapeChanged,
                ),
              ),
            if (controller.stopwatchVisible)
              QwiStopwatchOverlay(
                state: controller.model.stopwatch,
                canvasSize: layout.canvas,
                onChanged: controller.notifyStopwatchChanged,
              ),

            // --- Bottom tools ---
            Positioned(
              left: layout.slitControls.left,
              top: layout.slitControls.top,
              width: layout.slitControls.width,
              height: layout.slitControls.height,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: layout.slitControls.width,
                  child: HiSlitControls(controller: controller),
                ),
              ),
            ),
            if (controller.scene.detectionMode == DetectorMode.hits)
              _box(
                layout.clearButton,
                Material(
                  color: const Color(0xFFFFE066),
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    key: const Key('hi_clear_screen'),
                    onTap: controller.clearScreen,
                    child: const SizedBox(
                      width: HighIntensityLayoutConstants.clearButtonWidth,
                      height: HighIntensityLayoutConstants.clearButtonHeight,
                      child: Center(child: Text('⌫', style: TextStyle(fontSize: 14))),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: layout.reset.left,
              top: layout.reset.top,
              width: layout.reset.width,
              height: layout.reset.height,
              child: KratosResetAllButton(
                key: const Key('hi_reset_all'),
                onPressed: controller.reset,
                radius: HighIntensityLayoutConstants.resetRadius,
              ),
            ),

            // --- Snapshot overlay ---
            if (controller.snapshotPanelOpen)
              Positioned.fill(
                child: Material(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      key: const Key('hi_snapshot_panel'),
                      width: layout.snapshotDialog.width,
                      height: layout.snapshotDialog.height,
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(QwiStrings.snapshots, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              TextButton(
                                onPressed: () => controller.setSnapshotPanelOpen(false),
                                child: Text(QwiStrings.close),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var i = 0; i < controller.scene.snapshots.length; i++)
                                  ListTile(
                                    title: Text(
                                      'Snapshot ${controller.scene.snapshots.snapshots[i].snapshotNumber}',
                                    ),
                                    subtitle: Text(
                                      'PDF bins=${controller.scene.snapshots.snapshots[i].intensityDistribution.length}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Fixed display bounds (wave / detector / graph / reset / clear).
  static Widget _box(QwiRect r, Widget child) => Positioned(
        left: r.left,
        top: r.top,
        width: r.width,
        height: r.height,
        child: child,
      );

  /// Content-driven modules: Spec supplies left/top/width; height is intrinsic.
  static Widget _anchor(QwiRect r, Widget child) => Positioned(
        left: r.left,
        top: r.top,
        width: r.width,
        child: child,
      );
}
