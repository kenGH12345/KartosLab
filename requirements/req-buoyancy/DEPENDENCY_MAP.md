# Dependency Map · Buoyancy

真源：`phet sourses/buoyancy-main/buoyancy-main/package.json` 与 `dependencies.json`。
没有因为 README 的 clone 清单就假定某个库已在本地。

## Version lock

| Key | Value | Evidence |
| --- | --- | --- |
| BUOYANCY_SOURCE_VERSION | `1.3.0-dev.2` | `package.json` `version`；`dependencies.json` comment |
| SOURCE_COMMIT | `UNKNOWN` | lockfile 记录 `buoyancy.sha = e3a4d490dd75a4be8ad8a6f4744fc691d533c6f2`，工作树没有 `.git`，无法核对 |
| DEPENDENCY_SNAPSHOT | `dependencies.json` comment `Wed Feb 26 2025 16:28:33 GMT-0700` | 同一文件 |
| common lockfile SHA | `0295f8f62bff7f345185fbf11a9e42c08206e4c5` | `dependencies.json` `density-buoyancy-common.sha` |
| common local HEAD | `0c835c642c0603531c3b9f0844fcb8b196abe003` | `git rev-parse HEAD`，日期 `2026-04-20` |
| common lockfile object | ABSENT | `git cat-file` 对该 SHA 失败。shallow clone 不含该对象 |

## Graph

```text
buoyancy 1.3.0-dev.2
  phet.phetLibs
    density-buoyancy-common 1.0.0-dev.0     LOCAL, SHA MISMATCH
    mobius                                  NOT LOCAL
  phet.preload
    ../sherpa/lib/p2-0.7.1.js               NOT LOCAL
    ../sherpa/lib/three-r104.js             NOT LOCAL
  dependencies.json (all branch=main)
    assert, axon, brand, chipper, dot, joist, kite,
    perennial-alias, phet-core, phet-io, phet-io-sim-specific,
    phet-io-wrappers, phetcommon, phetmarks,
    query-string-machine, scenery, scenery-phet, sherpa,
    studio, sun, tambo, tandem, twixt, utterance-queue
    → none of these directories are in phet sourses/ except the two sims above
```

`density-buoyancy-common/package.json` 自己的 `phet.phetLibs` 只有 `mobius`，preload 同样是 p2 0.7.1 与 three r104。common 目录里没有 `dependencies.json`。

## Classification

| Dependency | Class | Local? | Flutter strategy |
| --- | --- | --- | --- |
| buoyancy | Simulation-specific shell | YES | REIMPLEMENT as screen registry only. The shell is 5 Screen constructors |
| density-buoyancy-common | Shared domain/common | YES, different SHA | REIMPLEMENT. Do not vendor the TypeScript. Do not copy `lib/density` solver as this model |
| mobius | PhET visual framework (THREE screen, MVT, ray) | NO | SOURCE AUDIT REQUIRED. Camera constants in common are known; `modelToViewPoint` implementation is not |
| scenery / scenery-phet / sun | PhET visual framework | NO | REIMPLEMENT controls as PhET-equivalent widgets (`KratosResetAllButton`, existing L0). Not Material `DropdownButton` / `Switch` |
| joist | PhET visual framework (Sim, Screen, layout bounds, clock) | NO | REIMPLEMENT navigation later. `ScreenView.DEFAULT_LAYOUT_BOUNDS` numeric size is UNKNOWN |
| axon / tandem | Generic utility (Property, PhET-iO) | NO | REIMPLEMENT as Dart state. PhET-iO instrumentation is NOT NEEDED for the student sim |
| dot / kite | Generic utility (Vector, Bounds, Shape) | NO | REIMPLEMENT with existing vector/bounds types |
| phet-core | Generic utility | NO | NOT NEEDED as a package |
| tambo | Audio | NO | NOT NEEDED until a local clip is found. Credits `soundDesign` is empty |
| utterance-queue | Accessibility | NO | ADAPT later as Flutter semantics. Key-binding source is not local |
| sherpa p2 0.7.1 | Physics engine | NO (preload path only) | REIMPLEMENT the forces and constraints described by `PhysicsEngine.ts`. Do not embed p2 |
| sherpa three r104 | 3D renderer | NO | REIMPLEMENT meshes with Flutter 3D or painters after a later visual phase. Procedural meshes stay procedural |
| chipper / brand / perennial / phet-io* / studio / phetmarks / query-string-machine | Build-only or PhET-iO | NO | NOT NEEDED for the Flutter sim, except query-parameter defaults already copied into `DensityBuoyancyCommonQueryParameters.ts` |
| assert | Build-only | NO | NOT NEEDED |

## density-buoyancy-common decision

**REIMPLEMENT.**

本地 common 是 Buoyancy 的 Model / View / 物理 / 材质 / 3D 网格所在地。buoyancy 仓库只注册 Screen。后续 Flutter 要按这份本地 common 重写领域模型，而不是把 TypeScript 拷进 `lib/`。

不能把 `lib/density/solver/buoyancy_world.dart` 当成这份 common 的已完成移植。那个 solver 是 Density 的简化步进，注释写明 pointer spring，不是 p2 `RevoluteConstraint`。

SHA 不一致是 P1，不是“源码缺失”。buoyancy Screen 引用的类在当前 common 里都存在：

- `BuoyancyCompareModel` / `BuoyancyCompareScreenView`
- `BuoyancyExploreModel` / `BuoyancyExploreScreenView`
- `BuoyancyLabModel` / `BuoyancyLabScreenView` / `getLabScreenIcon`
- `BuoyancyShapesModel` / `BuoyancyShapesScreenView`
- `BuoyancyApplicationsModel` / `BuoyancyApplicationsScreenView`
- `DensityBuoyancyCommonCredits` / `PreferencesNode` / `Colors` / `KeyboardHelpNode` / `DensityBuoyancyScreenView`

PHASE 1 之前不要把 common 切到 lockfile SHA，也不要再 `git pull`。当前审计对象就是这份工作树。
