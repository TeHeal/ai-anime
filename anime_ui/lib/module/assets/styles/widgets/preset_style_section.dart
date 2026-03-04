import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/data/preset_styles_data.dart';
import 'package:anime_ui/pub/models/style.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

import '../providers/styles.dart';

/// 精选预设风格区域：分类筛选 + 预设卡片网格
class PresetStyleSection extends ConsumerStatefulWidget {
  const PresetStyleSection({super.key, required this.existingStyles});

  final List<Style> existingStyles;

  @override
  ConsumerState<PresetStyleSection> createState() => _PresetStyleSectionState();
}

class _PresetStyleSectionState extends ConsumerState<PresetStyleSection> {
  static const _accent = AppColors.primary;
  String? _selectedCategory;
  bool _applying = false;

  @override
  Widget build(BuildContext context) {
    final existingNames = widget.existingStyles.map((s) => s.name).toSet();
    final filteredPresets = _selectedCategory == null
        ? kPresetStyles
        : kPresetStyles
            .where((p) => p.category == _selectedCategory)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '精选预设风格',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        SizedBox(height: Spacing.xs.h),
        Text(
          '点击预设风格可添加到项目中使用',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
        ),
        SizedBox(height: Spacing.lg.h),
        _buildCategoryTabs(),
        SizedBox(height: Spacing.lg.h),
        Wrap(
          spacing: Spacing.md.w,
          runSpacing: Spacing.md.h,
          children: filteredPresets
              .map((p) =>
                  _buildPresetCard(p, existingNames.contains(p.name)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip(null, '全部'),
          ...kPresetCategories.map((c) => _buildCategoryChip(c, c)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final selected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: Spacing.sm.w),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: _accent.withValues(alpha: 0.2),
        checkmarkColor: _accent,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: selected ? _accent : AppColors.mutedLight,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected
              ? _accent.withValues(alpha: 0.4)
              : AppColors.chipBorderHover,
        ),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  Widget _buildPresetCard(PresetStyle preset, bool alreadyAdded) {
    return GestureDetector(
      onTap: alreadyAdded || _applying
          ? null
          : () => _addPresetToProject(preset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 150.w,
        decoration: BoxDecoration(
          color: alreadyAdded
              ? _accent.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
          border: Border.all(
            color: alreadyAdded
                ? _accent.withValues(alpha: 0.4)
                : AppColors.border,
            width: alreadyAdded ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(RadiusTokens.lg.r),
                  ),
                  child: SizedBox(
                    width: 150.w,
                    height: 110.h,
                    child: Image.asset(
                      preset.thumbnailPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e1, s1) => Image.asset(
                        preset.assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, e2, s2) => _cardPlaceholder(),
                      ),
                    ),
                  ),
                ),
                if (alreadyAdded)
                  Positioned(
                    top: Spacing.xs.h,
                    right: Spacing.xs.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.inputGapSm.w,
                        vertical: Spacing.xxs.h,
                      ),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius:
                            BorderRadius.circular(RadiusTokens.sm.r),
                      ),
                      child: Text(
                        '已添加',
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.sm.h,
              ),
              child: Column(
                children: [
                  Text(
                    preset.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: alreadyAdded ? _accent : AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Spacing.xs.h),
                  Text(
                    preset.description,
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.muted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardPlaceholder() {
    return Container(
      color: AppColors.surfaceMutedDark,
      child: Center(
        child: Icon(
          AppIcons.brush,
          size: 32.r,
          color: AppColors.muted,
        ),
      ),
    );
  }

  Future<void> _addPresetToProject(PresetStyle preset) async {
    setState(() => _applying = true);
    try {
      final bytes = await rootBundle.load(preset.assetPath);
      final fileBytes = bytes.buffer.asUint8List();
      final filename = preset.assetPath.split('/').last;

      final svc = FileService();
      final url = await svc.upload(
        fileBytes,
        filename,
        category: 'style_reference',
      );

      final refJson = jsonEncode([
        {'url': url}
      ]);

      ref.read(assetStylesProvider.notifier).add(Style(
            name: preset.name,
            description: preset.description,
            referenceImagesJson: refJson,
            thumbnailUrl: url,
            isPreset: true,
          ));

      if (mounted) {
        showToast(context, '已添加风格「${preset.name}」');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, '添加失败: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }
}
