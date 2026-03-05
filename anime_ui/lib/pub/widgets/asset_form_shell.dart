import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 资产表单弹窗外壳，统一标题栏 + 底部按钮栏 + 响应式尺寸。
///
/// 各弹窗只需向 [body] 填充自己的表单内容即可。
class AssetFormShell extends StatelessWidget {
  const AssetFormShell({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent = AppColors.primary,
    required this.body,
    this.primaryLabel = '创建',
    this.onPrimary,
    this.saving = false,
    this.maxWidth,
    this.maxHeight,
    this.secondaryActions = const [],
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accent;

  /// 表单主体内容
  final Widget body;

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool saving;

  /// 弹窗最大宽度，默认 620
  final double? maxWidth;

  /// 弹窗最大高度，默认 640
  final double? maxHeight;

  /// 底部左侧额外操作按钮（如"上一步"）
  final List<Widget> secondaryActions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 620.w,
          maxHeight: maxHeight ?? 640.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(child: body),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w, Spacing.lg.h, Spacing.md.w, Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(Spacing.sm.r),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Icon(icon, size: 20.r, color: accent),
            ),
            SizedBox(width: Spacing.md.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: Spacing.xxs.h),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(color: accent),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18.r, color: AppColors.muted),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w, Spacing.md.h, Spacing.xl.w, Spacing.lg.h,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          ...secondaryActions,
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.lg.w,
                vertical: Spacing.sm.h,
              ),
            ),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          FilledButton(
            onPressed: saving ? null : onPrimary,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              disabledBackgroundColor: accent.withValues(alpha: 0.3),
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xl.w,
                vertical: Spacing.sm.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
            ),
            child: saving
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}
