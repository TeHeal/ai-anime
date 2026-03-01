import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/ai_action.dart';
import 'creation_assistant_pill_button.dart';
import 'tiny_btn.dart';

/// 反向提示词输入区块（含创作助理、提示词库、入库）
class NegPromptField extends StatelessWidget {
  const NegPromptField({
    super.key,
    required this.controller,
    required this.hint,
    required this.accent,
    this.label,
    this.onLibraryTap,
    this.onAssistantAction,
    this.onSaveToLibrary,
  });

  final TextEditingController controller;
  final String hint;
  final Color accent;
  final String? label;
  final VoidCallback? onLibraryTap;
  final void Function(AiAction)? onAssistantAction;
  final VoidCallback? onSaveToLibrary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label ?? '反向提示词（选填）',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (onAssistantAction != null ||
                onLibraryTap != null ||
                onSaveToLibrary != null) ...[
              const Spacer(),
              if (onAssistantAction != null)
                CreationAssistantPillButton<AiAction>(
                  itemBuilder: (_) => AiAction.values
                      .map(
                        (a) => PopupMenuItem<AiAction>(
                          value: a,
                          height: 36.h,
                          child: Row(
                            children: [
                              Icon(aiActionIcons[a], size: 15.r, color: accent),
                              SizedBox(width: Spacing.sm.w),
                              Text(
                                aiActionLabels[a]!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onSelected: onAssistantAction!,
                ),
              if (onLibraryTap != null) ...[
                SizedBox(width: Spacing.sm.w),
                TinyBtn(
                  icon: AppIcons.document,
                  label: '提示词库',
                  accent: accent,
                  onTap: onLibraryTap!,
                ),
              ],
            ],
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        Stack(
          clipBehavior: Clip.none,
          children: [
            TextField(
              controller: controller,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              decoration: onSaveToLibrary != null
                  ? _defaultDeco(hint).copyWith(
                      contentPadding: EdgeInsets.only(
                        left: 12.w,
                        top: 10.h,
                        right: 70.w,
                        bottom: 36.h,
                      ),
                    )
                  : _defaultDeco(hint),
            ),
            if (onSaveToLibrary != null)
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: TinyBtn(
                  icon: AppIcons.save,
                  label: '入库',
                  accent: accent,
                  onTap: onSaveToLibrary!,
                ),
              ),
          ],
        ),
      ],
    );
  }

  InputDecoration _defaultDeco(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.onSurface.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: AppColors.surfaceContainer,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.lg.h,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        borderSide: BorderSide(color: accent),
      ),
    );
  }
}
