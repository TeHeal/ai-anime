import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/gen_form_helpers.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import '../voice_gen_config.dart';
import '../voice_gen_controller.dart';
import 'voice_sample_upload.dart';

/// 音色生成左侧输入面板
class VoiceGenInputPanel extends StatelessWidget {
  const VoiceGenInputPanel({
    super.key,
    required this.config,
    required this.ctrl,
    required this.ref,
    required this.nameCtrl,
    required this.promptCtrl,
    required this.previewTextCtrl,
    required this.descCtrl,
    required this.tagInputCtrl,
    required this.isGeneratingPreviewText,
    required this.onGeneratePreviewText,
  });

  final VoiceGenConfig config;
  final VoiceGenController ctrl;
  final WidgetRef ref;
  final TextEditingController nameCtrl;
  final TextEditingController promptCtrl;
  final TextEditingController previewTextCtrl;
  final TextEditingController descCtrl;
  final TextEditingController tagInputCtrl;
  final bool isGeneratingPreviewText;
  final VoidCallback onGeneratePreviewText;

  Color get accent => config.accentColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.mid.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(),
          SizedBox(height: Spacing.gridGap.h),
          if (ctrl.mode == VoiceGenMode.clone) ...[
            genFormLabel('音频样本', required: true),
            SizedBox(height: Spacing.sm.h),
            VoiceSampleUpload(
              accent: accent,
              sampleUrl: ctrl.sampleAudioUrl,
              sampleFileName: ctrl.sampleFileName,
              onUpload: (bytes, name) async {
                await ctrl.uploadSample(bytes as dynamic, name);
              },
              onRemove: ctrl.removeSample,
            ),
          ] else ...[
            _buildDesignPromptField(),
            SizedBox(height: Spacing.gridGap.h),
            _buildPreviewTextField(),
          ],
          SizedBox(height: Spacing.gridGap.h),
          _buildTagSection(),
          SizedBox(height: Spacing.lg.h),
          _buildDescField(),
          SizedBox(height: Spacing.gridGap.h),
          ModelSelector(
            serviceType: 'voice_clone',
            accent: accent,
            selected: ctrl.selectedModel,
            style: ModelSelectorStyle.chips,
            onChanged: ctrl.setModel,
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('音色名称', required: true),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: 38.h,
          child: TextField(
            controller: nameCtrl,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            decoration: genFormInputDeco('输入音色名称，如：温柔少女', accent),
          ),
        ),
      ],
    );
  }

  Widget _buildDesignPromptField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('音色描述', required: true),
        SizedBox(height: Spacing.iconGapSm.h),
        TextField(
          controller: promptCtrl,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          maxLines: 3,
          decoration: genFormInputDeco(config.designPromptHint, accent),
        ),
        if (config.quickPrompts.isNotEmpty) ...[
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: config.quickPrompts.map((p) {
              return GestureDetector(
                onTap: () {
                  final cur = promptCtrl.text;
                  promptCtrl.text = cur.isEmpty ? p : '$cur，$p';
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xs.h,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                    border: Border.all(color: accent.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    p,
                    style: AppTextStyles.tiny.copyWith(color: accent),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
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
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: previewTextCtrl,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          maxLines: 2,
          decoration: genFormInputDeco('输入用于试听的文本（可选，AI 自动生成）', accent),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('标签'),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            ...ctrl.tags.map(
              (tag) => Chip(
                label: Text(tag),
                labelStyle: AppTextStyles.tiny.copyWith(color: accent),
                backgroundColor: accent.withValues(alpha: 0.1),
                side: BorderSide(color: accent.withValues(alpha: 0.2)),
                deleteIcon: Icon(AppIcons.close, size: 14.r, color: accent),
                onDeleted: () => ctrl.removeTag(tag),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(
              width: 120.w,
              height: 32.h,
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (v) {
                  ctrl.addTag(v.trim());
                  tagInputCtrl.clear();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('备注'),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: 38.h,
          child: TextField(
            controller: descCtrl,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            decoration: genFormInputDeco('选填，音色备注信息', accent),
          ),
        ),
      ],
    );
  }
}
