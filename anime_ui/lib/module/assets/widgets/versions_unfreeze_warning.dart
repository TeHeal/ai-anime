import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

import '../providers/versions.dart';

/// 解冻影响分析弹窗区块
class VersionsUnfreezeWarning extends ConsumerStatefulWidget {
  const VersionsUnfreezeWarning({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  ConsumerState<VersionsUnfreezeWarning> createState() =>
      _VersionsUnfreezeWarningState();
}

class _VersionsUnfreezeWarningState
    extends ConsumerState<VersionsUnfreezeWarning> {
  List<Map<String, dynamic>> _impactItems = [];
  bool _loadingImpact = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadImpact());
  }

  Future<void> _loadImpact() async {
    setState(() => _loadingImpact = true);
    try {
      final data = await ref.read(assetVersionsProvider.notifier).impact();
      final impacts =
          (data['impacts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (mounted) setState(() => _impactItems = impacts);
    } catch (_) {
      // API 失败时降级为空列表，避免解冻弹窗崩溃
      if (mounted) setState(() => _impactItems = []);
    } finally {
      if (mounted) setState(() => _loadingImpact = false);
    }
  }

  Future<void> _onUnfreeze() async {
    await ref.read(assetVersionsProvider.notifier).unfreeze();
    await ref.read(lockProvider.notifier).unlockPhase('assets');
    if (mounted) {
      widget.onDismiss();
      showToast(context, '已解冻，资产可编辑');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.warning, size: 18.r, color: AppColors.warning),
              SizedBox(width: Spacing.sm.w),
              Text(
                '解冻影响分析',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          Text(
            '解冻将允许修改当前版本基线资产，以下下游内容可能受影响：',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: Spacing.sm.h),
          if (_loadingImpact)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_impactItems.isEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: Spacing.sm.w,
                bottom: Spacing.xs.h,
              ),
              child: Text(
                '暂无下游内容引用当前版本',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            )
          else
            ..._impactItems.map(
              (item) => _impactRow(
                item['module'] as String? ?? '',
                item['detail'] as String? ?? '',
              ),
            ),
          SizedBox(height: Spacing.md.h),
          Text(
            '受影响内容不会被自动删除，但可能与修改后的资产不一致。修改完成后建议重新冻结。',
            style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onDismiss,
                child: Text(
                  '取消',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              FilledButton(
                onPressed: _onUnfreeze,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: const Text('确认解冻'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactRow(String module, String desc) {
    return Padding(
      padding: EdgeInsets.only(left: Spacing.sm.w, bottom: Spacing.xs.h),
      child: Row(
        children: [
          Text(
            '• ',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
          ),
          Text(
            module,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              desc,
              style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
            ),
          ),
        ],
      ),
    );
  }
}
