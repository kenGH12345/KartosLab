import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../../data/graph_data.dart';
import '../../render/high_intensity/hi_detector_renderer.dart';
import '../../render/high_intensity/wave_field_renderer.dart';
import '../../render/single_particles/sp_graph_renderer.dart';
import '../common/qwi_colors.dart';
import '../common/qwi_double_slit_barrier.dart';
import '../common/qwi_measuring_tape.dart';
import '../common/qwi_panel.dart';
import '../common/qwi_particle_selector.dart';
import '../common/qwi_position_plot.dart';
import '../common/qwi_probe_node.dart';
import '../common/qwi_stopwatch.dart';
import '../common/qwi_time_plot.dart';
import '../common/qwi_tools_panel.dart';
import '../common/qwi_wave_visualization_chrome.dart';
import '../single_particles/single_particles_controller.dart';
import '../single_particles/single_particles_controls.dart';
import '../single_particles/sp_emitter_view.dart';
import 'qwi_layout_primitives.dart';
import 'single_particles_layout_spec.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// Places existing Single Particles components per [SingleParticlesLayoutSpec].
///
/// Geometry only — no packet / probeProbability / auto-fire interval logic.
class SingleParticlesLayoutComposer extends StatelessWidget {
  const SingleParticlesLayoutComposer({
    super.key,
    required this.controller,
    this.spec,
  });

  final SingleParticlesController controller;
  final SingleParticlesLayoutSpec? spec;

