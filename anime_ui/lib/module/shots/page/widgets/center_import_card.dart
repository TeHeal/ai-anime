import 'package:flutter/material.dart';

import 'package:anime_ui/pub/widgets/generation_center/import_card_placeholder.dart';

/// 导入卡片：上传视频/音频
class CenterImportCard extends StatelessWidget {
  const CenterImportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImportCardPlaceholder(
      title: '导入',
      placeholderLabel: '上传视频/音频',
    );
  }
}
