import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 脚本 - 锁定页（Tab 4）
/// v2 TODO: 恢复按集锁定功能
class ScriptFreezePage extends ConsumerWidget {
  const ScriptFreezePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.lock, size: 48.r, color: AppColors.mutedDarker),
          SizedBox(height: Spacing.lg.h),
          Text(
            '脚本锁定功能暂未启用',
            style: AppTextStyles.h3.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            '此功能将在第二版中上线，届时支持按集锁定',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedDarker,
            ),
          ),
        ],
      ),
    );
  }
}
