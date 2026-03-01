import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 素材库页（待迁移完整实现：模态切换、侧边导航、内容区等）
class AssetsResourcesPage extends StatelessWidget {
  const AssetsResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.gallery, size: 64.r, color: AppColors.muted),
          SizedBox(height: Spacing.lg.h),
          Text(
            '素材库',
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
