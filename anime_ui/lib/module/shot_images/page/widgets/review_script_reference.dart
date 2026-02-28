import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/theme/text.dart';

/// 镜图审核 - 脚本对照区域
class ReviewScriptReference extends StatelessWidget {
  final StoryboardShot shot;

  const ReviewScriptReference({super.key, required this.shot});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(AppIcons.document, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  '脚本对照',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _refField('画面描述', shot.prompt),
                const SizedBox(height: 8),
                _refField('风格提示', shot.stylePrompt),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _cameraChip('景别', shot.cameraType ?? ''),
                    _cameraChip('运镜', shot.cameraAngle ?? ''),
                    _durationChip('时长', '${shot.duration}s'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _refField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontSize: 13,
            color: value.isNotEmpty ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _cameraChip(String label, String value) {
    final chipColor = label == '景别'
        ? AppColors.primary
        : (label == '运镜' ? const Color(0xFF6366F1) : Colors.grey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: chipColor.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontSize: 12,
              color: value.isNotEmpty ? chipColor : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _durationChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
