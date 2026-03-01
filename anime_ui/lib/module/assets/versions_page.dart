import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import 'characters/providers/characters.dart';
import 'locations/providers/list.dart';
import 'props/providers/list.dart';
import 'providers/versions.dart';
import 'widgets/versions_header.dart';
import 'widgets/versions_history_list.dart';
import 'widgets/versions_pending_changes.dart';
import 'widgets/versions_readiness_check.dart';
import 'widgets/versions_unfreeze_warning.dart';

/// 资产版本管理页：冻结、解冻、版本历史、待发布变更
class AssetsVersionsPage extends ConsumerStatefulWidget {
  const AssetsVersionsPage({super.key});

  @override
  ConsumerState<AssetsVersionsPage> createState() => _AssetsVersionsPageState();
}

class _AssetsVersionsPageState extends ConsumerState<AssetsVersionsPage> {
  bool _freezing = false;
  bool _showUnfreezeWarning = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(assetVersionsProvider.notifier).load();
      ref.read(assetCharactersProvider.notifier).load();
      ref.read(assetLocationsProvider.notifier).load();
      ref.read(assetPropsProvider.notifier).load();
    });
  }

  Future<void> _freezeAssets() async {
    if (_freezing) return;
    setState(() => _freezing = true);
    try {
      final chars = ref.read(assetCharactersProvider).value ?? [];
      final locs = ref.read(assetLocationsProvider).value ?? [];

      // 冻结前自动确认未确认的角色
      final draftIds = chars
          .where((c) => c.status != 'confirmed' && c.id != null)
          .map((c) => c.id!)
          .toList();
      if (draftIds.isNotEmpty) {
        await ref.read(assetCharactersProvider.notifier).batchConfirm(draftIds);
      }
      for (final loc in locs) {
        if (loc.status != 'confirmed' && loc.id != null) {
          await ref.read(assetLocationsProvider.notifier).confirm(loc.id!);
        }
      }

      final version = await ref.read(assetVersionsProvider.notifier).freeze();
      if (!mounted) return;

      if (version != null) {
        await ref.read(lockProvider.notifier).lockPhase('assets');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('资产已冻结 — 版本 v${version.version}'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(assetVersionsProvider.notifier).load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('冻结失败，请重试'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _freezing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chars = ref.watch(assetCharactersProvider).value ?? [];
    final locs = ref.watch(assetLocationsProvider).value ?? [];
    final props = ref.watch(assetPropsProvider).value ?? [];
    final lock = ref.watch(lockProvider);
    final isLocked = lock.assetsLocked;
    final versions = ref.watch(assetVersionsProvider).value ?? [];

    final pendingChars = chars.where((c) => !c.isConfirmed).toList();
    final pendingLocs = locs.where((l) => l.status != 'confirmed').toList();
    final pendingProps = props.where((p) => !p.isConfirmed).toList();
    final hasPendingChanges =
        pendingChars.isNotEmpty ||
        pendingLocs.isNotEmpty ||
        pendingProps.isNotEmpty;

    final confirmedChars = chars.where((c) => c.isConfirmed).length;
    final confirmedLocs = locs.where((l) => l.status == 'confirmed').length;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.xl.h,
        horizontal: Spacing.xl.w,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 720.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VersionsHeader(
                isLocked: isLocked,
                lockedAt: lock.assetsLockedAt,
                versions: versions,
              ),
              SizedBox(height: Spacing.xl.h),
              if (hasPendingChanges) ...[
                VersionsPendingChanges(
                  pendingChars: pendingChars,
                  pendingLocs: pendingLocs,
                  pendingProps: pendingProps,
                ),
                SizedBox(height: Spacing.xl.h),
              ],
              VersionsReadinessCheck(
                charTotal: chars.length,
                charConfirmed: confirmedChars,
                locTotal: locs.length,
                locConfirmed: confirmedLocs,
                propCount: props.length,
                isLocked: isLocked,
              ),
              if (_showUnfreezeWarning) ...[
                SizedBox(height: Spacing.lg.h),
                VersionsUnfreezeWarning(
                  onDismiss: () => setState(() => _showUnfreezeWarning = false),
                ),
              ],
              SizedBox(height: Spacing.xl.h),
              _buildActions(isLocked, chars.isEmpty && locs.isEmpty),
              if (versions.isNotEmpty) ...[
                SizedBox(height: Spacing.xxl.h),
                VersionsHistoryList(versions: versions),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(bool isLocked, bool isEmpty) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: (isEmpty || _freezing)
                ? null
                : isLocked
                ? () => setState(() => _showUnfreezeWarning = true)
                : _freezeAssets,
            icon: _freezing
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
              _freezing
                  ? '冻结中...'
                  : isLocked
                  ? '解冻当前版本'
                  : '创建冻结版本',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isLocked ? AppColors.warning : AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: Spacing.gridGap.h),
              textStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
