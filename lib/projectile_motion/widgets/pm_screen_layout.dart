import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../controller/projectile_motion_controller.dart';
import '../painters/tools_painters.dart';
import '../pm_assets.dart';
import '../pm_colors.dart';
import '../pm_constants.dart';
import '../pm_strings.dart';
import '../transform/pm_transform.dart';
import '../view/pm_image_cache.dart';
import 'pm_buttons.dart';
import 'pm_controls.dart';
import 'pm_panels.dart';
import 'pm_scene.dart';

enum PmScreenKind { intro, vectors, drag, lab }

/// PhET ProjectileMotionScreenView 布局（ScreenView:504-515）：
/// - topRightPanel：right=1014, top=10
/// - bottomRightPanel：topRight 下方 10
/// - toolboxPanel：topRight 左侧 10，top=10
/// - 底部左：speed/angle 面板 → fire → timeControl
/// - 底部右：eraser → resetAll
/// - zoom：left=10, top=20
class PmScreenLayout extends StatefulWidget {
  const PmScreenLayout({
    super.key,
    required this.controller,
    required this.images,
    required this.kind,
  });

  final ProjectileMotionController controller;
  final PmImageCache images;
  final PmScreenKind kind;

  @override
  State<PmScreenLayout> createState() => _PmScreenLayoutState();
}

class _PmScreenLayoutState extends State<PmScreenLayout> {
  final GlobalKey<PmSceneState> _sceneKey = GlobalKey();
  final GlobalKey _toolboxKey = GlobalKey();
  int? _toolboxPointer;

  @override
  void dispose() {
    _unbindToolboxPointer();
    super.dispose();
  }

  void _unbindToolboxPointer() {
    final id = _toolboxPointer;
    if (id != null) {
      GestureBinding.instance.pointerRouter
          .removeRoute(id, _onToolboxRoutedPointer);
      _toolboxPointer = null;
    }
  }

  ProjectileMotionController get controller => widget.controller;