  @override
  Widget build(BuildContext context) {
    final layout = spec ?? SingleParticlesLayoutSpec.resolve();
    final wave = layout.waveRegion;
    final det = layout.detector;
    final graph = layout.graph;
    final scene = controller.scene;
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
            _box(
              wave,
              Stack(
                children: [
                  CustomPaint(
                    key: const Key('sp_wave_canvas'),
                    size: Size(wave.width, wave.height),
                    painter: WaveFieldPixelPainter(
                      data: waveField,
                      dest: Rect.fromLTWH(0, 0, wave.width, wave.height),
                    ),
                  ),
                  QwiWaveVisualizationChrome(
                    width: wave.width,
                    height: wave.height,
                    regionWidthMeters: scene.solver.regionWidth,
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
                barrierFraction: scene.solver.barrierFractionX,
                slitSeparation: scene.slitSeparationMm,
                slitSeparationMin: scene.slitSeparationMinMm,
                slitSeparationMax: scene.slitSeparationMaxMm,
                config: scene.slitConfiguration,
                regionWidthMeters: scene.solver.regionWidth,
                topDetectorHits: scene.leftDetectorHits,
                bottomDetectorHits: scene.rightDetectorHits,
                onBarrierFractionChanged: controller.setBarrierFractionX,
              ),
            ),
            if (scene.probeVisible && scene.isProbeAvailable)
              Positioned(
                left: layout.probeLayer.left,
                top: layout.probeLayer.top,
                width: layout.probeLayer.width,
                height: layout.probeLayer.height,
                child: QwiProbeNode(
                  probe: scene.detectorProbe,
                  waveSize: Size(wave.width, wave.height),
                  panelAnchor: Offset(wave.width * 0.5, wave.height + 40),
                  onMove: controller.moveProbe,
                  onRadiusChanged: controller.setProbeRadius,
                  onDetectOrReset: controller.performProbeDetectOrReset,
                ),
              ),
            if (!controller.graphVisible)
              _box(
                det,
                CustomPaint(
                  key: const Key('sp_detector_canvas'),
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
                  key: const Key('sp_graph_canvas'),
                  painter: SpGraphPainter(
                    detector: detData,
                    histogram: HitsHistogramData.fromHits(scene.hits.hits),
                    graphRect: Rect.fromLTWH(0, 0, graph.width, graph.height),
                    zoomLevel: controller.model.graphZoom.level,
                  ),
                ),
              ),

            _anchor(
              layout.sourcePanel,
              QwiPanel(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: SpSourceControls(controller: controller),
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
                  keyPrefix: 'sp_source',
                  active: controller.model.activeSource,
                  onSelect: controller.selectSource,
                  cellWidth: 54,
                  cellHeight: 48,
                ),
              ),
            ),
            // SP gun at wave left edge (PhET SingleParticleEmitterNode).
            Positioned(
              left: layout.emitter.left,
              top: layout.emitter.top,
              width: layout.emitter.width,
              height: layout.emitter.height,
              child: SpEmitterView(
                controller: controller,
                bounds: Size(layout.emitter.width, layout.emitter.height),
              ),
            ),
            // Right rail (original): Wave Display → Screen → Tools.
            Positioned(
              left: layout.waveDisplayPanel.left,
              top: layout.waveDisplayPanel.top,
              width: SingleParticlesLayoutConstants.rightPanelWidth,
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
                        width: SingleParticlesLayoutConstants.rightPanelWidth,
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
                              SpWaveModeControls(controller: controller),
                              const SizedBox(height: 4),
                              SpTimeControls(controller: controller),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SingleParticlesLayoutConstants.rightPanelStackGap),
                  Expanded(
                    flex: 40,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: SingleParticlesLayoutConstants.rightPanelWidth,
                        child: QwiPanel(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SpDetectorControls(controller: controller),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  QwiPushButton(
                                    key: const Key('sp_take_snapshot'),
                                    label: QwiStrings.snap,
                                    enabled: !scene.snapshots.isFull,
                                    onPressed: scene.snapshots.isFull
                                        ? null
                                        : () => controller.takeSnapshot(),
                                    minWidth: 52,
                                    minHeight: 24,
                                  ),
                                  const SizedBox(width: 6),
                                  QwiPushButton(
                                    key: const Key('sp_view_snapshots'),
                                    label: QwiStrings.view,
                                    enabled: scene.snapshots.length > 0,
                                    onPressed: scene.snapshots.length == 0
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
                  const SizedBox(height: SingleParticlesLayoutConstants.rightPanelStackGap),
                  Expanded(
                    flex: 28,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: SingleParticlesLayoutConstants.rightPanelWidth,
                        child: QwiPanel(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          child: QwiToolsPanel(
                            keyPrefix: 'sp',
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

            if (controller.timePlotVisible)
              QwiTimePlotOverlay(
                state: controller.model.plots,
                waveRect: wave.asRect,
                mode: scene.waveDisplayMode,
                onChanged: controller.notifyPlotsChanged,
              ),
            if (controller.positionPlotVisible)
              QwiPositionPlotOverlay(
                state: controller.model.plots,
                waveRect: wave.asRect,
                regionWidthM: scene.solver.regionWidth,
                mode: scene.waveDisplayMode,
                onChanged: controller.notifyPlotsChanged,
              ),
            if (controller.measuringTapeVisible)
              Positioned.fill(
                child: QwiMeasuringTapeOverlay(
                  state: controller.model.measuringTape,
                  waveRect: wave.asRect,
                  regionWidthM: scene.solver.regionWidth,
                  onChanged: controller.notifyTapeChanged,
                ),
              ),
            if (controller.stopwatchVisible)
              QwiStopwatchOverlay(
                state: controller.model.stopwatch,
                canvasSize: layout.canvas,
                onChanged: controller.notifyStopwatchChanged,
              ),

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
                  child: SpSlitControls(controller: controller),
                ),
              ),
            ),
            _box(
              layout.clearButton,
              Material(
                color: const Color(0xFFFFE066),
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  key: const Key('sp_clear_screen'),
                  onTap: controller.clearScreen,
                  child: const SizedBox(
                    width: SingleParticlesLayoutConstants.clearButtonWidth,
                    height: SingleParticlesLayoutConstants.clearButtonHeight,
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
                key: const Key('sp_reset_all'),
                onPressed: controller.reset,
                radius: SingleParticlesLayoutConstants.resetRadius,
              ),
            ),

            if (controller.snapshotPanelOpen)
              Positioned.fill(
                child: Material(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      key: const Key('sp_snapshot_panel'),
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
                                for (var i = 0; i < scene.snapshots.length; i++)
                                  ListTile(
                                    title: Text(QwiStrings.snapshotN(scene.snapshots.snapshots[i].snapshotNumber)),
                                    subtitle: Text(
                                      'hits=${scene.snapshots.snapshots[i].hits.length}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: IconButton(
                                      key: Key('sp_delete_snapshot_$i'),
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => controller.deleteSnapshot(i),
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

  static Widget _box(QwiRect r, Widget child) => Positioned(
        left: r.left,
        top: r.top,
        width: r.width,
        height: r.height,
        child: child,
      );

  static Widget _anchor(QwiRect r, Widget child) => Positioned(
        left: r.left,
        top: r.top,
        width: r.width,
        child: child,
      );
}
