import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/module/draft/page.dart';

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
            Icon(AppIcons.lock,
                size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('剧本已锁定，无法重新导入',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            Text('如需修改，请先在「锁定」页面解锁',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => context.go(Routes.storyConfirm),
              icon: const Icon(AppIcons.lockUnlocked, size: 16),
              label: const Text('前往锁定页'),
            ),
          ],
        ),
      );
    }

    return const DraftPage();
  }
}
