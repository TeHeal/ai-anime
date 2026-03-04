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

/// 图生左侧输入面板 — 比例/分辨率以内联配置条常驻，不再折叠
class ImageGenInputPanel extends StatelessWidget {
  const ImageGenInputPanel({
    super.key,
    required this.config,
    required this.ctrl,
    required this.ref,
    required this.promptCtrl,
    required this.negPromptCtrl,
    required this.onPromptLibraryTap,
  });

  final ImageGenConfig config;
  final ImageGenController ctrl;
  final WidgetRef ref;
  final TextEditingController promptCtrl;
  final TextEditingController negPromptCtrl;
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

          // 内联配置条：比例 + 分辨率常驻
          _InlineConfigBar(ctrl: ctrl, config: config, accent: accent),

          // 模型选择器（紧凑内联）
          SizedBox(height: Spacing.md.h),
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
}

/// 内联配置条：比例选择 + 分辨率切换，以紧凑横条样式常驻
class _InlineConfigBar extends StatelessWidget {
  const _InlineConfigBar({
    required this.ctrl,
    required this.config,
    required this.accent,
  });

  final ImageGenController ctrl;
  final ImageGenConfig config;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: RatioPicker(
        selectedRatio: ctrl.ratio,
        selectedResolution: ctrl.resolution,
        allowedRatios: config.allowedRatios,
        accent: accent,
        onRatioChanged: ctrl.setRatio,
        onResolutionChanged: ctrl.setResolution,
      ),
    );
  }
}
