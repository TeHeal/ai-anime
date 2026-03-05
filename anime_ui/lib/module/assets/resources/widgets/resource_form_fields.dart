import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';

import '../models/resource_meta_schema.dart';
import '../providers/provider.dart';
import 'meta_field_editor.dart';

/// 素材表单 – 标签编辑区
class ResourceTagEditor extends StatefulWidget {
  const ResourceTagEditor({
    super.key,
    required this.tags,
    required this.tagInputController,
    required this.accentColor,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  final List<String> tags;
  final TextEditingController tagInputController;
  final Color accentColor;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;

  @override
  State<ResourceTagEditor> createState() => _ResourceTagEditorState();
}

class _ResourceTagEditorState extends State<ResourceTagEditor> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 13.h,
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '标签',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.mutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.xs.h),
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xs.h,
            ),
            constraints: BoxConstraints(minHeight: 36.h),
            decoration: BoxDecoration(
              color: AppColors.inputBackground.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
            ),
            child: Wrap(
              spacing: Spacing.xs.w,
              runSpacing: Spacing.xs.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...widget.tags.map((tag) => _TagChip(
                      label: tag,
                      accent: widget.accentColor,
                      onDelete: () => widget.onTagRemoved(tag),
                    )),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 80.w),
                    child: TextField(
                      controller: widget.tagInputController,
                      focusNode: _focusNode,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: widget.tags.isEmpty
                            ? '输入后按回车添加'
                            : '添加…',
                        hintStyle: AppTextStyles.tiny
                            .copyWith(color: AppColors.mutedDark),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Spacing.xs.w,
                          vertical: Spacing.xs.h,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: widget.onTagAdded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: Spacing.md.h),
      ],
    );
  }
}

/// 紧凑标签 Chip
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.accent,
    required this.onDelete,
  });

  final String label;
  final Color accent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(color: AppColors.onSurface),
          ),
          SizedBox(width: Spacing.xxs.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(AppIcons.close, size: 12.r, color: accent.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

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
        .where((f) =>
            f.type != MetaFieldType.text ||
            (f.key != 'prompt' && f.key != 'negativePrompt'))
        .toList();
    final longFields = editableFields
        .where((f) =>
            f.type == MetaFieldType.text &&
            (f.key == 'prompt' || f.key == 'negativePrompt'))
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
        Row(
          children: [
            Container(
              width: 3.w,
              height: 13.h,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '属性',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.mutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        if (shortFields.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final halfWidth = (constraints.maxWidth - Spacing.md.w) / 2;
              return Wrap(
                spacing: Spacing.md.w,
                runSpacing: 0,
                children: shortFields
                    .map((f) => SizedBox(
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
                        ))
                    .toList(),
              );
            },
          ),
        ...longFields.map((f) {
          final isNeg = f.key == 'negativePrompt';
          return Padding(
            padding: EdgeInsets.only(top: isNeg ? Spacing.md.h : 0),
            child: PromptFieldWithAssistant(
              value: metaValues[f.key] ?? '',
              onChanged: (v) => onChanged(f.key, v),
              hint: isNeg
                  ? '不想出现的元素，如：模糊、变形、低质量…'
                  : (f.hint ?? '描述画面风格、色调、氛围…'),
              accent: accentColor,
              label: isNeg ? '反向提示词（选填）' : (f.label),
              negOnly: isNeg,
              maxLines: isNeg ? 2 : 3,
              onLibraryTap: openPromptLibrary,
              onSaveToLibrary: (text, name, {required bool isNegative}) async {
                await ref.read(resourceListProvider.notifier).addResource(
                      Resource(
                        name: name,
                        libraryType: 'prompt',
                        modality: 'text',
                        description: text,
                        metadataJson: isNegative
                            ? '{"negative": true}'
                            : '{}',
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