  bool get _flatironsVisible {
    // 仅 Drag/Lab（addFlatirons）且 altitude ∈ [1500,1700]
    if (widget.kind != PmScreenKind.drag && widget.kind != PmScreenKind.lab) {
      return false;
    }
    final a = controller.model.altitude;
    return a >= PmConstants.flatironsAltitudeMin &&
        a <= PmConstants.flatironsAltitudeMax;
  }

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    return Stack(
      children: [
        // 播放区
        Positioned.fill(
          child: PmScene(
            key: _sceneKey,
            controller: controller,
            images: widget.images,
            showHeightCue: widget.kind == PmScreenKind.intro,
            flatironsVisible: _flatironsVisible,
            angleSnapDegrees: widget.kind == PmScreenKind.lab ? 1 : 5,
            toolboxBoundsInScene: _toolboxSceneBounds,
          ),
        ),

        // zoom（左上，ScreenView:514-515 → top = 2*Y_MARGIN = 10）
        Positioned(
          left: 10,
          top: 10,
          child: PmZoomButtons(
            onZoomIn: model.zoomIn,
            onZoomOut: model.zoomOut,
            canZoomIn: model.zoom < PmConstants.maxZoom,
            canZoomOut: model.zoom > PmConstants.minZoom,
          ),
        ),

        // 右侧面板链（ScreenView:508-511）：
        // topRight.right = width-10, top=5；bottomRight.top = topRight.bottom+5；
        // toolbox.right = topRight.left - 10，与 topRight 同 top
        Positioned(
          right: 10,
          top: 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: _buildToolbox(),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopRightPanel(),
                  if (_buildBottomRightPanel() != null) ...[
                    const SizedBox(height: 5),
                    _buildBottomRightPanel()!,
                  ],
                ],
              ),
            ],
          ),
        ),

        // 底部左：Initial Speed / Angle / Fire / TimeControl
        Positioned(
          left: 10,
          bottom: 10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PmPanel(
                minWidth: 0,
                fill: PmColors.initialValuePanelFill,
                child: PmNumberControl(
                  title: PmStrings.initialSpeed,
                  value: model.initialSpeed,
                  min: PmConstants.launchVelocityMin,
                  max: PmConstants.launchVelocityMax,
                  delta: 1,
                  decimals: 0,
                  unit: 'm/s',
                  onChanged: model.setInitialSpeed,
                ),
              ),
              const SizedBox(width: 10),
              PmPanel(
                minWidth: 0,
                fill: PmColors.initialValuePanelFill,
                child: PmNumberControl(
                  title: PmStrings.angle,
                  value: model.cannonAngle,
                  min: PmConstants.cannonAngleMin,
                  max: PmConstants.cannonAngleMax,
                  delta: widget.kind == PmScreenKind.lab ? 1 : 5,
                  decimals: 0,
                  unit: '°',
                  onChanged: model.setCannonAngle,
                ),
              ),
              const SizedBox(width: 40),
              PmFireButton(
                enabled: model.fireEnabled,
                onFire: controller.fire,
                icon: widget.images[PmAssets.fireButton],
              ),
              const SizedBox(width: 40),
              PmPlayPauseButton(
                isPlaying: model.isPlaying,
                onToggle: () => controller.setPlaying(!model.isPlaying),
              ),
              const SizedBox(width: 6),
              PmStepButton(
                enabled: !model.isPlaying,
                onStep: controller.stepManual,
              ),
              const SizedBox(width: 10),
              PmTimeSpeedRadio(
                slowMotion: model.slowMotion,
                onChanged: model.setSlowMotion,
              ),
            ],
          ),
        ),

        // 底部右：Eraser + ResetAll（centerY = initialSpeedPanel.centerY ≈ bottom 25）
        Positioned(
          right: 10,
          bottom: 25,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PmEraserButton(onErase: model.eraseTrajectories),
              const SizedBox(width: 10),
              PmResetAllButton(onReset: controller.reset),
            ],
          ),
        ),

        // MeasuringTape / DataProbe 在面板之上（PhET ScreenView 图层顺序）
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerDown: (e) {
              _sceneKey.currentState?.tryHandleToolPointerDown(
                  e.pointer, _toSceneCoords(e.position));
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: PmToolsPainter(
                      transform: PmTransform(zoom: model.zoom),
                      measuringTape: model.measuringTape,
                      dataProbe: model.dataProbe,
                    ),
                  ),
                ),
                if (model.measuringTape.isActive)
                  PmMeasuringTapeHousing(
                    transform: PmTransform(zoom: model.zoom),
                    tape: model.measuringTape,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbox() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Stack(
      key: _toolboxKey,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toolIcon(
                isActive: controller.model.dataProbe.isActive,
                onDragStart: (pos) => _sceneKey.currentState
                    ?.startToolDrag(PmDragTarget.probe, pos),
                child: CustomPaint(
                  size: const Size(76, 38),
                  painter: PmDataProbeIconPainter(),
                ),
              ),
              const SizedBox(width: 30),
              _toolIcon(
                isActive: controller.model.measuringTape.isActive,
                onDragStart: (pos) => _sceneKey.currentState
                    ?.startToolDrag(PmDragTarget.tapeBase, pos),
                child: const SizedBox(
                  width: 84,
                  height: 47,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Image(
                          image: AssetImage(PmAssets.measuringTape),
                          width: 40.8,
                          height: 40.8,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      CustomPaint(
                        size: Size(84, 47),
                        painter: PmMeasuringTapeIconPainter(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  /// 工具图标：从 toolbox 拖出（ToolboxPanel:86-127），无 click-to-place。
  Widget _toolIcon({
    required bool isActive,
    required void Function(Offset viewPos) onDragStart,
    required Widget child,
  }) {
    // 激活时隐藏图标但保留占位（ToolboxPanel:96-99）
    final icon = Visibility(
      visible: !isActive,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: child,
    );
    if (isActive) return icon;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        if (_toolboxPointer != null) return;
        _toolboxPointer = e.pointer;
        GestureBinding.instance.pointerRouter
            .addRoute(e.pointer, _onToolboxRoutedPointer);
        onDragStart(_toSceneCoords(e.position));
      },
      child: icon,
    );
  }

  void _onToolboxRoutedPointer(PointerEvent e) {
    if (e.pointer != _toolboxPointer) return;
    if (e is PointerMoveEvent) {
      _dragToolTo(e.position);
    } else if (e is PointerUpEvent || e is PointerCancelEvent) {
      _unbindToolboxPointer();
      _endToolDrag();
    }
  }

  /// 把 toolbox 手势的 global 坐标换算到 scene（1024×618）坐标系
  Offset _toSceneCoords(Offset globalPos) {
    final sceneBox =
        _sceneKey.currentContext?.findRenderObject() as RenderBox?;
    return sceneBox?.globalToLocal(globalPos) ?? globalPos;
  }

  Rect? _toolboxSceneBounds() {
    final box = _toolboxKey.currentContext?.findRenderObject() as RenderBox?;
    final sceneBox =
        _sceneKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || sceneBox == null) return null;
    final topLeft = sceneBox.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  void _dragToolTo(Offset globalPos) {
    _sceneKey.currentState?.dragToolTo(_toSceneCoords(globalPos));
  }

  void _endToolDrag() {
    final scene = _sceneKey.currentState;
    final bounds = _toolboxSceneBounds();
    if (scene == null || bounds == null) return;
    scene.endToolDrag(bounds);
  }

  Widget _buildTopRightPanel() {
    switch (widget.kind) {
      case PmScreenKind.intro:
        return PmPanels.introProjectilePanel(controller);
      case PmScreenKind.vectors:
        return PmPanels.vectorsProjectilePanel(controller);
      case PmScreenKind.drag:
        return PmPanels.dragProjectilePanel(controller);
      case PmScreenKind.lab:
        return PmPanels.labInitialValuesPanel(controller);
    }
  }

  Widget? _buildBottomRightPanel() {
    switch (widget.kind) {
      case PmScreenKind.intro:
        return PmPanels.introVectorsPanel(controller);
      case PmScreenKind.vectors:
        return PmPanels.vectorsVectorsPanel(controller);
      case PmScreenKind.drag:
        return PmPanels.dragVectorsPanel(controller);
      case PmScreenKind.lab:
        return PmPanels.labProjectilePanel(controller);
    }
  }
}
