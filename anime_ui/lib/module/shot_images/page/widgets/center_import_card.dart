import 'package:flutter/material.dart';

import 'package:anime_ui/pub/widgets/generation_center/import_card_placeholder.dart';

/// 镜图导入卡片
class CenterImportCard extends StatelessWidget {
  const CenterImportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImportCardPlaceholder(
      title: '导入镜图',
      placeholderLabel: '拖拽或点击上传图片',
      hintText: '支持 PNG/JPG/ZIP 批量导入',
      infoText: '按文件名自动匹配镜头编号\n如: S01-001.png → 镜头1',
    );
  }
}
