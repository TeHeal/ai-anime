import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 脚本 - 锁定页（Tab 4）
/// v2 TODO: 恢复按集锁定功能
class ScriptFreezePage extends ConsumerWidget {
  const ScriptFreezePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.lock, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            '脚本锁定功能暂未启用',
            style: TextStyle(fontSize: 18, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            '此功能将在第二版中上线，届时支持按集锁定',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
