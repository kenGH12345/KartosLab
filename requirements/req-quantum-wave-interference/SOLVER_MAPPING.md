# SOLVER_MAPPING — Phase 1

| PhET | Flutter | Evidence | Test |
|---|---|---|---|
| `DetectorPattern.getExactDetectorIntensity` | `FraunhoferSolver.getExactDetectorIntensity` | `DetectorPattern.ts` sinc² + cos² | `core_numerics_test` Fraunhofer group |
| `sincSquared` = (sin x / x)² | `FraunhoferSolver.sincSquared` | same file | sincSquared limits |
| `WaveKernel.evaluateSample` | `evaluateSample` | `WaveKernel.ts` | WaveKernel / Fresnel group |
| `WavePropagation.evaluateUndecoheredSample` | `evaluateUndecoheredSample` | `WavePropagation.ts` | noBarrier / double / single slit |
| `getFresnelApertureTransfer` | `getFresnelApertureTransfer` | `FresnelApertureTransfer.ts` incl. 0.57 scale | via WaveKernel tests |
| `FieldSampleMath.computeSampleIntensity` | `computeSampleIntensity` | group then \|sum\|² | Coherence groups |
| `WaveDecoherence.applyDecoherenceEvent` | `applyDecoherenceEvent` | packet + plane chains | which-path test |
| `getGaussianPacketState` | `getGaussianPacketState` | σ√(1+(t/τ)²), chirp | Gaussian packet state |
| `inverseStandardNormalCDF` | `inverseStandardNormalCdf` | Acklam | inverseStandardNormalCdf |
| `SceneModel.generateHitPosition` rejection | `ExperimentHitSampler` | max 1000 iters | seeded hits |
| `BaseSceneModel.generateHitPosition` roulette | `WaveRegionHitSampler` | y∈[0,1] | wave region hit |
| `HighIntensitySolver` time average | `HighIntensityWaveSolver` | accumulator / count | emitting PDF |
| `SingleParticleSolver` + timing | `SingleParticleWaveSolver` + scene | weight + invCDF | emit/detect |
| `computeDetectorProbability` | `ProbeSolver.computeProbability` | grid \|ψ\|² ratio | probe tests |
| `TimeSpeed` factors | `TimeSpeedFactors` | Exp/HI/SP tables | clock tests |
| `stepOnce` = 1/60 no speed | `SimulationClock.stepOnce` | `BaseScreenModel` | stepOnce ignores TimeSpeed |