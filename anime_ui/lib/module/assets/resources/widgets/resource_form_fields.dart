import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/asset_section_label.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';

import '../models/resource_meta_schema.dart';
import '../providers/provider.dart';
import 'meta_field_editor.dart';

/// 素材表单 – 属性（Schema）编辑区
/// prompt / negativePrompt 使用 PromptFieldWithAssistant（创作助理 + 提示词库 + 入库 + 复制）
class ResourceSchemaSection extends ConsumerWidget {
  const ResourceSchemaSection({
    super.key,
    required this.schema,
    required this.metaValues,
    required this.accentColor,
    required this.availableValues,
    required this.onChanged,
  });

  final List<MetaFieldDef> schema;
  final Map<String, String> metaValues;
  final Color accentColor;
  final Map<String, List<String>>? availableValues;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editableFields = schema.where((f) => !f.readOnly).toList();
    final shortFields = editableFields
        .where(
          (f) =>
              f.type != MetaFieldType.text ||
              (f.key != 'prompt' && f.key != 'negativePrompt'),
        )
        .toList();
    final longFields = editableFields
        .where(
          (f) =>
              f.type == MetaFieldType.text &&
              (f.key == 'prompt' || f.key == 'negativePrompt'),
        )
        .toList();

    void openPromptLibrary(void Function(String) setText) {
      final promptsAsync = ref.read(promptResourcesProvider);
      promptsAsync.when(
        data: (prompts) => showPromptLibrary(
          context,
          prompts: prompts,
          accent: accentColor,
          onSelected: setText,
        ),
        loading: () => showToast(context, '正在加载提示词库…', isInfo: true),
        error: (e, _) => showToast(context, '提示词库加载失败', isError: true),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AssetSectionLabel('属性', accent: accentColor),
        SizedBox(height: Spacing.sm.h),
        if (shortFields.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final halfWidth = (constraints.maxWidth - Spacing.md.w) / 2;
              return Wrap(
                spacing: Spacing.md.w,
                runSpacing: 0,
                children: shortFields
                    .map(
                      (f) => SizedBox(
                        width: shortFields.length == 1
                            ? constraints.maxWidth
                            : halfWidth,
                        child: MetaFieldEditor(
                          field: f,
                          value: metaValues[f.key] ?? '',
                          accentColor: accentColor,
                          extraOptions: availableValues?[f.key],
                          onChanged: (v) => onChanged(f.key, v),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ...longFields.map((f) {
          final isNeg = f.key == 'negativePrompt';
          final defaultHint = isNeg ? '不想出现的元素，如：模糊、变形、低质量…' : '描述画面风格、色调、氛围…';
          final defaultLabel = isNeg ? '反向提示词（选填）' : '提示词';
          return Padding(
            padding: EdgeInsets.only(top: isNeg ? Spacing.md.h : 0),
            child: PromptFieldWithAssistant(
              value: metaValues[f.key] ?? '',
              onChanged: (v) => onChanged(f.key, v),
              hint: f.hint ?? defaultHint,
              accent: accentColor,
              label: f.label != '提示词' && f.label != '反向提示词'
                  ? '${f.label}（选填）'
                  : defaultLabel,
              negOnly: isNeg,
              maxLines: isNeg ? 2 : 3,
              onLibraryTap: openPromptLibrary,
              onSaveToLibrary: (text, name, {required bool isNegative}) async {
                await ref
                    .read(resourceListProvider.notifier)
                    .addResource(
                      Resource(
                        name: name,
                        libraryType: 'prompt',
                        modality: 'text',
                        description: text,
                        metadataJson: isNegative ? '{"negative": true}' : '{}',
                      ),
                    );
                if (context.mounted) {
                  showToast(context, '已保存到提示词库');
                }
              },
            ),
          );
        }),
      ],
    );
  }
}
