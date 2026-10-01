# Bending Light — 视口与棱镜拖动收口

本轮只收用户在 Home 接入之后指出的页面问题：三页要铺满窗口、字要清楚、Prisms 底栏棱镜要能拖出去再拖回来，并且按住看得见的形状就能拖。物理、Reset All、Home 入口没有重开。

判定依据仍是本地 source `1.3.0-dev.0`。官方 1.2.5 画面只作对照，不拿来改公式。

## 1. 本轮做了什么

- 舞台不再居中留边。`834×504` 的布局框还在，窗口按各自轴向铺满：`scaleX = viewWidth / 834`，`scaleY = viewHeight / 504`。字形和控件仍用两轴里较小的那个，避免被拉扁。
- 字在显示尺寸上排版，不再把整页先画小再拉伸。这是上一轮字发糊的原因，没有改回 `FittedBox` 或整页 `canvas.scale`。
- Prisms 底栏是横条。图标按原版 `createForwardingListener`：按下就复制一枚棱镜，浮在栏表面上跟着手指；松手时轮廓还压在栏上就收回，拖出栏才留下。同一种最多 6 个，没拿光之前图标还在，槽位不缩。
- 已放下的棱镜，可拖范围改成画出来的路径，不再用模型 `containsPoint`。半圆原先要点直径外侧的空白才能拖，现在按住紫色本体即可。圆形棱镜仍无旋钮。

## 2. 没有改的

- Intro 标量 Snell、Prisms 矢量 Snell、TIR、Fresnel、dispersion、白光、波、传感器、时间步长、Reset All（`KratosResetAllButton`，半径 19）。
- Home 卡片、三个标签、demo 的 `?qa=` 路由。
- 折射率滑条、波长滑条、介质选择、+/-、面板壳。这些上一轮已经对齐，本轮没有再调。

## 3. 测试

- `dart analyze lib/bending_light`：clean
- `flutter test test/bending_light/`：**161 passed**（没有删测试，也没有改期望）

本轮没有重新跑全库 `flutter test`，也没有重编 APK。全库里其他 sim 的超时、以及 `Android runtime NOT VERIFIED`，维持 Home 接入报告里的结论。

## 4. 还留着的

- 半圆的**画面**和**光线求交**仍可能不在直径的同一侧。拖动跟画面走；求交仍按 `SemiCircle.ts` 的弧。这是已知残留，本轮按用户要求只改了可拖范围。
- sun 滑条渐变、下拉高光、箭头倒角、圆形按钮倒角、官方 joist 导航条：仍是 VERSION_DELTA，本地 1.3.0 source 里没有的不补画。
- 本轮没有新的对照截图。页面要热重启后才能看到铺满和拖动。

## 5. 状态

# SLICE CLOSED

视口铺满、底栏拖出/拖回、按可见形状拖动，这三件收口。不改变先前的 READY / HOME INTEGRATION PASS，也不把 Android 标成已验证。
