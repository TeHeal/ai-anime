import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

const _timeOptions = ['日', '夜', '黄昏', '凌晨'];
const _ieOptions = ['内', '外'];

/// 场景元信息编辑区：编号、地点、时间、内外、角色
class SceneEditorMetadata extends StatelessWidget {
  const SceneEditorMetadata({
    super.key,
    required this.sceneIdCtrl,
    required this.locationCtrl,
    required this.time,
    required this.ie,
    required this.characters,
    required this.characterCtrl,
    required this.onTimeChanged,
    required this.onIeChanged,
    required this.onAddCharacter,
    required this.onRemoveCharacter,
    required this.onMarkDirty,
  });

  final TextEditingController sceneIdCtrl;
  final TextEditingController locationCtrl;
  final String time;
  final String ie;
  final List<String> characters;
  final TextEditingController characterCtrl;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onIeChanged;
  final VoidCallback onAddCharacter;
  final ValueChanged<String> onRemoveCharacter;
  final VoidCallback onMarkDirty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '场景信息',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        Row(
          children: [
            SizedBox(width: 100.w, child: _field('场景编号', sceneIdCtrl)),
            SizedBox(width: Spacing.md.w),
            Expanded(child: _field('地点', locationCtrl)),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        Row(
          children: [
            _dropdown('时间', time, _timeOptions, (v) {
              onTimeChanged(v);
              onMarkDirty();
            }),
            SizedBox(width: Spacing.md.w),
            _dropdown('内/外', ie, _ieOptions, (v) {
              onIeChanged(v);
              onMarkDirty();
            }),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        Text(
          '角色',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mutedDarkest,
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.sm.h,
          children: [
            for (final c in characters)
              Chip(
                label: Text(
                  c,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                backgroundColor: AppColors.divider,
                deleteIconColor: AppColors.mutedDarkest,
                onDeleted: () => onRemoveCharacter(c),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            SizedBox(
              width: 120.w,
              height: 32.h,
              child: TextField(
                controller: characterCtrl,
                onSubmitted: (_) => onAddCharacter(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '添加角色…',
                  hintStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedDarkest,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.sm.h,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(AppIcons.add, size: 16.r),
                    color: AppColors.primary,
                    onPressed: onAddCharacter,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24.w,
                      minHeight: 24.h,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => onMarkDirty(),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.mutedDarkest,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.mutedDarkest),
        ),
        SizedBox(height: Spacing.xs.h),
        Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              hint: Text(
                '选择$label',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedDarkest,
                ),
              ),
              isDense: true,
              dropdownColor: AppColors.surfaceContainerHigh,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
