import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/data/preset_styles_data.dart';
import 'package:anime_ui/pub/models/style.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/image_lightbox.dart';
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/resources/widgets/empty_guide_card.dart';

import 'providers/styles.dart';
import 'widgets/style_toolbar.dart';
import 'widgets/preset_style_section.dart';

/// 风格库页面：自定义风格网格 + 精选预设风格
class StyleLibraryPage extends ConsumerStatefulWidget {
  const StyleLibraryPage({super.key});

  @override
  ConsumerState<StyleLibraryPage> createState() => _StyleLibraryPageState();
}

class _StyleLibraryPageState extends ConsumerState<StyleLibraryPage> {
  static const _accent = AppColors.primary;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(assetStylesProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final asyncStyles = ref.watch(assetStylesProvider);

    return asyncStyles.when(
      loading: () => Column(
        children: [
          StyleToolbar(onUpload: () => showStyleFormDialog(context, ref)),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
      error: (e, _) => Column(
        children: [
          StyleToolbar(onUpload: () => showStyleFormDialog(context, ref)),
          Expanded(
            child: Center(
              child: Text(
                '加载失败: $e',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
      data: (styles) {
        final defaultStyle =
            styles.where((s) => s.isProjectDefault).firstOrNull;
        final nameSearch =
            ref.watch(styleNameSearchProvider).trim().toLowerCase();
        final filteredStyles = nameSearch.isEmpty
            ? styles
            : styles
                .where((s) => s.name.toLowerCase().contains(nameSearch))
                .toList();

        return Column(
          children: [
            StyleToolbar(onUpload: () => showStyleFormDialog(context, ref)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Spacing.xl.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomStyleGrid(filteredStyles, defaultStyle),
                    if (defaultStyle != null) ...[
                      SizedBox(height: Spacing.lg.h),
                      _buildCurrentStyleDetail(defaultStyle),
                    ],
                    SizedBox(height: Spacing.xxl.h),
                    PresetStyleSection(existingStyles: styles),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── 工具方法 ──

  List<String> _parseRefImages(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => (e as Map<String, dynamic>)['url'] as String? ?? '')
          .where((u) => u.isNotEmpty)
          .map(resolveFileUrl)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 通过风格名称查找本地预设缩略图 asset 路径，未找到返回 null
  String? _findPresetThumbAsset(Style style) {
    if (!style.isPreset) return null;
    final match = kPresetStyles
        .where((p) => p.name == style.name)
        .firstOrNull;
    return match?.thumbnailPath;
  }

  /// 风格缩略图，[size] 和 [radius] 需传入 ScreenUtil 缩放值（如 44.r）
  Widget _styleThumbnail(
    Style style, {
    required double size,
    required double radius,
  }) {
    // 预设风格优先使用本地 asset 缩略图
    final localThumb = _findPresetThumbAsset(style);
    if (localThumb != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            localThumb,
            fit: BoxFit.cover,
            cacheWidth: (size * 2).round(),
            errorBuilder: (_, __, ___) => _iconPlaceholder(size, radius),
          ),
        ),
      );
    }

    final urls = _parseRefImages(style.referenceImagesJson);
    final thumb = style.thumbnailUrl.isNotEmpty
        ? resolveFileUrl(style.thumbnailUrl)
        : (urls.isNotEmpty ? resolveFileUrl(urls.first) : null);

    if (thumb != null && thumb.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            thumb,
            fit: BoxFit.cover,
            cacheWidth: (size * 2).round(),
            errorBuilder: (_, __, ___) => _iconPlaceholder(size, radius),
          ),
        ),
      );
    }
    return _iconPlaceholder(size, radius);
  }

  /// 图标占位，[size] 和 [radius] 需传入 ScreenUtil 缩放值
  Widget _iconPlaceholder(double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedDark,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        AppIcons.brush,
        size: size * 0.45,
        color: AppColors.muted,
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

  // ── 当前风格详情面板 ──

  Widget _buildCurrentStyleDetail(Style style) {
    final refUrls = _parseRefImages(style.referenceImagesJson);
    final localThumb = _findPresetThumbAsset(style);

    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _styleThumbnail(style, size: 44.r, radius: 10.r),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前统一风格',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      style.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _buildApplyAllButton(style),
            ],
          ),
          if (style.description.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Text(
              style.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.muted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (refUrls.isNotEmpty || localThumb != null) ...[
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              height: 56.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: localThumb != null && refUrls.isEmpty
                    ? 1
                    : refUrls.length,
                separatorBuilder: (_, __) => SizedBox(width: Spacing.xs.w),
                itemBuilder: (_, i) {
                  if (localThumb != null && refUrls.isEmpty) {
                    return _buildDetailThumbAsset(localThumb, 56.h);
                  }
                  return _buildDetailThumbNetwork(refUrls[i], 56.h);
                },
              ),
            ),
          ],
          SizedBox(height: Spacing.xs.h),
          Text(
            '角色 · 场景 · 道具  全部跟随此风格',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyAllButton(Style style) {
    return InkWell(
      onTap: () async {
        if (style.id == null) return;
        final count = await ref
            .read(assetStylesProvider.notifier)
            .applyAll(style.id!);
        if (!mounted) return;
        showToast(context, '已应用到 $count 个资产');
      },
      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xs.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.check, size: 14.r, color: _accent),
            SizedBox(width: Spacing.xxs.w),
            Text(
              '应用到所有资产',
              style: AppTextStyles.caption.copyWith(
                color: _accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailThumbAsset(String assetPath, double size) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            cacheWidth: (size * 2).round(),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailThumbNetwork(String url, double size) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showImageLightbox(context, imageUrl: url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          child: SizedBox(
            width: size,
            height: size,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              cacheWidth: (size * 2).round(),
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  // ── 自定义风格网格 ──

  Widget _buildCustomStyleGrid(List<Style> allStyles, Style? defaultStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '画面风格',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        SizedBox(height: Spacing.lg.h),
        if (allStyles.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: Spacing.emptyStatePadding.h),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(Spacing.xl.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      _accent.withValues(alpha: 0.1),
                      _accent.withValues(alpha: 0.02),
                    ]),
                  ),
                  child: Icon(
                    AppIcons.brush,
                    size: 36.r,
                    color: _accent.withValues(alpha: 0.4),
                  ),
                ),
                SizedBox(height: Spacing.lg.h),
                Text(
                  '还没有添加风格',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Spacing.xs.h),
                Text(
                  '从下方预设中选择，或上传/AI 生成添加',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
                SizedBox(height: Spacing.xl.h),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: Spacing.md.w,
                  runSpacing: Spacing.md.h,
                  children: [
                    EmptyGuideCard(
                      icon: AppIcons.upload,
                      label: '上传风格图',
                      accent: _accent,
                      onTap: () => showStyleFormDialog(context, ref),
                    ),
                    EmptyGuideCard(
                      icon: AppIcons.magicStick,
                      label: 'AI 生成',
                      accent: _accent,
                      filled: true,
                      onTap: () => ImageGenDialog.show(
                        context,
                        ref,
                        config: buildStyleImageGenConfig(ref),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: Spacing.md.w,
            runSpacing: Spacing.md.h,
            children: allStyles
                .map((s) => _buildStyleCard(s, defaultStyle))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildStyleCard(Style style, Style? defaultStyle) {
    final selected = defaultStyle?.id == style.id;
    final isCustom = !style.isPreset;

    return GestureDetector(
      onTap: selected
          ? null
          : () async {
              await ref
                  .read(assetStylesProvider.notifier)
                  .setDefault(style.id!);
              if (!mounted) return;
              showToast(context, '已切换为「${style.name}」');
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 160.w,
        decoration: BoxDecoration(
          color: selected
              ? _accent.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
          border: Border.all(
            color: selected ? _accent : AppColors.border,
            width: selected ? 2 : 1,
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
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      color: AppColors.backgroundDarkest,
                      child: _styleCardImage(style),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: Spacing.xs.h,
                    right: Spacing.xs.w,
                    child: Container(
                      padding: EdgeInsets.all(Spacing.xxs.r),
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14.r,
                        color: AppColors.onPrimary,
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
                    style.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? _accent : AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCustom && style.id != null) ...[
                    SizedBox(height: Spacing.xs.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => showStyleFormDialog(context, ref,
                              existing: style),
                          child: Icon(
                            AppIcons.edit,
                            size: 14.r,
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(width: Spacing.md.w),
                        InkWell(
                          onTap: () async {
                            final ok = await showConfirmDeleteDialog(
                              context,
                              title: '删除风格',
                              content: '确定要删除「${style.name}」吗？此操作不可撤销。',
                            );
                            if (ok == true) {
                              ref
                                  .read(assetStylesProvider.notifier)
                                  .remove(style.id!);
                            }
                          },
                          child: Icon(
                            AppIcons.delete,
                            size: 14.r,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styleCardImage(Style style) {
    // 预设风格优先使用本地 asset 缩略图
    final localThumb = _findPresetThumbAsset(style);
    if (localThumb != null) {
      return Image.asset(
        localThumb,
        fit: BoxFit.cover,
        cacheWidth: 320,
        errorBuilder: (_, __, ___) => _cardPlaceholder(),
      );
    }

    final urls = _parseRefImages(style.referenceImagesJson);
    final thumb = style.thumbnailUrl.isNotEmpty
        ? resolveFileUrl(style.thumbnailUrl)
        : (urls.isNotEmpty ? urls.first : null);

    if (thumb != null && thumb.isNotEmpty) {
      return Image.network(
        thumb,
        fit: BoxFit.cover,
        cacheWidth: 320,
        errorBuilder: (_, __, ___) => _cardPlaceholder(),
      );
    }
    return _cardPlaceholder();
  }
}
