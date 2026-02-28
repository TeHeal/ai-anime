import 'package:flutter/material.dart';

import '../image_gen_controller.dart';

/// 当前生成模式只读标签（底部状态栏）
class ModeBadge extends StatelessWidget {
  const ModeBadge({
    super.key,
    required this.mode,
    required this.accent,
  });

  final ImageGenMode mode;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome_rounded, size: 12, color: accent.withValues(alpha: 0.7)),
        const SizedBox(width: 5),
        Text(
          '当前模式：',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        Text(
          mode.label,
          style: TextStyle(
            fontSize: 11,
            color: accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
