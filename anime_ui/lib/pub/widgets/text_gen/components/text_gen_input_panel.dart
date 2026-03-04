import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/widgets/gen_form_helpers.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import '../text_gen_config.dart';

/// 文本生成左侧输入面板
class TextGenInputPanel extends StatelessWidget {
  const TextGenInputPanel({
    super.key,
    required this.config,
    required this.instructionCtrl,
    required this.nameCtrl,
    required this.selectedLanguage,
    required this.selectedTargetModel,
    required this.imageModels,
    required this.loadingModels,
    this.modelLoadError,
    required this.accent,
    required this.onLanguageChanged,
    required this.onTargetModelChanged,
  });

  final TextGenConfig config;
  final TextEditingController instructionCtrl;
  final TextEditingController nameCtrl;
  final String selectedLanguage;
  final ModelCatalogItem? selectedTargetModel;
  final List<ModelCatalogItem> imageModels;
  final bool loadingModels;
  final String? modelLoadError;
  final Color accent;
  final void Function(String) onLanguageChanged;
  final void Function(ModelCatalogItem?) onTargetModelChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.mid.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.saveToLibrary) ...[
            genFormLabel('名称'),
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              height: 38.h,
              child: TextField(
                controller: nameCtrl,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                decoration: genFormInputDeco('为该文本命名（可选）', accent),
              ),
            ),
            SizedBox(height: Spacing.gridGap.h),
          ],

          if (config.mode == TextGenMode.optimize &&
              config.referenceText.isNotEmpty) ...[
            genFormLabel('原始文本'),
            SizedBox(height: Spacing.sm.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Spacing.md.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedDarker,
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                config.referenceText,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: Spacing.gridGap.h),
          ],

          genFormLabel('指令'),
          SizedBox(height: Spacing.sm.h),
          TextField(
            controller: instructionCtrl,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            maxLines: 5,
            decoration: genFormInputDeco(config.instructionHint, accent),
          ),

          if (config.quickPrompts.isNotEmpty) ...[
            SizedBox(height: Spacing.lg.h),
            Wrap(
              spacing: Spacing.sm.w,
              runSpacing: Spacing.sm.h,
              children: config.quickPrompts.map((p) {
                return GestureDetector(
                  onTap: () {
                    final cur = instructionCtrl.text;
                    instructionCtrl.text = cur.isEmpty ? p : '$cur，$p';
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

          SizedBox(height: Spacing.lg.h),
          _buildOptions(context),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('选项'),
        SizedBox(height: Spacing.sm.h),
        Row(
          children: [
            Expanded(child: _buildLanguageDropdown(context)),
            SizedBox(width: Spacing.lg.w),
            Expanded(
              child: modelLoadError != null
                  ? Text(modelLoadError!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error))
                  : ModelSelectorMini(
                      models: imageModels,
                      selected: selectedTargetModel,
                      isLoading: loadingModels,
                      onChanged: onTargetModelChanged,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '语言',
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
        ),
        SizedBox(height: Spacing.xs.h),
        Container(
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedDarker,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String>(
            value: selectedLanguage,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: AppColors.surfaceMutedDarker,
            style: AppTextStyles.caption.copyWith(color: AppColors.onSurface),
            items: const ['', '中文', 'English', '中英混合']
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v.isEmpty ? '自动' : v),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onLanguageChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
