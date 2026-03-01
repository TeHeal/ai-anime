import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import '../image_gen_config.dart';
import '../image_gen_controller.dart';
import 'ratio_picker.dart';
import 'ref_image_grid.dart';

/// 图生左侧输入面板
class ImageGenInputPanel extends StatelessWidget {
  const ImageGenInputPanel({
    super.key,
    required this.config,
    required this.ctrl,
    required this.ref,
    required this.promptCtrl,
    required this.negPromptCtrl,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.onPromptLibraryTap,
  });

  final ImageGenConfig config;
  final ImageGenController ctrl;
  final WidgetRef ref;
  final TextEditingController promptCtrl;
  final TextEditingController negPromptCtrl;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final void Function(ValueChanged<String>) onPromptLibraryTap;

  Color get accent => config.accentColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.mid.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromptField(context),
          SizedBox(height: Spacing.lg.h),

          if (config.maxRefImages > 0) ...[
            RefImageGrid(
              controller: ctrl,
              maxImages: config.maxRefImages,
              accent: accent,
            ),
            SizedBox(height: Spacing.lg.h),
          ],

          _buildAdvancedToggle(context),
          if (showAdvanced) ...[
            SizedBox(height: Spacing.md.h),
            _buildAdvancedContent(context),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptField(BuildContext context) {
    return PromptFieldWithAssistant(
      controller: promptCtrl,
      hint: config.promptHint,
      accent: accent,
      quickPrompts: config.quickPrompts,
      onLibraryTap: (setText) => onPromptLibraryTap(setText),
      negPromptController: negPromptCtrl,
      negPromptHint: '不想出现的元素，如：模糊、变形、低质量…',
      negOnLibraryTap: (setText) => onPromptLibraryTap(setText),
      onSaveToLibrary: (text, name, {required bool isNegative}) async {
        await ref
            .read(resourceListPortProvider)
            .addResource(
              Resource(
                name: name,
                libraryType: 'prompt',
                modality: 'text',
                description: text,
              ),
            );
      },
    );
  }

  Widget _buildAdvancedToggle(BuildContext context) {
    return GestureDetector(
      onTap: onToggleAdvanced,
      child: Row(
        children: [
          Icon(
            showAdvanced ? AppIcons.expandMore : AppIcons.chevronRight,
            size: (AppTextStyles.bodySmall.fontSize ?? 13).r,
            color: AppColors.mutedDark,
          ),
          SizedBox(width: Spacing.inputGapSm.w),
          Text(
            '高级选项（比例 / 模型）',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RatioPicker(
          selectedRatio: ctrl.ratio,
          selectedResolution: ctrl.resolution,
          allowedRatios: config.allowedRatios,
          accent: accent,
          onRatioChanged: ctrl.setRatio,
          onResolutionChanged: ctrl.setResolution,
        ),
        SizedBox(height: Spacing.gridGap.h),
        ModelSelector(
          serviceType: 'image',
          accent: accent,
          selected: ctrl.selectedModel,
          style: ModelSelectorStyle.dialog,
          onChanged: ctrl.setModel,
        ),
        if (ctrl.sizeValidationError != null) ...[
          SizedBox(height: Spacing.sm.h),
          Row(
            children: [
              Icon(
                AppIcons.warning,
                size: (AppTextStyles.bodySmall.fontSize ?? 13).r,
                color: AppColors.warning,
              ),
              SizedBox(width: Spacing.xs.w),
              Text(
                ctrl.sizeValidationError!,
                style: AppTextStyles.tiny.copyWith(color: AppColors.warning),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
