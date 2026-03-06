import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/gen_form_helpers.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import '../voice_gen_config.dart';
import '../voice_gen_controller.dart';

/// 左侧面板：仅包含核心输入（音色名称 + 音色描述 prompt）
class VoiceGenInputPanel extends StatelessWidget {
  const VoiceGenInputPanel({
    super.key,
    required this.config,
    required this.ctrl,
    required this.ref,
    required this.nameCtrl,
    required this.promptCtrl,
  });

  final VoiceGenConfig config;
  final VoiceGenController ctrl;
  final WidgetRef ref;
  final TextEditingController nameCtrl;
  final TextEditingController promptCtrl;

  Color get accent => config.accentColor;

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
          _buildNameField(),
          SizedBox(height: Spacing.lg.h),
          _buildDesignPromptField(context),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genFormLabel('音色名称', required: true),
        SizedBox(height: Spacing.sm.h),
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

  Widget _buildDesignPromptField(BuildContext context) {
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
      controller: promptCtrl,
      hint: config.designPromptHint,
      accent: accent,
      label: '音色描述',
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
}
