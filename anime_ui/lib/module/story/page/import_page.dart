import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/module/draft/index.dart';

/// 剧本导入页 — 锁定后不可导入，展示 DraftPage
class StoryImportPage extends ConsumerWidget {
  const StoryImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(lockProvider);
    if (lock.storyLocked) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.lock,
              size: 48.r,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            SizedBox(height: Spacing.lg.h),
            Text(
              '剧本已锁定，无法重新导入',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              '如需修改，请先在「锁定」页面解锁',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDark,
              ),
            ),
            SizedBox(height: Spacing.mid.h),
            OutlinedButton.icon(
              onPressed: () => context.go(Routes.storyConfirm),
              icon: Icon(AppIcons.lockUnlocked, size: 16.r),
              label: const Text('前往锁定页'),
            ),
          ],
        ),
      );
    }

    return const DraftPage();
  }
}
