import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import '../image_gen_config.dart';
import '../image_gen_controller.dart';
import 'ref_image_grid.dart';

/// 图生左侧输入面板 — 提示词 + 参考图
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

          if (config.maxRefImages > 0)
            RefImageGrid(
              controller: ctrl,
              maxImages: config.maxRefImages,
              accent: accent,
            ),
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
