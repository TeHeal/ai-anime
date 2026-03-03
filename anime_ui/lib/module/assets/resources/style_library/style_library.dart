import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/style.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

import '../../overview/providers/styles.dart';

/// 风格库视图：自定义风格网格、默认风格
class StyleLibraryView extends ConsumerStatefulWidget {
  const StyleLibraryView({super.key});

  @override
  ConsumerState<StyleLibraryView> createState() => _StyleLibraryViewState();
}

class _StyleLibraryViewState extends ConsumerState<StyleLibraryView> {
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          '加载失败: $e',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
      data: (styles) {
        final defaultStyle =
            styles.where((s) => s.isProjectDefault).firstOrNull;

        return SingleChildScrollView(
          padding: EdgeInsets.all(Spacing.xl.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomStyleGrid(styles, defaultStyle),
              SizedBox(height: Spacing.xxl.h),
              _buildCurrentStyle(defaultStyle),
            ],
          ),
        );
      },
    );
  }

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

  Widget _styleThumbnail(Style style, {double size = 48, double radius = 10}) {
    final urls = _parseRefImages(style.referenceImagesJson);
    final thumb = style.thumbnailUrl.isNotEmpty
        ? resolveFileUrl(style.thumbnailUrl)
        : (urls.isNotEmpty ? resolveFileUrl(urls.first) : null);

    if (thumb != null && thumb.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: SizedBox(
          width: size.r,
          height: size.r,
          child: Image.network(
            thumb,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _iconPlaceholder(size, radius),
          ),
        ),
      );
    }
    return _iconPlaceholder(size, radius);
  }

  Widget _iconPlaceholder(double size, double radius) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedDark,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Icon(
        AppIcons.brush,
        size: (size * 0.45).r,
        color: AppColors.muted,
      ),
    );
  }

  Widget _buildCurrentStyle(Style? defaultStyle) {
    if (defaultStyle == null) return const SizedBox.shrink();

    final refUrls = _parseRefImages(defaultStyle.referenceImagesJson);

    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _styleThumbnail(defaultStyle, size: 44, radius: 10),
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
                    SizedBox(height: Spacing.xxs.h),
                    Text(
                      defaultStyle.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  if (defaultStyle.id == null) return;
                  final count = await ref
                      .read(assetStylesProvider.notifier)
                      .applyAll(defaultStyle.id!);
                  if (!mounted) return;
                  showToast(context, '已应用到 $count 个资产');
                },
                icon: Icon(AppIcons.check, size: 14.r),
                label: const Text('应用到所有资产'),
              ),
            ],
          ),
          if (defaultStyle.description.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Text(
              defaultStyle.description,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (refUrls.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              height: 56.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: refUrls.length,
                separatorBuilder: (_, __) => SizedBox(width: Spacing.xs.w),
                itemBuilder: (_, i) => SizedBox(
                  width: 56.w,
                  child: GestureDetector(
                    onTap: () => _openLightbox(context, refUrls[i]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                      child: Image.network(
                        refUrls[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _iconPlaceholder(56, 6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: Spacing.sm.h),
          Text(
            '角色 · 场景 · 道具  全部跟随此风格',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  void _openLightbox(BuildContext context, String url) {
    // 简化：暂不实现大图预览，可后续接入 ImageLightbox
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

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
            padding: EdgeInsets.symmetric(vertical: Spacing.xxl.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  AppIcons.brush,
                  size: 40.r,
                  color: AppColors.muted,
                ),
                SizedBox(height: Spacing.md.h),
                Text(
                  '还没有添加风格',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(height: Spacing.xs.h),
                Text(
                  '通过上传或 AI 生成添加风格',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedDark,
                  ),
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
      onTap: () {
        ref.read(assetStylesProvider.notifier).update(
              style.copyWith(isProjectDefault: true),
            );
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
                          onTap: () {
                            // TODO: 接入风格编辑对话框
                          },
                          child: Icon(
                            AppIcons.edit,
                            size: 14.r,
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(width: Spacing.md.w),
                        InkWell(
                          onTap: () {
                            ref
                                .read(assetStylesProvider.notifier)
                                .remove(style.id!);
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
    final urls = _parseRefImages(style.referenceImagesJson);
    final thumb = style.thumbnailUrl.isNotEmpty
        ? resolveFileUrl(style.thumbnailUrl)
        : (urls.isNotEmpty ? urls.first : null);

    if (thumb != null && thumb.isNotEmpty) {
      return Image.network(
        thumb,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _cardPlaceholder(),
      );
    }
    return _cardPlaceholder();
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
}
