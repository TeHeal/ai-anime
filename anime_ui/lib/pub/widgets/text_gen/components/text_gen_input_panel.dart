import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/gen_form_helpers.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import '../text_gen_config.dart';

/// 文本生成输入面板
class TextGenInputPanel extends ConsumerWidget {
  const TextGenInputPanel({
    super.key,
    required this.config,
    required this.instructionCtrl,
    required this.nameCtrl,
    required this.selectedLanguage,
    required this.accent,
    required this.onLanguageChanged,
  });

  final TextGenConfig config;
  final TextEditingController instructionCtrl;
  final TextEditingController nameCtrl;
  final String selectedLanguage;
  final Color accent;
  final void Function(String) onLanguageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
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
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.onSurface),
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
                color: AppColors.inputBackground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.3)),
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

          _buildInstructionField(context, ref),
          SizedBox(height: Spacing.lg.h),
          _buildOptions(context),
        ],
      ),
    );
  }

  Widget _buildInstructionField(BuildContext context, WidgetRef ref) {
    void openPromptLibrary(void Function(String) setText) {
      final resources =
          ref.read(resourceListPortProvider).resources.value ?? [];
      final prompts =
          resources.where((r) => r.libraryType == 'prompt').toList();
      showPromptLibrary(
        context,
        prompts: prompts,
        accent: accent,
        onSelected: setText,
      );
    }

    return PromptFieldWithAssistant(
      controller: instructionCtrl,
      hint: config.instructionHint,
      accent: accent,
      label: '指令',
      quickPrompts: config.quickPrompts,
      maxLines: 5,
      onLibraryTap: openPromptLibrary,
      onSaveToLibrary: (text, name, {required bool isNegative}) async {
        await ref.read(resourceListPortProvider).addResource(
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

  Widget _buildOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('选项'),
        SizedBox(height: Spacing.sm.h),
        _buildLanguageDropdown(),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
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
          padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
          decoration: genSelectBoxDeco(),
          child: DropdownButton<String>(
            value: selectedLanguage,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: AppColors.surfaceContainerHigh,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.onSurface),
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                size: 18.r, color: AppColors.muted),
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
