import 'package:flutter/material.dart';

/// 资产状态芯片
class AssetStatusChip extends StatelessWidget {
  const AssetStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 10,
  });

  final String label;
  final Color color;
  final double fontSize;

  factory AssetStatusChip.fromStatus(String status) {
    switch (status) {
      case 'confirmed':
        return const AssetStatusChip(
            label: '已确认', color: Color(0xFF22C55E));
      case 'skeleton':
        return const AssetStatusChip(
            label: '骨架', color: Color(0xFFF97316));
      case 'draft':
        return const AssetStatusChip(
            label: '草稿', color: Color(0xFF3B82F6));
      default:
        return AssetStatusChip(
            label: status, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
