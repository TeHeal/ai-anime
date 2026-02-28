import 'package:flutter/material.dart';

import 'package:anime_ui/module/shots/page/provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';

/// 单个复合生成任务卡片，展示子任务状态矩阵
class CompositeTaskCard extends StatelessWidget {
  final String shotId;
  final int shotNumber;
  final String cameraScale;
  final String prompt;
  final String imageUrl;
  final CompositeShotStatus status;
  final int completedSubtasks;
  final int totalSubtasks;
  final Map<String, SubtaskState> subtasks;
  final bool isSelected;
  final String viewMode;
  final ValueChanged<bool> onSelectChanged;
  final VoidCallback onGenerate;

  const CompositeTaskCard({
    super.key,
    required this.shotId,
    required this.shotNumber,
    this.cameraScale = '',
    this.prompt = '',
    this.imageUrl = '',
    required this.status,
    this.completedSubtasks = 0,
    this.totalSubtasks = 0,
    this.subtasks = const {},
    required this.isSelected,
    this.viewMode = 'standard',
    required this.onSelectChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent =
        totalSubtasks > 0 ? completedSubtasks / totalSubtasks : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelectChanged(!isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (viewMode != 'compact') ...[
                const SizedBox(height: 10),
                if (imageUrl.isNotEmpty) _buildThumbnail(),
                const SizedBox(height: 10),
                _buildSubtaskMatrix(),
              ],
              const SizedBox(height: 8),
              _buildProgressBar(progressPercent),
              const SizedBox(height: 6),
              _buildStatusRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text('$shotNumber',
                style: TextStyle(
                    fontSize: 11,
                    color: _statusColor,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'S${shotNumber.toString().padLeft(2, '0')}${cameraScale.isNotEmpty ? ' · $cameraScale' : ''}',
            style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          isSelected ? AppIcons.checkOutline : AppIcons.circleOutline,
          size: 15,
          color: isSelected ? AppColors.primary : Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, e, s) =>
                Container(color: AppColors.surfaceContainerHighest)),
      ),
    );
  }

  Widget _buildSubtaskMatrix() {
    const types = [
      ('🎬', 'video'),
      ('🎤', 'vo'),
      ('🎵', 'bgm'),
      ('🔊', 'foley'),
      ('👄', 'lip_sync'),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: types
          .where((t) => subtasks.containsKey(t.$2))
          .map((t) => _subtaskChip(t.$1, subtasks[t.$2]!))
          .toList(),
    );
  }

  Widget _subtaskChip(String emoji, SubtaskState st) {
    Color color;
    String suffix;
    if (st.isComplete) {
      color = Colors.green;
      suffix = '✅';
    } else if (st.isRunning) {
      color = AppColors.primary;
      suffix = '${st.progress}%';
    } else if (st.isFailed) {
      color = Colors.red;
      suffix = '❌';
    } else if (st.isWaiting) {
      color = Colors.amber;
      suffix = '⏳';
    } else {
      color = Colors.grey;
      suffix = '○';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$emoji $suffix',
          style: TextStyle(fontSize: 10, color: color)),
    );
  }

  Widget _buildProgressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.grey[800]!.withValues(alpha: 0.5),
        color: _statusColor,
        minHeight: 4,
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Text(
          '$completedSubtasks/$totalSubtasks',
          style: TextStyle(
              fontSize: 11,
              color: _statusColor,
              fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (status == CompositeShotStatus.notStarted)
          MiniActionButton(
              label: '生成',
              icon: AppIcons.magicStick,
              color: AppColors.primary,
              onTap: onGenerate),
        if (status == CompositeShotStatus.failed)
          MiniActionButton(
              label: '重试',
              icon: AppIcons.refresh,
              color: Colors.orange,
              onTap: onGenerate),
        if (status == CompositeShotStatus.generating)
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
      ],
    );
  }

  Color get _statusColor => switch (status) {
        CompositeShotStatus.notStarted => Colors.grey,
        CompositeShotStatus.generating => AppColors.primary,
        CompositeShotStatus.partialComplete => Colors.blue,
        CompositeShotStatus.completed => Colors.green,
        CompositeShotStatus.failed => Colors.red,
      };
}
