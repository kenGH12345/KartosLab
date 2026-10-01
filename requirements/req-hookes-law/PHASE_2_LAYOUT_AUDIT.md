# PHASE 2 — LAYOUT AUDIT · Hooke's Law Intro

> 在写 Intro UI 之前确认 viewport。依据是本地 TypeScript，以及与 `dependencies.json` 钉死的依赖 SHA。  
> 日期：2026-09-20

## 结论

Intro 的布局坐标系是 joist `ScreenView` 的默认 **1024 × 618**。  
`IntroScreenView` 没有覆写 `layoutBounds`。

不要用 Home 的 768 × 504 当 Intro 的舞台。  
本阶段不画导航栏，也不接 Home。

## 1. 依赖

| 项 | 值 |
|---|---|
| joist SHA | `bb6a94e05e03c82aa75dfb9717459e5be07a4507` |
| 来源 | `js/ScreenView.ts`（jsDelivr，该 SHA） |
| scenery-phet SHA | `5a91ec98da7266d76e9f6062d8acbb1e985ce3de` |
| 弹簧 | `ParametricSpringNode`（prolate cycloid，不是贴图） |

`ScreenView.ts`：

```text
static readonly DEFAULT_LAYOUT_BOUNDS = new Bounds2(0, 0, 1024, 618);
```

`IntroScreenView` 只把 `tandem` 传给 `super`，因此用这份默认值。

## 2. Viewport 与 letterbox

`ScreenView.getLayoutScale`：

```text
scale = min(viewWidth / 1024, viewHeight / 618)
```

`getLayoutMatrix` 用这个**均匀**缩放，再把舞台在窗口里水平、垂直居中。  
x 与 y 不分开拉伸，所以 1 m = 225 layout px 在两个方向上保持各向同性。

窗口比 1024×618 更宽或更高时，多出来的是 letterbox，不是舞台的一部分。

## 3. 导航栏（本阶段不画）

`NavigationBar.NAVIGATION_BAR_SIZE`：

```text
Dimension2(HomeScreenView.LAYOUT_BOUNDS.width, 40)
                 = Dimension2(768, 40)
```

`Sim.ts` 把导航栏放在 ScreenView **外面**：

```text
navBarHeight = scale * 40
screen 区域高度 = windowHeight - navBarHeight
```

Intro 里所有 `layoutBounds.centerY`、`0.25 * height`、`right - 10` 都是相对 **1024×618**，不是相对「扣掉导航栏之后的像素」。  
导航栏是切屏 chrome。本阶段禁止 Systems / Energy / Home，所以 Flutter 不画这 40 px 的栏，也不留一个假的底栏。

## 4. 舞台分区（layout px）

原点在舞台左上，**y 向下**，与 scenery 一致。

| 区域 | 位置 |
|---|---|
| layoutBounds | x 0–1024，y 0–618 |
| 右上控件列 | `right = 1024 - 10`，`top = 10`，VBox spacing 10 |
| 控件列内容（自上而下） | Visibility panel，然后 1 / 2 系统单选 |
| 系统列左缘 | `left = 15`（节点 bounds 的左边，不是弹簧原点） |
| Reset All | `right = 1024 - 15`，`bottom = 618 - 15`，半径 20.5 |
| 单系统时 system1 | `centerY = 309` |
| 双系统时 system1 | `centerY = 0 + 0.25 * 618 = 154.5` |
| system2 | `centerY = 0.75 * 618 = 463.5`（始终） |

源码变量名 `system1CenterXForTwoSystems` 实际赋的是 **centerY**。按赋值语义，不按变量名。

`IntroScreenView` 断言每个系统节点高度 ≤ `618 / 2 = 309`。  
Flutter 系统列高度是 `introSystemHeight`（墙 170 + 间距 10 + 控件块 118 = 298），小于 309，满足该断言。

## 5. 系统节点局部坐标

`IntroSystemNode` 的局部原点是弹簧左端 / 墙的右中点。

| 对象 | 局部位置 |
|---|---|
| 墙 | 25×170，圆角 6，`right = 0`，`centerY = 0` |
| 弹簧 | `x = 0`，`y = 0`（线圈左中点） |
| 机械臂节点 | `x = 225 * arm.right`，`y = 0`。臂的局部原点在右侧红盒左中点 |
| 手 | `x = 225 * (arm.left - arm.right)`（相对臂节点） |
| 平衡线 | `centerX = 225 * equilibriumX`，`centerY = 0`，长度 = 墙高 |
| 施力 / 弹力箭头 | `x = 225 * spring.right`，节点 bottom = 弹簧 y − 50 |
| 位移箭头 | `x = 225 * equilibriumX`，节点 top = 弹簧 y + 50 |
| 弹簧控件 | `top = wall.bottom + 10`，水平居中于墙左缘到臂右缘 |

默认（左端锁在 0，平衡长度 1.5 m）：

- `equilibriumX = 1.5`
- `arm.right = 3.0`（构造时 `spring.right + length`，之后固定）
- 平衡位置是**固定参考**，不跟手移动

屏幕上：系统列的 x = 0 对齐墙的左缘，所以弹簧原点（墙的右缘）在列内 x = 25，舞台 x = 15 + 25 = 40。

## 6. Model → view

一维，没有 `ModelViewTransform2`。

| 量 | 比例 | 用在 |
|---|---|---|
| 位移 | 1 m = 225 px | 弹簧、臂、位移箭头、平衡线 |
| 力（Intro 场景） | 1 N = 1.45 px | 施力箭头、弹力箭头 |
| 力（Energy 图） | 1 N = 0.25 px（y） | **Intro 不用** |
| Energy 场景力箭头 | 1 N = 0.4 px | **Intro 不用** |

+x 向右。力 > 0 时施力箭头向右，弹力箭头向左（`springForce = -F`）。  
y 只用于把对象摆到弹簧轴的上/下，模型本身没有 y。

## 7. 绘制顺序

`IntroScreenView` 子节点（先画在下）：

1. 右上控件
2. system 1
3. system 2
4. Reset All

`IntroSystemNode` 子节点（先画在下）：

1. 平衡线
2. 机械臂（含手）
3. 弹簧
4. 墙
5. nib
6. 施力箭头
7. 弹力箭头
8. 位移箭头
9. 弹簧控件（k 与 F，横向并排）

## 8. 动画用的是 centerY，不是弹簧轴

`IntroAnimator` 移动的是**整个系统节点的 bounds.centerY**。  
默认不可见的箭头不计入 scenery bounds。复选框后来打开时，源码不会重新居中，弹簧轴保持不动。  
Flutter 用「墙 + 控件」这一固定高度做 centerY，箭头画在这个盒子外面（不裁剪），避免勾选时整列跳动。
