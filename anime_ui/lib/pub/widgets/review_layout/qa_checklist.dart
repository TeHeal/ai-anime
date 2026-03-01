import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// A single QA check item result.
class QACheckItem {
  final String name;
  final int score;
  final String feedback;

  const QACheckItem({
    required this.name,
    required this.score,
    this.feedback = '',
  });

  /// 0-59 fail, 60-79 warn, 80+ pass
  String get status => score >= 80 ? 'pass' : (score >= 60 ? 'warn' : 'fail');
}

/// Displays a list of QA check items with scores, icons, and a total score.
class QAChecklist extends StatelessWidget {
  final List<QACheckItem> items;
  final int? totalScore;
  final VoidCallback? onRerunQA;
  final String title;

  const QAChecklist({
    super.key,
    required this.items,
    this.totalScore,
    this.onRerunQA,
    this.title = 'QA 检查项',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotal =
        totalScore ??
        (items.isEmpty
            ? 0
            : items.map((e) => e.score).reduce((a, b) => a + b) ~/
                  items.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '$effectiveTotal/100',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: _scoreColor(effectiveTotal),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.lg.h),
        for (final item in items) _buildItem(item),
        if (onRerunQA != null) ...[
          SizedBox(height: Spacing.lg.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRerunQA,
              icon: Icon(AppIcons.magicStick, size: 14.r),
              label: const Text('重新 AI 审核'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                textStyle: AppTextStyles.caption,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItem(QACheckItem item) {
    final color = _statusColor(item.status);
    final icon = _statusIcon(item.status);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.r, color: color),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyles.caption.copyWith(color: AppColors.mutedLight),
                ),
              ),
              Text(
                '${item.score}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          if (item.feedback.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: Spacing.mid.w, top: Spacing.xxs.h),
              child: Text(
                item.feedback,
                style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
              ),
            ),
        ],
      ),
    );
  }

  static Color _scoreColor(int score) => score >= 80
      ? AppColors.success
      : (score >= 60 ? AppColors.warning : AppColors.error);

  static Color _statusColor(String status) {
    switch (status) {
      case 'pass':
        return AppColors.success;
      case 'warn':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status) {
      case 'pass':
        return AppIcons.check;
      case 'warn':
        return AppIcons.warning;
      default:
        return AppIcons.error;
    }
  }
}
