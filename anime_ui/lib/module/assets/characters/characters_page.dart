import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 角色页（待迁移完整实现：列表、详情、AI 提取、形象生成等）
class AssetsCharactersPage extends StatelessWidget {
  const AssetsCharactersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.person, size: 64.r, color: AppColors.muted),
          SizedBox(height: Spacing.lg.h),
          Text(
            '角色页',
            style: AppTextStyles.h3.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            '待迁移完整实现',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
