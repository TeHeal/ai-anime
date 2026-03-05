import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';

import 'widgets/freeze_status_card.dart';
import 'widgets/freeze_readiness_board.dart';
import 'widgets/freeze_pipeline.dart';

/// 脚本 - 锁定页：发布控制台
class ScriptFreezePage extends ConsumerStatefulWidget {
  const ScriptFreezePage({super.key});

  @override
  ConsumerState<ScriptFreezePage> createState() => _ScriptFreezePageState();
}

class _ScriptFreezePageState extends ConsumerState<ScriptFreezePage> {
  bool _locking = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(lockProvider.notifier).load();
      ref.read(episodesProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(lockProvider);
    final isLocked = lock.scriptLocked;
    final states = ref.watch(episodeStatesProvider);

    // 汇总统计
    final withShots = states.values
        .where((s) => s.isComplete && s.shotCount > 0)
        .toList();
    int totalShots = 0, approved = 0, pending = 0, revision = 0;
    for (final s in withShots) {
      totalShots += s.shotCount;
      approved += s.approvedCount;
      pending += s.pendingCount;
      revision += s.revisionCount;
    }

    final hasShots = totalShots > 0;
    final allReady = hasShots && withShots.every((s) => s.allApproved);
    final canLock = hasShots && allReady && !isLocked;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.xl.h,
        horizontal: Spacing.xl.w,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 760.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 状态 Hero 卡片
              FreezeStatusCard(
                isLocked: isLocked,
                lockedAt: lock.scriptLockedAt,
                totalShots: totalShots,
                approvedShots: approved,
                pendingShots: pending,
                revisionShots: revision,
              ),
              SizedBox(height: Spacing.xl.h),

              // 2. 分集就绪度看板
              FreezeReadinessBoard(
                episodeStates: withShots,
                isLocked: isLocked,
              ),
              SizedBox(height: Spacing.xl.h),

              // 3. 生产流水线
              FreezePipeline(lockStatus: lock),
              SizedBox(height: Spacing.xl.h),

              // 4. 操作区
              _buildActions(isLocked, canLock, hasShots, allReady),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(
    bool isLocked,
    bool canLock,
    bool hasShots,
    bool allReady,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 锁定 / 解锁按钮
        SizedBox(
          height: 48.h,
          child: FilledButton.icon(
            onPressed: _locking
                ? null
                : isLocked
                    ? _confirmUnlock
                    : canLock
                        ? _lockScript
                        : null,
            icon: _locking
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onSurface,
                    ),
                  )
                : Icon(
                    isLocked ? AppIcons.lockUnlocked : AppIcons.lock,
                    size: 18.r,
                  ),
            label: Text(
              _locking
                  ? '处理中…'
                  : isLocked
                      ? '解锁脚本'
                      : '锁定脚本',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isLocked ? AppColors.warning : AppColors.primary,
              disabledBackgroundColor: AppColors.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              ),
              textStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // 不可锁定时的提示
        if (!isLocked && !canLock) ...[
          SizedBox(height: Spacing.sm.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.info, size: 12.r, color: AppColors.muted),
              SizedBox(width: Spacing.xs.w),
              Text(
                !hasShots
                    ? '需要先生成分镜脚本'
                    : '需要全部镜头审核通过后才可锁定',
                style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _lockScript() async {
    if (_locking) return;
    setState(() => _locking = true);
    try {
      final ok = await ref.read(lockProvider.notifier).lockPhase('script');
      if (!mounted) return;
      if (ok) {
        showToast(context, '脚本已锁定 — 进入生产基线');
      } else {
        showToast(context, '锁定失败，请重试', isError: true);
      }
    } finally {
      if (mounted) setState(() => _locking = false);
    }
  }

  Future<void> _confirmUnlock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        ),
        title: Row(
          children: [
            Icon(AppIcons.warning, size: 20.r, color: AppColors.warning),
            SizedBox(width: Spacing.sm.w),
            const Text('确认解锁'),
          ],
        ),
        content: Text(
          '解锁后脚本将重新进入可编辑状态，\n已进入生产的镜头可能受到影响。',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('确认解锁'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _locking = true);
    try {
      final ok = await ref.read(lockProvider.notifier).unlockPhase('script');
      if (!mounted) return;
      if (ok) {
        showToast(context, '脚本已解锁 — 可继续编辑');
      } else {
        showToast(context, '解锁失败，请重试', isError: true);
      }
    } finally {
      if (mounted) setState(() => _locking = false);
    }
  }
}
