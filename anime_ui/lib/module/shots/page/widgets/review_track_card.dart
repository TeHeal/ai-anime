import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/review_layout/qa_checklist.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';

/// 分轨审核卡片：展示一条轨道的 QA 检查项和操作按钮
class ReviewTrackCard extends StatelessWidget {
  final String title;
  final int score;
  final List<QACheckItem> items;
  final String trackType;
  final ValueChanged<String>? onAction;

  const ReviewTrackCard({
    super.key,
    required this.title,
    required this.score,
    required this.items,
    required this.trackType,
    this.onAction,
  });

  void _notify(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

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
          _buildHeader(),
          Divider(height: 1, color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final item in items) _qaItem(item),
                const SizedBox(height: 10),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final color = score >= 80
        ? Colors.green
        : (score >= 60 ? Colors.orange : Colors.red);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const Spacer(),
          Text('$score',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _qaItem(QACheckItem item) {
    final color = item.score >= 80
        ? Colors.green
        : (item.score >= 60 ? Colors.orange : Colors.red);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            item.score >= 80
                ? AppIcons.check
                : (item.score >= 60 ? AppIcons.warning : AppIcons.error),
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(item.name,
                style: TextStyle(fontSize: 12, color: Colors.grey[300])),
          ),
          Text('${item.score}',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 8),
          if (item.feedback.isNotEmpty)
            Expanded(
              child: Text(item.feedback,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        MiniActionButton(
            label: '通过',
            icon: AppIcons.check,
            color: Colors.green,
            onTap: () {
              onAction?.call('approve');
              _notify(context, '$title 已通过');
            }),
        const SizedBox(width: 8),
        MiniActionButton(
            label: '需调整',
            icon: AppIcons.warning,
            color: Colors.orange,
            onTap: () {
              onAction?.call('revise');
              _notify(context, '$title 标记需调整');
            }),
        const SizedBox(width: 8),
        MiniActionButton(
            label: '重跑$trackType',
            icon: AppIcons.refresh,
            color: AppColors.primary,
            onTap: () {
              onAction?.call('retry');
              _notify(context, '重跑 $trackType');
            }),
      ],
    );
  }
}
