import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';

/// 导入卡片：上传视频/音频
class CenterImportCard extends StatelessWidget {
  const CenterImportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.teal.withValues(alpha: 0.25),
                    Colors.teal.withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(AppIcons.upload,
                    size: 18, color: Colors.tealAccent),
              ),
              const SizedBox(width: 12),
              const Text('导入',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('导入功能开发中'),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF16162A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey[700]!.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Icon(AppIcons.uploadOutline,
                      size: 20, color: Colors.tealAccent),
                  const SizedBox(height: 8),
                  Text('上传视频/音频',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
