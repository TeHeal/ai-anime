import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';

/// 剧本锁定/解锁页
class StoryConfirmPage extends ConsumerStatefulWidget {
  const StoryConfirmPage({super.key});

  @override
  ConsumerState<StoryConfirmPage> createState() => _StoryConfirmPageState();
}

class _StoryConfirmPageState extends ConsumerState<StoryConfirmPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lockProvider.notifier).load();
    });
  }

  Future<void> _toggleLock() async {
    final lock = ref.read(lockProvider);
    final isLocked = lock.storyLocked;
    final action = isLocked ? '解锁' : '锁定';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          '确认$action剧本',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: Text(
          isLocked ? '解锁后可以重新编辑和导入剧本。确定解锁？' : '锁定后将无法编辑和重新导入剧本，但仍可预览。确定锁定？',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: isLocked ? AppColors.primary : AppColors.error,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    final success = isLocked
        ? await ref.read(lockProvider.notifier).unlockPhase('story')
        : await ref.read(lockProvider.notifier).lockPhase('story');
    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('剧本已$action')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$action失败，请重试')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(lockProvider);
    final project = ref.watch(currentProjectProvider).value;
    final isLocked = lock.storyLocked;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? AppIcons.check : AppIcons.lock,
                size: 36.r,
                color: isLocked
                    ? AppColors.success
                    : AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: Spacing.xl.h),
            Text(
              isLocked ? '剧本已锁定' : '锁定剧本',
              style: AppTextStyles.h2.copyWith(color: AppColors.onSurface),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              isLocked
                  ? '锁定于 ${_formatTime(lock.storyLockedAt)}'
                  : '锁定后将无法编辑和重新导入，但可预览',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDark,
              ),
            ),
            if (project != null) ...[
              SizedBox(height: Spacing.xl.h),
              Container(
                padding: EdgeInsets.all(Spacing.lg.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                  border: Border.all(
                    color: AppColors.surfaceMutedDark.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow('项目', project.name),
                    SizedBox(height: Spacing.sm.h),
                    _infoRow(
                      '状态',
                      isLocked ? '已锁定' : '未锁定',
                      valueColor: isLocked
                          ? AppColors.success
                          : AppColors.mutedDark,
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: Spacing.xxl.h),
            SizedBox(
              width: 200.w,
              height: 44.h,
              child: FilledButton.icon(
                onPressed: _loading ? null : _toggleLock,
                icon: _loading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Icon(
                        isLocked ? AppIcons.lockUnlocked : AppIcons.lock,
                        size: 18.r,
                      ),
                label: Text(
                  isLocked ? '解锁剧本' : '锁定剧本',
                  style: AppTextStyles.labelLarge,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isLocked
                      ? AppColors.primary
                      : AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: valueColor ?? AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--';
    return '${dt.year}/${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
