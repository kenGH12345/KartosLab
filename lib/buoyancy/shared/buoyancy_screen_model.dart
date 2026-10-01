/// Shared base for screen models: world ownership, clock lifecycle, no Flutter.
library;

import '../domain/material/buoyancy_gravity.dart';
import '../domain/material/buoyancy_material.dart';
import '../domain/world/vec2.dart';
import '../physics/buoyancy_physics_world.dart';

enum ScreenModelLifecycle { initial, idle, dragging, physicsRunning, settling, paused, disposed }

/// Injects a dedicated [BuoyancyPhysicsWorld] — never a static singleton.
abstract class BuoyancyScreenModel {
  BuoyancyScreenModel({BuoyancyPhysicsWorld? world})
      : world = world ?? BuoyancyPhysicsWorld();

  final BuoyancyPhysicsWorld world;
  ScreenModelLifecycle lifecycle = ScreenModelLifecycle.initial;
  bool _disposed = false;

  bool get isDisposed => _disposed;
  bool get isPaused => world.clock.paused;

  void step(double externalDt) {
    if (_disposed || isPaused) {
      return;
    }
    lifecycle = ScreenModelLifecycle.physicsRunning;
    world.step(externalDt);
    lifecycle = ScreenModelLifecycle.idle;
  }

  void pause() {
    world.clock.pause();
    lifecycle = ScreenModelLifecycle.paused;
  }

  void resume() {
    if (_disposed) {
      return;
    }
    world.clock.resume();
    lifecycle = ScreenModelLifecycle.idle;
  }

  void dispose() {
    _disposed = true;
    world.clock.pause();
    lifecycle = ScreenModelLifecycle.disposed;
  }

  void startDrag(String id, BVec2 modelPosition) {
    lifecycle = ScreenModelLifecycle.dragging;
    world.startDrag(id, modelPosition);
  }

  void updateDrag(String id, BVec2 modelPosition) {
    world.updateDrag(id, modelPosition);
  }

  void endDrag(String id) {
    world.endDrag(id);
    lifecycle = ScreenModelLifecycle.idle;
  }

  void setGravity(BuoyancyGravity g) => world.gravity = g;

  void setFluidMaterial(BuoyancyMaterial fluid) {
    assert(fluid.isFluid);
    world.pool.fluidMaterial = fluid;
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
  }

  void reset();
}
