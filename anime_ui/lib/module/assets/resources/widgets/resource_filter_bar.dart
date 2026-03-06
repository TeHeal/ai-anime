import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_search_field.dart';

import '../models/resource_meta_schema.dart';
import '../providers/provider.dart';

/// 素材库筛选栏：搜索、排序、元数据筛选、标签筛选
class ResourceFilterBar extends ConsumerStatefulWidget {
  const ResourceFilterBar({
    super.key,
    required this.accentColor,
  });

  final Color accentColor;

  @override
  ConsumerState<ResourceFilterBar> createState() => _ResourceFilterBarState();
}

class _ResourceFilterBarState extends ConsumerState<ResourceFilterBar> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchCtrl.text = ref.read(resourceSearchProvider);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearFilters() {
    ref.read(selectedTagsProvider.notifier).clear();
    ref.read(selectedMetaFiltersProvider.notifier).clear();
    ref.read(resourceSearchProvider.notifier).set('');
    _searchCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedLibraryTypeProvider, (previous, next) {
      _searchCtrl.clear();
      ref.read(resourceSearchProvider.notifier).set('');
    });

    final sort = ref.watch(resourceSortProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final metaFilters = ref.watch(selectedMetaFiltersProvider);
    final libraryType = ref.watch(selectedLibraryTypeProvider);
    final filterableFields =
        ResourceMetaSchema.filterableFields(libraryType);
    final availableMetaValues = ref.watch(availableMetaValuesProvider);
    final availableTags = ref.watch(availableTagsProvider);
    final searchState = ref.watch(resourceSearchProvider);

    if (searchState.isEmpty && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
    }

    final hasActiveFilters = ref.watch(hasActiveFiltersProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppSearchField(
                controller: _searchCtrl,
                hintText: '搜索素材名称或标签…',
                width: 240.w,
                height: 36.h,
                accentColor: widget.accentColor,
                fillColor: AppColors.inputFill,
                onChanged: (v) =>
                    ref.read(resourceSearchProvider.notifier).set(v),
              ),
              SizedBox(width: Spacing.sm.w),
              _SortDropdown(
                sort: sort,
                accentColor: widget.accentColor,
                onChanged: (s) =>
                    ref.read(resourceSortProvider.notifier).set(s),
              ),
              if (hasActiveFilters) ...[
                SizedBox(width: Spacing.sm.w),
                _ClearFiltersButton(
                  count: selectedTags.length + metaFilters.length,
                  accentColor: widget.accentColor,
                  onClear: _clearFilters,
                ),
              ],
              const Spacer(),
            ],
          ),
          if (filterableFields.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            _MetaFilterRow(
              fields: filterableFields,
              metaFilters: metaFilters,
              availableValues: availableMetaValues,
              accentColor: widget.accentColor,
              onFilterTap: (key, value) {
                ref.read(selectedMetaFiltersProvider.notifier).set(key, value);
              },
            ),
          ],
          if (availableTags.isNotEmpty) ...[
            SizedBox(height: Spacing.xs.h),
            Wrap(
              spacing: Spacing.iconGapSm.w,
              runSpacing: Spacing.iconGapSm.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: Spacing.xxs.w,
                    top: Spacing.xxs.h,
                  ),
                  child: Text(
                    '标签:',
                    style: AppTextStyles.tiny.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                ...availableTags.map((tag) {
                  final selected = selectedTags.contains(tag);
                  return FilterChip(
                    selected: selected,
                    label: Text(
                      tag,
                      style: AppTextStyles.tiny.copyWith(
                        color: selected
                            ? AppColors.onSurface
                            : AppColors.mutedLight,
                      ),
                    ),
                    backgroundColor: AppColors.inputFill,
                    selectedColor: widget.accentColor.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: selected
                          ? widget.accentColor
                          : AppColors.chipBorderHover,
                    ),
                    checkmarkColor: widget.accentColor,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onSelected: (_) {
                      ref.read(selectedTagsProvider.notifier).toggle(tag);
                    },
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 清除筛选按钮，带 hover 态
class _ClearFiltersButton extends StatefulWidget {
  const _ClearFiltersButton({
    required this.count,
    required this.accentColor,
    required this.onClear,
  });

  final int count;
  final Color accentColor;
  final VoidCallback onClear;

  @override
  State<_ClearFiltersButton> createState() => _ClearFiltersButtonState();
}

class _ClearFiltersButtonState extends State<_ClearFiltersButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onClear,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: Spacing.chipPaddingH.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(
              alpha: _hovered ? 0.18 : 0.1,
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: widget.accentColor.withValues(
                alpha: _hovered ? 0.5 : 0.3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.close,
                size: 14.r,
                color: widget.accentColor,
              ),
              SizedBox(width: Spacing.xxs.w),
              Text(
                '清除筛选 (${widget.count})',
                style: AppTextStyles.caption.copyWith(
                  color: widget.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatefulWidget {
  const _SortDropdown({
    required this.sort,
    required this.accentColor,
    required this.onChanged,
  });

  final ResourceSort sort;
  final Color accentColor;
  final ValueChanged<ResourceSort> onChanged;

  @override
  State<_SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<_SortDropdown> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: PopupMenuButton<ResourceSort>(
        onSelected: widget.onChanged,
        color: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.chipBgHover
                : AppColors.inputFill,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: _hovered
                  ? AppColors.chipBorderHover
                  : AppColors.inputBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.sort.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(width: Spacing.xxs.w),
              Icon(
                Icons.arrow_drop_down,
                size: Spacing.menuIconSize.r,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
        itemBuilder: (_) => ResourceSort.values
            .map(
              (s) => PopupMenuItem(
                value: s,
                child: Row(
                  children: [
                    Icon(
                      s.sortIcon,
                      size: 14.r,
                      color: s == widget.sort
                          ? widget.accentColor
                          : AppColors.muted,
                    ),
                    SizedBox(width: Spacing.iconGapSm.w),
                    Text(
                      s.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: s == widget.sort
                            ? widget.accentColor
                            : AppColors.onSurface,
                        fontWeight: s == widget.sort
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MetaFilterRow extends StatelessWidget {
  const _MetaFilterRow({
    required this.fields,
    required this.metaFilters,
    required this.availableValues,
    required this.accentColor,
    required this.onFilterTap,
  });

  final List<MetaFieldDef> fields;
  final Map<String, String> metaFilters;
  final Map<String, List<String>> availableValues;
  final Color accentColor;
  final void Function(String key, String value) onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < fields.length; i++) ...[
            if (i > 0)
              Container(
                width: Spacing.dividerHeight.w,
                height: Spacing.menuIconSize.h,
                margin: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                color: AppColors.divider,
              ),
            _MetaFieldFilterGroup(
              field: fields[i],
              activeValue: metaFilters[fields[i].key],
              options: availableValues[fields[i].key] ?? fields[i].options ?? [],
              accentColor: accentColor,
              onFilterTap: onFilterTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaFieldFilterGroup extends StatelessWidget {
  const _MetaFieldFilterGroup({
    required this.field,
    required this.activeValue,
    required this.options,
    required this.accentColor,
    required this.onFilterTap,
  });

  final MetaFieldDef field;
  final String? activeValue;
  final List<String> options;
  final Color accentColor;
  final void Function(String key, String value) onFilterTap;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: Spacing.iconGapSm.w),
          child: Text(
            '${field.label}:',
            style: AppTextStyles.tiny.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...options.map((opt) {
          return Padding(
            padding: EdgeInsets.only(right: Spacing.xs.w),
            child: _FilterOptionChip(
              label: opt,
              active: opt == activeValue,
              accentColor: accentColor,
              onTap: () => onFilterTap(field.key, opt),
            ),
          );
        }),
      ],
    );
  }
}

/// 筛选选项 Chip，带 hover 态（对齐原版样式）
class _FilterOptionChip extends StatefulWidget {
  const _FilterOptionChip({
    required this.label,
    required this.active,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_FilterOptionChip> createState() => _FilterOptionChipState();
}

class _FilterOptionChipState extends State<_FilterOptionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: widget.active
                ? widget.accentColor.withValues(alpha: 0.18)
                : (_hovered
                    ? AppColors.chipBgHover
                    : AppColors.inputFill),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: widget.active
                  ? widget.accentColor.withValues(alpha: 0.6)
                  : (_hovered
                      ? AppColors.chipBorderHover
                      : AppColors.inputBorder),
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.tiny.copyWith(
              color: widget.active
                  ? widget.accentColor
                  : AppColors.mutedLight,
              fontWeight:
                  widget.active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
