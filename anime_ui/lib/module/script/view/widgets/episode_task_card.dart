import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';

/// 单集脚本生成任务卡片
class EpisodeTaskCard extends StatelessWidget {
  final int episodeId;
  final String title;
  final int sortIndex;
  final EpisodeGenerateState? state;
  final bool isSelected;
  final ValueChanged<bool> onSelectChanged;
  final VoidCallback onGenerate;
  final VoidCallback onReview;

  const EpisodeTaskCard({
    super.key,
    required this.episodeId,
    required this.title,
    required this.sortIndex,
    this.state,
    required this.isSelected,
    required this.onSelectChanged,
    required this.onGenerate,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final status = state?.status ?? EpisodeScriptStatus.notStarted;
    final progress = state?.progress ?? 0;
    final shotCount = state?.shotCount ?? 0;

    Color accentColor;
    IconData statusIcon;
    String statusText;
    switch (status) {
      case EpisodeScriptStatus.completed:
        accentColor = Colors.green;
        statusIcon = AppIcons.check;
        statusText = '已完成';
      case EpisodeScriptStatus.generating:
        accentColor = AppColors.primary;
        statusIcon = AppIcons.sync;
        statusText = '生成中';
      case EpisodeScriptStatus.failed:
        accentColor = Colors.red;
        statusIcon = AppIcons.error;
        statusText = '失败';
      case EpisodeScriptStatus.notStarted:
        accentColor = Colors.grey;
        statusIcon = AppIcons.circleOutline;
        statusText = '待生成';
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelectChanged(!isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : const Color(0xFF16162A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : const Color(0xFF2A2A40),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：标题 + 选中指示
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${sortIndex + 1}',
                        style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Icon(
                    isSelected
                        ? AppIcons.checkOutline
                        : AppIcons.circleOutline,
                    size: 16,
                    color: isSelected ? AppColors.primary : Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[800]!.withValues(alpha: 0.5),
                  color: accentColor,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 10),

              // 底部：状态 + 操作
              Row(
                children: [
                  Icon(statusIcon, size: 13, color: accentColor),
                  const SizedBox(width: 5),
                  Text(statusText,
                      style: TextStyle(
                          fontSize: 11,
                          color: accentColor,
                          fontWeight: FontWeight.w600)),
                  if (status == EpisodeScriptStatus.completed) ...[
                    const SizedBox(width: 8),
                    Text('$shotCount 镜头',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                  if (status == EpisodeScriptStatus.generating) ...[
                    const SizedBox(width: 8),
                    Text('$progress%',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                  const Spacer(),
                  _buildAction(status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(EpisodeScriptStatus status) {
    switch (status) {
      case EpisodeScriptStatus.completed:
        return MiniActionButton(
          label: '审核',
          icon: AppIcons.arrowForward,
          color: Colors.green,
          onTap: onReview,
        );
      case EpisodeScriptStatus.generating:
        return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2));
      case EpisodeScriptStatus.failed:
        return MiniActionButton(
          label: '重试',
          icon: AppIcons.refresh,
          color: Colors.orange,
          onTap: onGenerate,
        );
      case EpisodeScriptStatus.notStarted:
        return MiniActionButton(
          label: '生成',
          icon: AppIcons.magicStick,
          color: AppColors.primary,
          onTap: onGenerate,
        );
    }
  }
}
