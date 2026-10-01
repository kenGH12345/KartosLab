# SPIN_EXPERIMENT_CONFIG_PHASE5

Derived via `SpinExperimentViewConfiguration.fromModel(SpinModel)`.

| Experiment | Shared Apparatus | Orientation | Visible Nodes | Axis | Special Behavior |
| --- | --- | --- | --- | --- | --- |
| 1 | Source+SG0 (+MD single) | SG0 Z | SG1/2 off | SGz | single apparatus |
| 2 | same | SG0 X | SG1/2 off | SGx | single apparatus |
| 3 | Source+SG0–2 | Z,X,X | SG1/2 unless blocked | SGz→SGx | multi; Block Up/Down in continuous |
| 4 | same | Z,Z,Z | same | SGz cascade | multi |
| 5 | same | X,Z,Z | same | SGx→SGz | multi |
| 6 | same | X,X,X | same | SGx cascade | multi |
| Custom | same | default X,Z,Z | same + axis radios | user | `isDirectionControllable` |

## Field mapping

```
experimentId ← SpinExperiment
axis ← sternGerlachs[i].isZOriented
inputState ← spinState / customSpinState / alphaSquared
apparatusConfiguration ← experimentSetting
visibleNodes ← showSg* / showMd* (from sourceMode + blocking)
orientation ← isZOriented labels SGz/SGx
blockingConfiguration ← sternGerlachs[0].blockingMode (+ map memory)
singleContinuousMode ← sourceMode
```
