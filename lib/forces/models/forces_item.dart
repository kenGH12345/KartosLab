import 'package:flutter/material.dart';

/// 可推动物品的定义（冰箱/板条箱/人/垃圾桶/神秘物体/水桶）
class ForceItem {
  const ForceItem({
    required this.id,
    required this.name,
    required this.mass,
    required this.icon,
    required this.color,
    this.isHuman = false,
    this.massKnown = true,
    this.side = ItemSide.right,
  });

  final String id;
  final String name;
  final double mass;       // kg
  final IconData icon;
  final Color color;
  final bool isHuman;
  final bool massKnown;    // 神秘物体隐藏质量
  final ItemSide side;     // 物品来源工具箱侧

  static const double humanMass = 40;
  static const double maxStack = 3;
}

enum ItemSide { left, right }

/// 预设物品清单
const kForceItems = [
  ForceItem(id: 'fridge', name: '冰箱', mass: 200, icon: Icons.kitchen, color: Color(0xFF9CA3AF), side: ItemSide.left),
  ForceItem(id: 'crate1', name: '板条箱1', mass: 50, icon: Icons.inventory_2, color: Color(0xFFD97706), side: ItemSide.left),
  ForceItem(id: 'crate2', name: '板条箱2', mass: 50, icon: Icons.inventory_2, color: Color(0xFFB45309), side: ItemSide.left),
  ForceItem(id: 'girl', name: '女孩', mass: 40, icon: Icons.face_3, color: Color(0xFFEC4899), isHuman: true, side: ItemSide.right),
  ForceItem(id: 'man', name: '成年男性', mass: 80, icon: Icons.face, color: Color(0xFF3B82F6), isHuman: true, side: ItemSide.right),
  ForceItem(id: 'trash', name: '垃圾桶', mass: 100, icon: Icons.delete, color: Color(0xFF6B7280), side: ItemSide.right),
  ForceItem(id: 'mystery', name: '神秘物体', mass: 50, icon: Icons.help_outline, color: Color(0xFF7C3AED), massKnown: false, side: ItemSide.right),
  ForceItem(id: 'bucket', name: '水桶', mass: 100, icon: Icons.water_drop, color: Color(0xFF06B6D4), side: ItemSide.right),
];
