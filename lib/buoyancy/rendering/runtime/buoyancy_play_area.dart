import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../layout/buoyancy_global_layout_spec.dart';
import '../../shared/buoyancy_scale_host.dart';
import '../../shared/buoyancy_screen_model.dart';
import '../interaction/buoyancy_pointer_adapter.dart';
import '../primitives/buoyancy_scene_painter.dart';
import '../primitives/composed_scene.dart';
import '../texture/buoyancy_texture_cache.dart';
import '../transform/buoyancy_three_transform.dart';

class BuoyancyPlayArea extends StatefulWidget {
  const BuoyancyPlayArea({
    super.key,
    required this.model,
    required this.frame,
    required this.transform,
    required this.sceneBuilder,
    required this.overlay,
  });

  final BuoyancyScreenModel model;
  final BuoyancyDesignFrame frame;
  final BuoyancyThreeTransform transform;
  final ComposedScene Function() sceneBuilder;
  final Widget overlay;

  @override
  State<BuoyancyPlayArea> createState() => _BuoyancyPlayAreaState();
}

class _BuoyancyPlayAreaState extends State<BuoyancyPlayArea>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  String? _dragId;
  SceneScaleMarker? _dragScale;
  double? _poolScaleDragStartHeight;
  double? _poolScaleDragStartY;
  Map<String, ui.Image> _textures = const {};

  @override
  void initState() {
    super.initState();
    _loadTextures();
    _ticker = createTicker((elapsed) {
      if (widget.model.isPaused || widget.model.isDisposed) {
        return;
      }
      widget.model.step(1 / 60);
      if (mounted) {
        setState(() {});
      }
    })
      ..start();
  }

  Future<void> _loadTextures() async {
    final cache = BuoyancyTextureCache.instance;
    await cache.ensureLoaded();
    if (!mounted) {
      return;
    }
    setState(() {
      _textures = {
        for (final path in cache.paths) path: cache[path]!,
      };
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onScaleDrag(Offset local) {
    final scale = _dragScale;
    final model = widget.model;
    if (scale == null || model is! BuoyancyScaleHost) {
      return;
    }
    final host = model as BuoyancyScaleHost;
    final adapter = BuoyancyPointerAdapter(widget.transform);
    switch (scale.dragMode) {
      case ScaleDragMode.vertical:
        final sh = _poolScaleDragStartHeight;
        final sy = _poolScaleDragStartY;
        if (sh == null || sy == null) {
          return;
        }
        adapter.updatePoolScaleHeightByDelta(
          host,
          startHeight: sh,
          startViewportY: sy,
          viewport: local,
        );
      case ScaleDragMode.free:
        // Drive land scale as a physics mass (stacking / collision).
        adapter.update(model, 'scale.land', local);
        host.landScaleX = host.landScale.position.x;
      case ScaleDragMode.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adapter = BuoyancyPointerAdapter(widget.transform);
    final scene = widget.sceneBuilder();
    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) {
              final scale = adapter.hitScale(e.localPosition, scene);
              if (scale != null) {
                _dragScale = scale;
                _dragId = null;
                if (scale.dragMode == ScaleDragMode.vertical &&
                    widget.model is BuoyancyScaleHost) {
                  final m = widget.model as BuoyancyScaleHost;
                  _poolScaleDragStartHeight = m.poolScaleHeight;
                  _poolScaleDragStartY = e.localPosition.dy;
                } else if (scale.dragMode == ScaleDragMode.free) {
                  adapter.start(widget.model, 'scale.land', e.localPosition);
                }
                setState(() {});
                return;
              }
              final id = adapter.hitMassId(e.localPosition, scene);
              if (id == null) {
                return;
              }
              _dragScale = null;
              _dragId = id;
              adapter.start(widget.model, id, e.localPosition);
            },
            onPointerMove: (e) {
              if (_dragScale != null) {
                _onScaleDrag(e.localPosition);
                setState(() {});
                return;
              }
              final id = _dragId;
              if (id == null) {
                return;
              }
              adapter.update(widget.model, id, e.localPosition);
            },
            onPointerUp: (_) {
              if (_dragScale != null) {
                if (_dragScale!.dragMode == ScaleDragMode.free) {
                  adapter.end(widget.model, 'scale.land');
                }
                _dragScale = null;
                _poolScaleDragStartHeight = null;
                _poolScaleDragStartY = null;
                setState(() {});
                return;
              }
              final id = _dragId;
              if (id != null) {
                adapter.end(widget.model, id);
              }
              _dragId = null;
            },
            child: CustomPaint(
              painter: BuoyancyScenePainter(
                scene: scene,
                transform: widget.transform,
                textures: _textures,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        // Sliders / InkWell in overlays need a Material ancestor.
        Material(
          type: MaterialType.transparency,
          child: widget.overlay,
        ),
      ],
    );
  }
}

class BuoyancyPanel extends StatelessWidget {
  const BuoyancyPanel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 240, 240, 240),
      borderRadius: BorderRadius.circular(5),
      elevation: 2,
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}
