import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/gen_form_helpers.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import '../voice_gen_config.dart';
import '../voice_gen_controller.dart';
import 'voice_result_preview.dart';

/// 右侧面板：上部参数配置 + 下部生成结果（参考角色生成图布局）
class VoiceGenRightPanel extends StatelessWidget {
  const VoiceGenRightPanel({
    super.key,
    required this.config,
    required this.ctrl,
    required this.accent,
    required this.previewTextCtrl,
    required this.descCtrl,
    required this.tagInputCtrl,
    required this.isGeneratingPreviewText,
    required this.onGeneratePreviewText,
    required this.isSaving,
    this.isSaved = false,
    required this.onSave,
  });

  final VoiceGenConfig config;
  final VoiceGenController ctrl;
  final Color accent;
  final TextEditingController previewTextCtrl;
  final TextEditingController descCtrl;
  final TextEditingController tagInputCtrl;
  final bool isGeneratingPreviewText;
  final VoidCallback onGeneratePreviewText;
  final bool isSaving;
  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.mid.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 参数配置区 ──
          _buildPreviewTextField(),
          SizedBox(height: Spacing.md.h),
          _buildTagAndDescRow(),
          SizedBox(height: Spacing.md.h),
          ModelSelector(
            serviceType: 'voice_clone',
            accent: accent,
            selected: ctrl.selectedModel,
            style: ModelSelectorStyle.chips,
            onChanged: ctrl.setModel,
          ),

          SizedBox(height: Spacing.lg.h),

          // ── 生成结果区 ──
          _buildResultSection(context),
        ],
      ),
    );
  }

  Widget _buildPreviewTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            genFormLabel('预览文本'),
            const Spacer(),
            TextButton.icon(
              onPressed: isGeneratingPreviewText ? null : onGeneratePreviewText,
              icon: isGeneratingPreviewText
                  ? SizedBox(
                      width: Spacing.md.w,
                      height: Spacing.md.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5.r,
                        color: accent,
                      ),
                    )
                  : Icon(AppIcons.magicStick, size: 12.r, color: accent),
              label: Text(
                'AI 生成',
                style: AppTextStyles.tiny.copyWith(color: accent),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.xs.h,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        TextField(
          controller: previewTextCtrl,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          maxLines: 2,
          decoration: genFormInputDeco('输入用于试听的文本（可选，AI 自动生成）', accent),
        ),
      ],
    );
  }

  Widget _buildTagAndDescRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTagSection()),
        SizedBox(width: Spacing.md.w),
        Expanded(child: _buildDescField()),
      ],
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('标签'),
        SizedBox(height: Spacing.sm.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 38.h),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...ctrl.tags.map(
                (tag) => Chip(
                  label: Text(tag),
                  labelStyle: AppTextStyles.tiny.copyWith(color: accent),
                  backgroundColor: accent.withValues(alpha: 0.1),
                  side: BorderSide(color: accent.withValues(alpha: 0.2)),
                  deleteIcon: Icon(AppIcons.close, size: 12.r, color: accent),
                  onDeleted: () => ctrl.removeTag(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  padding: EdgeInsets.symmetric(horizontal: Spacing.xs.w),
                ),
              ),
              IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 80.w),
                  child: TextField(
                    controller: tagInputCtrl,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '+ 添加标签',
                      hintStyle: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedDarker,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Spacing.xs.w,
                        vertical: Spacing.xs.h,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (v) {
                      ctrl.addTag(v.trim());
                      tagInputCtrl.clear();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('备注'),
        SizedBox(height: Spacing.sm.h),
        SizedBox(
          height: 38.h,
          child: TextField(
            controller: descCtrl,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            decoration: genFormInputDeco('选填', accent),
          ),
        ),
      ],
    );
  }

  // ─── 生成结果区 ───

  Widget _buildResultSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '生成预览',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        VoiceResultPreview(
          accent: accent,
          audioUrl: ctrl.resultAudioUrl,
          isGenerating: ctrl.isGenerating,
          progress: ctrl.progress,
          errorMsg: ctrl.hasError ? ctrl.errorMsg : null,
        ),
        if (ctrl.isDone && ctrl.resultAudioUrl.isNotEmpty) ...[
          SizedBox(height: Spacing.md.h),
          _buildResultActions(context),
        ],
      ],
    );
  }

  Widget _buildResultActions(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: ctrl.reset,
          icon: Icon(AppIcons.refresh, size: 14.r),
          label: const Text('重新生成'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.muted,
            side: const BorderSide(color: AppColors.border),
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: (isSaving || isSaved) ? null : onSave,
          icon: isSaving
              ? SizedBox(
                  width: 14.w,
                  height: 14.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: AppColors.onSurface,
                  ),
                )
              : Icon(
                  isSaved ? AppIcons.check : AppIcons.save,
                  size: 14.r,
                ),
          label: Text(isSaved ? '已保存' : '保存音色'),
          style: FilledButton.styleFrom(
            backgroundColor: isSaved ? AppColors.success : accent,
            disabledBackgroundColor: isSaved
                ? AppColors.success.withValues(alpha: 0.7)
                : null,
            disabledForegroundColor: isSaved
                ? AppColors.onPrimary.withValues(alpha: 0.9)
                : null,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
      ],
    );
  }
}
