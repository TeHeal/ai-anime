import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// AI 建议内联区块（流式生成中 / 可编辑 / 替换/追加/放弃）
class PromptFieldAiSuggestion extends StatelessWidget {
  const PromptFieldAiSuggestion({
    super.key,
    required this.suggestion,
    required this.loading,
    this.originalContent,
    required this.showOriginalDiff,
    required this.accent,
    required this.onToggleOriginalDiff,
    required this.onDismiss,
    this.onAcceptReplace,
    this.onAcceptAppend,
    this.controller,
  });

  final String? suggestion;
  final bool loading;
  final String? originalContent;
  final bool showOriginalDiff;
  final Color accent;
  final VoidCallback onToggleOriginalDiff;
  final VoidCallback onDismiss;
  final VoidCallback? onAcceptReplace;
  final VoidCallback? onAcceptAppend;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Spacing.sm.h),
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.autoAwesome, size: 14.r, color: accent),
              SizedBox(width: Spacing.sm.w),
              Text(
                loading ? 'AI 生成中…' : 'AI 建议（可直接编辑）',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              if (loading) ...[
                SizedBox(width: Spacing.sm.w),
                SizedBox(
                  width: 12.w,
                  height: 12.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5.r,
                    color: accent,
                  ),
                ),
              ],
              const Spacer(),
              if (originalContent != null && originalContent!.isNotEmpty)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onToggleOriginalDiff,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showOriginalDiff
                              ? AppIcons.unfoldLess
                              : AppIcons.compareArrows,
                          size: 14.r,
                          color: accent.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: Spacing.xs.w),
                        Text(
                          showOriginalDiff ? '收起原文' : '对比原文',
                          style: AppTextStyles.tiny.copyWith(
                            color: accent.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (showOriginalDiff && originalContent != null) ...[
            SizedBox(height: Spacing.sm.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Spacing.sm.r),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '原文',
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.mutedDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Spacing.xs.h),
                  Text(
                    originalContent!.isEmpty ? '（空）' : originalContent!,
                    style: AppTextStyles.bodySmall.copyWith(
                      height: 1.5,
                      color: AppColors.mutedDark,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.mutedDarker,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: Spacing.sm.h),
          if (loading)
            SelectableText(
              suggestion ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                color: AppColors.onSurface,
              ),
            )
          else
            TextField(
              controller: controller,
              maxLines: null,
              minLines: 2,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '编辑 AI 建议内容…',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDarkest,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.buttonPaddingV.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.2),
                    width: 1.r,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.5),
                    width: 1.5.r,
                  ),
                ),
              ),
            ),
          SizedBox(height: Spacing.lg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onDismiss,
                icon: Icon(AppIcons.close, size: 14.r),
                label: const Text('放弃'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mutedDarkest,
                  textStyle: AppTextStyles.caption,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.chipPaddingH.w,
                    vertical: Spacing.xs.h,
                  ),
                ),
              ),
              if (!loading && (controller?.text.isNotEmpty ?? false)) ...[
                SizedBox(width: Spacing.iconGapSm.w),
                if (onAcceptAppend != null)
                  OutlinedButton.icon(
                    onPressed: onAcceptAppend,
                    icon: Icon(AppIcons.add, size: 14.r),
                    label: const Text('追加'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent.withValues(alpha: 0.8),
                      side: BorderSide(color: accent.withValues(alpha: 0.3)),
                      textStyle: AppTextStyles.caption,
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.chipPaddingH.w,
                        vertical: Spacing.xs.h,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                if (onAcceptAppend != null) SizedBox(width: Spacing.sm.w),
                if (onAcceptReplace != null)
                  FilledButton.icon(
                    onPressed: onAcceptReplace,
                    icon: Icon(AppIcons.check, size: 14.r),
                    label: const Text('替换'),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: AppColors.onPrimary,
                      textStyle: AppTextStyles.caption,
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.md.w,
                        vertical: Spacing.xs.h,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
