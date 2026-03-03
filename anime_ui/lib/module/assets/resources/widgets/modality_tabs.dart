import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';

/// 素材库模态 Tab：视觉 / 音频 / 文本
class ModalityTabs extends ConsumerWidget {
  const ModalityTabs({super.key, required this.modality});

  final ResourceModality modality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          ...ResourceModality.values.map((m) {
            final selected = m == modality;
            return Padding(
              padding: EdgeInsets.only(right: Spacing.sm.w),
              child: FilterChip(
                selected: selected,
                label: Text(m.label),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: selected ? AppColors.onSurface : AppColors.muted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: AppColors.surfaceMutedDark,
                selectedColor: m.color.withValues(alpha: 0.2),
                side: BorderSide(
                  color: selected ? m.color : AppColors.inputBorder,
                ),
                checkmarkColor: m.color,
                onSelected: (_) {
                  ref.read(selectedModalityProvider.notifier).set(m);
                  final libs = ResourceLibraryType.forModalityInResources(m);
                  ref.read(selectedLibraryTypeProvider.notifier).set(libs.first);
                  ref.read(resourceSearchProvider.notifier).set('');
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
