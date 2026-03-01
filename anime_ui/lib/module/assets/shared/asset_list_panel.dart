import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 资产列表面板：统计行 + ListView
///
/// 用于 locations、props 等资产列表的通用布局
class AssetListPanel extends StatelessWidget {
  const AssetListPanel({
    super.key,
    required this.totalCount,
    required this.confirmedCount,
    required this.countLabel,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int totalCount;
  final int confirmedCount;

  /// 如 "个场景"、"个道具"
  final String countLabel;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.lg.w,
            Spacing.sm.h,
            Spacing.lg.w,
            Spacing.sm.h,
          ),
          child: Row(
            children: [
              Text(
                '$totalCount $countLabel',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Icon(AppIcons.check, size: 12.r, color: AppColors.success),
              Text(
                ' $confirmedCount',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}
