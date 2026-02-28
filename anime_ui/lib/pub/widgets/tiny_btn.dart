import 'package:flutter/material.dart';

/// 紧凑型文字按钮，适合放在标签行右侧作为辅助操作。
class TinyBtn extends StatelessWidget {
  const TinyBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 12, color: accent),
      label: Text(label, style: TextStyle(fontSize: 11, color: accent)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
