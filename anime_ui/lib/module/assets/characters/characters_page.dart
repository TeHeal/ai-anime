import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 角色页（待迁移完整实现：列表、详情、AI 提取、形象生成等）
class AssetsCharactersPage extends StatelessWidget {
  const AssetsCharactersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('角色页', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('待迁移完整实现', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
