part of 'review_editor.dart';

// ---------------------------------------------------------------------------
// 原子级 UI 组件
// ---------------------------------------------------------------------------

/// 预览模式下的图标 + 值胶囊
Widget _iconChip(IconData icon, String value) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.chipPaddingH.w,
      vertical: Spacing.chipPaddingV.h,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
      border: Border.all(
        color: AppColors.border.withValues(alpha: 0.5),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.r, color: AppColors.muted),
        SizedBox(width: Spacing.xs.w),
        Text(
          value.isNotEmpty ? value : '—',
          style: AppTextStyles.labelMedium.copyWith(
            color: value.isNotEmpty ? AppColors.onSurface : AppColors.mutedDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// 只读属性展示（编辑模式下的时间轴等不可编辑字段）
Widget _readOnlyChip(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: AppTextStyles.tiny.copyWith(color: AppColors.muted)),
      SizedBox(height: Spacing.xs.h),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        ),
        child: Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mutedLight,
          ),
        ),
      ),
    ],
  );
}

/// 紧凑编辑输入框
Widget _compactField(
  String label,
  String value, {
  ValueChanged<String>? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: AppTextStyles.tiny.copyWith(color: AppColors.muted)),
      SizedBox(height: Spacing.xs.h),
      TextFormField(
        initialValue: value,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
        ),
        onChanged: onChanged,
      ),
    ],
  );
}

/// 紧凑下拉选择
Widget _compactDropdown(
  String label,
  String value,
  List<String> options, {
  ValueChanged<String>? onChanged,
}) {
  final effectiveValue = options.contains(value) ? value : null;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: AppTextStyles.tiny.copyWith(color: AppColors.muted)),
      SizedBox(height: Spacing.xs.h),
      DropdownButtonFormField<String>(
        initialValue: effectiveValue,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
        ),
        dropdownColor: AppColors.surfaceContainerHighest,
        items: options
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o, style: AppTextStyles.labelMedium),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged?.call(v);
        },
      ),
    ],
  );
}

/// 带左侧装饰线的文本输入区——编辑和预览共享视觉
Widget _accentTextBlock({
  required String value,
  required bool editing,
  required Color accentColor,
  String hint = '',
  int maxLines = 3,
  ValueChanged<String>? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(color: accentColor, width: 3),
      ),
    ),
    child: Container(
      width: double.infinity,
      padding: editing
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: Spacing.md.w, vertical: Spacing.md.h),
      margin: EdgeInsets.only(left: 1.w),
      decoration: BoxDecoration(
        color: editing
            ? AppColors.inputBackground
            : accentColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(RadiusTokens.md.r),
        ),
      ),
      child: editing
          ? TextFormField(
              initialValue: value,
              maxLines: maxLines,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                height: 1.6,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedDarker,
                ),
                contentPadding: EdgeInsets.all(Spacing.md.r),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            )
          : Text(
              value.isNotEmpty ? value : '—',
              style: AppTextStyles.bodySmall.copyWith(
                color: value.isNotEmpty
                    ? AppColors.onSurface
                    : AppColors.mutedDarker,
                height: 1.6,
              ),
            ),
    ),
  );
}

/// 行内带图标标签 + 装饰线文本块
Widget _labeledBlock({
  required IconData icon,
  required String label,
  required String value,
  required bool editing,
  Color accentColor = AppColors.muted,
  String hint = '',
  int maxLines = 1,
  ValueChanged<String>? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Icon(icon, size: 12.r, color: accentColor),
          SizedBox(width: Spacing.xs.w),
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      SizedBox(height: Spacing.xs.h),
      _accentTextBlock(
        value: value,
        editing: editing,
        accentColor: accentColor,
        hint: hint,
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    ],
  );
}

/// 优先级徽章
Widget _priorityBadge(String priority) {
  Color color;
  if (priority.contains('P0')) {
    color = AppColors.error;
  } else if (priority.contains('P1')) {
    color = AppColors.warning;
  } else {
    color = AppColors.muted;
  }
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.sm.w,
      vertical: Spacing.xxs.h,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      priority,
      style: AppTextStyles.tiny.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  );
}
