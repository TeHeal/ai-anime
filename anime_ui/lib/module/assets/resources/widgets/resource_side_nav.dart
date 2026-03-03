import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import '../models/resource_category.dart';
import '../providers/provider.dart';

/// 素材库侧边导航：按模态展示子库类型列表（风格已合并到顶级 Tab，不在此展示）
class ResourceSideNav extends ConsumerWidget {
  const ResourceSideNav({super.key, required this.modality});

  final ResourceModality modality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ResourceLibraryType.forModalityInResources(modality);
    final selected = ref.watch(selectedLibraryTypeProvider);
    final allResources = ref.watch(resourceListProvider).value ?? [];

    return Container(
      width: Spacing.listPanelMinWidth.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(
          vertical: Spacing.md.h,
          horizontal: Spacing.sm.w,
        ),
        children: libraries.map((lib) {
          final isSelected = lib == selected;
          final count = allResources.where((r) => r.libraryType == lib.name).length;

          return Padding(
            padding: EdgeInsets.only(bottom: Spacing.xxs.h),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                onTap: () {
                  ref.read(selectedLibraryTypeProvider.notifier).set(lib);
                  ref.read(resourceSearchProvider.notifier).set('');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? modality.color.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        lib.icon,
                        size: Spacing.menuIconSize.r,
                        color: isSelected
                            ? modality.color
                            : AppColors.muted,
                      ),
                      SizedBox(width: Spacing.iconGapMd.w),
                      Expanded(
                        child: Text(
                          lib.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected
                                ? modality.color
                                : AppColors.mutedLight,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.inputGapSm.w,
                          vertical: Spacing.xxs.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? modality.color.withValues(alpha: 0.15)
                              : AppColors.surfaceMutedDark,
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.xs.r),
                        ),
                        child: Text(
                          '$count',
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? modality.color
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
