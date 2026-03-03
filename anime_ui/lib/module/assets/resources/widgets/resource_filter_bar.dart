import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

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

    final hasActiveFilters =
        selectedTags.isNotEmpty || metaFilters.isNotEmpty;

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
              SizedBox(
                width: 240.w,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: '搜索素材名称或标签…',
                    hintStyle:
                        AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                    prefixIcon: Icon(
                      AppIcons.search,
                      size: 18.r,
                      color: AppColors.muted,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(RadiusTokens.sm.r),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Spacing.md.w,
                      vertical: Spacing.sm.h,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                  onChanged: (v) =>
                      ref.read(resourceSearchProvider.notifier).set(v),
                ),
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
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(RadiusTokens.sm.r),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.3),
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
                          '清除筛选 (${selectedTags.length + metaFilters.length})',
                          style: AppTextStyles.caption.copyWith(
                            color: widget.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              spacing: Spacing.xs.w,
              runSpacing: Spacing.xs.h,
              children: availableTags.map((tag) {
                final selected = selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedTagsProvider.notifier).toggle(tag);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.xxs.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? widget.accentColor.withValues(alpha: 0.15)
                          : AppColors.surfaceMutedDark,
                      borderRadius:
                          BorderRadius.circular(RadiusTokens.xs.r),
                      border: Border.all(
                        color: selected
                            ? widget.accentColor.withValues(alpha: 0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.caption.copyWith(
                        color: selected
                            ? widget.accentColor
                            : AppColors.mutedLight,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.sort,
    required this.accentColor,
    required this.onChanged,
  });

  final ResourceSort sort;
  final Color accentColor;
  final ValueChanged<ResourceSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ResourceSort>(
      onSelected: onChanged,
      color: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sort.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(width: Spacing.xxs.w),
            Icon(Icons.arrow_drop_down, size: 18.r, color: AppColors.muted),
          ],
        ),
      ),
      itemBuilder: (_) => ResourceSort.values
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(
                s.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: s == sort ? accentColor : AppColors.onSurface,
                  fontWeight: s == sort ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
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
    return Wrap(
      spacing: Spacing.md.w,
      runSpacing: Spacing.sm.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: fields.map((field) {
        final options = availableValues[field.key] ?? [];
        if (options.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: Spacing.xs.w,
          runSpacing: Spacing.xxs.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${field.label}:',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.muted,
              ),
            ),
            SizedBox(width: Spacing.xxs.w),
            ...options.map((opt) {
              final isActive = metaFilters[field.key] == opt;
              return GestureDetector(
                onTap: () => onFilterTap(field.key, opt),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor.withValues(alpha: 0.15)
                        : AppColors.surfaceMutedDark,
                    borderRadius:
                        BorderRadius.circular(RadiusTokens.xs.r),
                    border: Border.all(
                      color: isActive
                          ? accentColor.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? accentColor
                          : AppColors.mutedLight,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}
