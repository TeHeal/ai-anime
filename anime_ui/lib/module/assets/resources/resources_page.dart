import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 素材库页（待迁移完整实现：模态切换、侧边导航、内容区等）
class AssetsResourcesPage extends StatelessWidget {
  const AssetsResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.gallery, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('素材库', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('待迁移完整实现', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
