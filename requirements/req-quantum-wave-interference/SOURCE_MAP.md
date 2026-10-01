# SOURCE_MAP — Quantum Wave Interference

Local root: `phet sourses/quantum-wave-interference-main/quantum-wave-interference-main`  
Version: `1.0.0-dev.5` · Lock SHA: `d9ee906473cf4ae2ece4f18b65f715e46249dd86`

> 每行说明**职责**，不是文件名清单。Flutter Mapping 为 PHASE 1+ 目标模块名（尚未实现）。

| PhET Source | Class / Symbol | Responsibility | Flutter Mapping | Risk |
|---|---|---|---|---|
| `js/quantum-wave-interference-main.ts` | `simLauncher.launch` | Joist 入口；注册 Experiment → High Intensity → Single Particles | `QuantumWaveInterferenceApp` / sim registry | L |
| `js/quantumWaveInterference.ts` | namespace | PhET namespace 导出 | n/a | L |
| `js/experiment/ExperimentScreen.ts` | `ExperimentScreen` | Experiment Joist Screen 壳 | `ExperimentScreen` | L |
| `js/experiment/model/ExperimentModel.ts` | `ExperimentModel` | 独立 TModel：4× SceneModel、TimeSpeed、ruler、zoom、playback；**无 WaveSolver** | `ExperimentModel` | M |
| `js/experiment/model/SceneModel.ts` | `SceneModel` | 每粒子源场景：波长/速度/缝距/强度、闭式强度、rejection hits、snapshots | `ExperimentSceneModel` | H |
| `js/experiment/ExperimentConstants.ts` | constants | 俯视/正视布局尺寸、探测器缩放档位 | `ExperimentLayoutConstants` | M |
| `js/common/model/DetectorPattern.ts` | `getExactDetectorIntensity` 等 | Fraunhofer 单缝 envelope + 双缝 cos²；which-path → 仅 envelope | `FraunhoferDetectorPattern` | H |
| `js/high-intensity/HighIntensityScreen.ts` | `HighIntensityScreen` | HI Screen 壳 | `HighIntensityScreen` | L |
| `js/high-intensity/model/HighIntensityModel.ts` | `HighIntensityModel` | extends BaseScreenModel；TimeSpeed 0.15/0.35/0.65 | `HighIntensityModel` | M |
| `js/high-intensity/model/HighIntensitySceneModel.ts` | `HighIntensitySceneModel` | 连续波场景：detectionMode、hit rate 40/s、pattern formation、decoherence 调度 | `HighIntensitySceneModel` | H |
| `js/high-intensity/model/HighIntensitySolver.ts` | `HighIntensitySolver` | 平面波 solver 适配器；detector 时间平均；DISPLAY_TRAVERSAL_TIME=2.0 | `HighIntensityWaveSolver` | H |
| `js/single-particles/SingleParticlesScreen.ts` | `SingleParticlesScreen` | SP Screen 壳 | `SingleParticlesScreen` | L |
| `js/single-particles/model/SingleParticlesModel.ts` | `SingleParticlesModel` | extends BaseScreenModel；TimeSpeed 0.15/0.7/16；autoRepeat DynamicProperty | `SingleParticlesModel` | H |
| `js/single-particles/model/SingleParticlesSceneModel.ts` | `SingleParticlesSceneModel` | 单包发射、检测时刻采样、which-path re-emission、probe 测量 | `SingleParticlesSceneModel` | **Critical** |
| `js/single-particles/model/SingleParticleSolver.ts` | `SingleParticleSolver` | 高斯波包 solver 适配器；measurement projections | `SingleParticleWaveSolver` | **Critical** |
| `js/single-particles/model/DetectorProbe.ts` | `DetectorProbe` | 圆形探针：position/radius/state/probability | `DetectorProbeModel` | H |
| `js/single-particles/model/CurrentDetectorProbe.ts` | `CurrentDetectorProbe` | 仅 `noBarrier` 可用；可见性 | `CurrentDetectorProbe` | M |
| `js/common/model/BaseScreenModel.ts` | `BaseScreenModel` | HI/SP 共享：4 scenes、playback、TimeSpeed、测量工具、step/stepOnce | `WaveRegionScreenModel` | M |
| `js/common/model/BaseSceneModel.ts` | `BaseSceneModel` | 每源场景：质量/速度/λ、barrier、hits、snapshots、PDF hit sample、decoherence records | `WaveRegionSceneModel` | H |
| `js/common/model/BaseWaveSolver.ts` | `BaseWaveSolver` | 网格缓存、time、getDetectorProbabilityDistribution、setParameters | `BaseWaveSolver` | H |
| `js/common/model/WaveSolver.ts` | `WaveSolver` interface | step/evaluate/field sample/detector PDF/measurement projection/state | `WaveSolver` (interface) | H |
| `js/common/model/WaveKernel.ts` | `evaluateSample` / `evaluateSamples` | **纯函数**场采样入口；decoherence + measurement 叠加 | `WaveKernel` | **Critical** |
| `js/common/model/WavePropagation.ts` | `evaluateUndecoheredSample` 等 | 无势/双缝传播；plane + Gaussian + Fresnel aperture | `WavePropagation` | **Critical** |
| `js/common/model/FresnelApertureTransfer.ts` | `getFresnelApertureTransfer` | 缝后 Fresnel 孔径传递函数 | `FresnelApertureTransfer` | H |
| `js/common/model/WaveDecoherence.ts` | `applyDecoherenceEvent` 等 | which-path 去相干层/衰减 | `WaveDecoherence` | H |
| `js/common/model/WaveMeasurementProjection.ts` | projections | 探针失败测量后的概率 bite + 重整化 | `WaveMeasurementProjection` | H |
| `js/common/model/WaveMath.ts` / `FieldSampleMath.ts` | helpers | Complex helpers；`sum \|group\|^2` intensity | `WaveMath` | M |
| `js/common/model/WaveKernelTypes.ts` | types | FieldSample / LayeredFieldSample / WaveParameters | `wave_kernel_types.dart` | M |
| `js/common/model/SlitConfiguration.ts` | enums + helpers | bothOpen / covered / detectors / noBarrier；left↔top 映射 | `SlitConfiguration` | M |
| `js/common/model/BarrierType.ts` | `none` \| `doubleSlit` | HI/SP 屏障类型 | `BarrierType` | L |
| `js/common/model/SourceType.ts` | 4 source types | photons/electrons/neutrons/heliumAtoms | `SourceType` | L |
| `js/common/model/DetectionMode.ts` | `intensity` \| `hits` | 探测器显示模式（SP 固定 hits） | `DetectionMode` | L |
| `js/common/model/Snapshot.ts` | `Snapshot` / `renumberSnapshots` | 每场景最多 4 张；hits 或 intensityDistribution | `SnapshotRecord` | M |
| `js/common/model/TimeSpeedProperty.ts` | `TimeSpeedProperty` | SLOW/NORMAL/FAST，默认 NORMAL | `TimeSpeed` + property | L |
| `js/common/model/inverseStandardNormalCDF.ts` | Acklam approx | 波包检测时刻采样 | `InverseStandardNormalCdf` | M |
| `js/common/QuantumWaveInterferenceConstants.ts` | constants | h、质量、packet 参数、MAX_HITS=25000、布局 | `QwiConstants` | M |
| `js/common/view/WaveRasterizer.ts` | rasterizer | FieldSample → RGBA；光子 VisibleColor；物质灰 | `WaveRasterizer` | H |
| `js/common/view/WaveVisualizationCanvasNode.ts` | canvas | 120² 网格 → 420×385 区域 | `WaveFieldPainter` | H |
| `js/common/view/DetectorScreenTextureRenderer.ts` | texture | HI/SP 倾斜探测器；hits 增量戳印 MAX 10000 | `DetectorScreenRenderer` | H |
| `js/common/view/renderDetectorScreenTexture.ts` | shared render | Experiment 共用纹理渲染 | shared renderer | M |
| `js/common/view/DetectorPatternGraphNode.ts` | graph | 转置 intensity 曲线 / 100-bin hits 直方图 | `DetectorGraphPainter` | M |
| `js/experiment/view/GraphAccordionBox.ts` | accordion graph | Experiment 强度曲线 / hits 直方图 | `ExperimentGraph` | M |
| `js/experiment/view/DetectorRulerNode.ts` | ruler | mm 尺；仅视觉缩放，不改物理 | `DetectorRuler` | M |
| `js/common/view/MeasurementToolsLayerNode.ts` | tools | Measuring tape / stopwatch / time & position plots | `MeasurementToolsLayer` | M |
| `js/common/view/Snapshot*.ts` | snapshot UI | 拍照、闪光、对话框、删除重编号 | `SnapshotController` + UI | M |
| `js/single-particles/view/DetectorProbeNode.ts` | probe view | 拖拽圆 + Detect/Reset + Size | `DetectorProbeView` | H |
| `js/common/view/WavelengthColorUtils.ts` | color zones | 380–700 nm → violet…red（a11y/标签）；渲染色走 VisibleColor | `WavelengthColorZones` | L |
| `js/common/view/QuantumWaveInterferenceKeyboardHelpContent.ts` | keyboard help | **仅**通用 PhET sections，无自定义快捷键表 | reuse KartosLab keyboard help | L |
| `doc/model.md` | learning design | 教学模型说明；**部分数值已落后源码** | reference only | M |
| `doc/implementation-notes.md` | maintainer map | 架构地图；Analytical* 文件名已重命名为 Wave* | reference only | L |