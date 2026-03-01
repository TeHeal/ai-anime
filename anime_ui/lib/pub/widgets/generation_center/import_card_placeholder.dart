import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';

/// 导入占位卡片：图标 + 标题 + 占位内容 + onTap
///
/// 用于 shot_images、shots 的「导入功能开发中」占位
class ImportCardPlaceholder extends StatelessWidget {
  const ImportCardPlaceholder({
    super.key,
    required this.title,
    required this.placeholderLabel,
    this.hintText,
    this.infoText,
    this.onTap,
  });

  final String title;
  final String placeholderLabel;

  /// 占位区下方的提示文字（如「支持 PNG/JPG/ZIP 批量导入」）
  final String? hintText;

  /// 信息框内容（如「按文件名自动匹配镜头编号」）
  final String? infoText;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentImport.withValues(alpha: 0.25),
                      AppColors.accentImport.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Icon(
                  AppIcons.upload,
                  size: 18.r,
                  color: AppColors.accentImport,
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Text(
                title,
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
            ],
          ),
          SizedBox(height: Spacing.lg.h),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap:
                  onTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('导入功能开发中'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: Spacing.xl.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.uploadOutline,
                      size: 22.r,
                      color: AppColors.accentImport,
                    ),
                    SizedBox(height: Spacing.md.h),
                    Text(
                      placeholderLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accentImport,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hintText != null) ...[
                      SizedBox(height: Spacing.sm.h),
                      Text(
                        hintText!,
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (infoText != null) ...[
            SizedBox(height: Spacing.gridGap.h),
            Container(
              padding: EdgeInsets.all(Spacing.sm.r),
              decoration: BoxDecoration(
                color: AppColors.accentImport.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.info, size: 14.r, color: AppColors.mutedDark),
                  SizedBox(width: Spacing.sm.w),
                  Expanded(
                    child: Text(
                      infoText!,
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.mutedDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
