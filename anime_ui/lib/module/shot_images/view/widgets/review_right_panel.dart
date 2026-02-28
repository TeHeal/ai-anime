import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/theme/text.dart';
import 'package:anime_ui/pub/widgets/review_layout/qa_checklist.dart';
import 'package:anime_ui/pub/widgets/review_layout/review_status_panel.dart';

/// 镜图审核右侧面板
class ReviewRightPanel extends ConsumerWidget {
  final dynamic shot;

  const ReviewRightPanel({super.key, required this.shot});

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.rightPanelBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewStatusPanel(
              currentStatus: shot?.reviewStatus ?? 'pending',
              options: const [
                ReviewOption(
                    value: 'pending', label: '待审核', color: Colors.grey),
                ReviewOption(
                    value: 'approved', label: '确认通过', color: Colors.green),
                ReviewOption(
                    value: 'needsRevision', label: '需修改', color: Colors.orange),
                ReviewOption(
                    value: 'rejected', label: '退回重生成', color: Colors.red),
              ],
              onApprove: () => _toast(context, '已确认通过'),
              onReject: () => _toast(context, '已标记需修改'),
            ),
            const Divider(height: 24, color: AppColors.divider),
            QAChecklist(
              items: const [
                QACheckItem(name: '风格一致性', score: 85, feedback: '风格基本统一'),
                QACheckItem(name: '角色一致性', score: 88, feedback: '角色外观与设定一致'),
                QACheckItem(name: '构图', score: 78, feedback: '主体偏左'),
                QACheckItem(name: '画面质量', score: 92, feedback: '清晰无瑕疵'),
                QACheckItem(name: '语义符合度', score: 80, feedback: '基本符合描述'),
              ],
              onRerunQA: () => _toast(context, 'AI 审核功能开发中'),
            ),
            const Divider(height: 24, color: AppColors.divider),
            Text(
              '对比',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _toast(context, '对比功能开发中'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: AppTextStyles.caption,
                ),
                child: const Text('与前镜对比'),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _toast(context, '对比功能开发中'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: AppTextStyles.caption,
                ),
                child: const Text('与资产参考图对比'),
              ),
            ),
            const Divider(height: 24, color: AppColors.divider),
            Text(
              '批量操作',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _toast(context, '一键全部通过'),
                icon: const Icon(AppIcons.check, size: 16),
                label: const Text('一键全部通过'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Divider(height: 24, color: AppColors.divider),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _toast(context, '重新生成'),
                icon: const Icon(AppIcons.refresh, size: 14),
                label: const Text('重新生成'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _toast(context, '上传替换'),
                icon: const Icon(AppIcons.upload, size: 14),
                label: const Text('上传替换'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: shot == null ? null : () => _toast(context, '删除功能'),
                icon: Icon(AppIcons.delete, size: 14, color: Colors.red[300]),
                label: Text(
                  '删除镜头',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.red[300],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[800]!),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
