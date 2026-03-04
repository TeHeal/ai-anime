import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';
import '../models/resource_meta_schema.dart';
import 'meta_field_editor.dart';

/// 素材表单 – 名称和描述输入字段
class ResourceBasicFields extends StatelessWidget {
  const ResourceBasicFields({
    super.key,
    required this.nameController,
    required this.descController,
    required this.accentColor,
    required this.libraryType,
  });

  final TextEditingController nameController;
  final TextEditingController descController;
  final Color accentColor;
  final ResourceLibraryType libraryType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '名称',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: nameController,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: '输入素材名称',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.inputBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              borderSide: BorderSide(color: accentColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
        SizedBox(height: Spacing.md.h),
        Text(
          '描述',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: descController,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: libraryType == ResourceLibraryType.prompt
                ? '输入提示词内容…'
                : '输入素材描述…',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.inputBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              borderSide: BorderSide(color: accentColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
        SizedBox(height: Spacing.lg.h),
      ],
    );
  }
}

/// 素材表单 – 标签编辑区
class ResourceTagEditor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          constraints: BoxConstraints(minHeight: 38.h),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Wrap(
            spacing: Spacing.xs.w,
            runSpacing: Spacing.xs.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...tags.map((tag) => Chip(
                    label: Text(tag, style: AppTextStyles.caption),
                    deleteIcon:
                        Icon(AppIcons.close, size: 14.r, color: accentColor),
                    onDeleted: () => onTagRemoved(tag),
                    backgroundColor: accentColor.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: accentColor.withValues(alpha: 0.2),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )),
              SizedBox(
                width: 140.w,
                height: 28.h,
                child: TextField(
                  controller: tagInputController,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText:
                        tags.isEmpty ? '输入标签后按回车添加' : '添加更多…',
                    hintStyle: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.mutedDark),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: Spacing.xs.w),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: onTagAdded,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Spacing.lg.h),
      ],
    );
  }
}

/// 素材表单 – 属性（Schema）编辑区
class ResourceSchemaSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 14.h,
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
        ...longFields.map((f) => MetaFieldEditor(
              field: f,
              value: metaValues[f.key] ?? '',
              accentColor: accentColor,
              extraOptions: availableValues?[f.key],
              onChanged: (v) => onChanged(f.key, v),
            )),
      ],
    );
  }
}
