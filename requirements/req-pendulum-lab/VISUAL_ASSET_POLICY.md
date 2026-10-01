# 原版 Assets 与视觉一致性（Pendulum Lab）

遵循仓库规则 `85-phet-original-assets.mdc`。

优先级：原 PhET Asset → 原 SVG/PNG/Mipmap → 原 Scenery geometry → Flutter Canvas 等价重建。

本 sim 运行时位图仅 `mipmaps/` 6 张。摆、量角器、尺、能量柱、chrome **全部为源码 Path/Shape**，必须 Canvas 重建，禁止近似图标替代。
