part of 'review_editor.dart';

// ---------------------------------------------------------------------------
// 通用表单组件（section、readField、editField、dropdown 等）
// ---------------------------------------------------------------------------

Widget _section(String title, Widget child) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        const Divider(height: 1, color: AppColors.divider),
        Padding(padding: EdgeInsets.all(Spacing.lg.r), child: child),
      ],
    ),
  );
}

Widget _sectionHeader(String title, {Widget? trailing}) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.lg.w,
      vertical: Spacing.md.h,
    ),
    child: Row(
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        if (trailing != null) ...[SizedBox(width: Spacing.sm.w), trailing],
      ],
    ),
  );
}

Widget _readField(String label, String value, {bool fullWidth = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label.isNotEmpty)
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      if (label.isNotEmpty) SizedBox(height: Spacing.xs.h),
      Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.badgeGap.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          value.isNotEmpty ? value : '—',
          style: AppTextStyles.bodySmall.copyWith(
            color: value.isNotEmpty
                ? AppColors.onSurface
                : AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    ],
  );
}

Widget _readChip(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      SizedBox(height: Spacing.xs.h),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        ),
        child: Text(
          value.isNotEmpty ? value : '—',
          style: AppTextStyles.bodySmall.copyWith(
            color: value.isNotEmpty
                ? AppColors.onSurface
                : AppColors.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget _editField(
  String label,
  String value, {
  bool fullWidth = false,
  int maxLines = 1,
  Color? labelColor,
  ValueChanged<String>? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label.isNotEmpty)
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            color: labelColor ?? AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      if (label.isNotEmpty) SizedBox(height: Spacing.xs.h),
      SizedBox(
        width: fullWidth ? double.infinity : null,
        child: TextFormField(
          initialValue: value,
          maxLines: maxLines,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
          ),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

Widget _dropdown(
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
      Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      SizedBox(height: Spacing.xs.h),
      DropdownButtonFormField<String>(
        initialValue: effectiveValue,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant,
        ),
        dropdownColor: AppColors.surfaceContainer,
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

Widget _miniField(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      const SizedBox(height: Spacing.xs),
      Text(
        value.isNotEmpty ? value : '—',
        style: AppTextStyles.labelMedium.copyWith(
          color: value.isNotEmpty
              ? AppColors.onSurface.withValues(alpha: 0.75)
              : AppColors.onSurface.withValues(alpha: 0.4),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget _priorityBadge(String priority) {
  Color color;
  if (priority.contains('P0')) {
    color = AppColors.error;
  } else if (priority.contains('P1')) {
    color = AppColors.warning;
  } else {
    color = AppColors.onSurface;
  }
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.sm.w,
      vertical: Spacing.xs.h,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      priority,
      style: AppTextStyles.tiny.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _countBadge(int count) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.xs.w,
      vertical: Spacing.dividerHeight.h,
    ),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
    ),
    child: Text(
      '$count',
      style: AppTextStyles.tiny.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _enabledDot() {
  return Container(
    width: 6.w,
    height: 6.h,
    decoration: const BoxDecoration(
      color: AppColors.success,
      shape: BoxShape.circle,
    ),
  );
}
