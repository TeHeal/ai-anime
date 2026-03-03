import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

import '../models/resource_category.dart';

/// 资源卡片：缩略图、名称、标签
class ResourceCard extends StatelessWidget {
  const ResourceCard({
    super.key,
    required this.resource,
    required this.accentColor,
    this.aspectRatio = 3 / 2,
    this.onTap,
  });

  final Resource resource;
  final Color accentColor;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final libType = ResourceLibraryType.values
        .where((t) => t.name == resource.libraryType)
        .firstOrNull;
    final icon = libType?.icon ?? AppIcons.gallery;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 缩略图
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(RadiusTokens.lg.r),
                  ),
                ),
                child: resource.hasThumbnail
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(RadiusTokens.lg.r),
                        ),
                        child: Image.network(
                          resolveFileUrl(resource.thumbnailUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(icon),
                        ),
                      )
                    : _buildPlaceholder(icon),
              ),
            ),
            // 名称与标签
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Spacing.md.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (resource.tags.isNotEmpty) ...[
                      SizedBox(height: Spacing.xs.h),
                      Wrap(
                        spacing: Spacing.xs.w,
                        runSpacing: Spacing.xxs.h,
                        children: resource.tags
                            .take(3)
                            .map((tag) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.inputGapSm.w,
                                    vertical: Spacing.xxs.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                      RadiusTokens.xs.r,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: AppTextStyles.caption.copyWith(
                                      color: accentColor.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Center(
      child: Icon(
        icon,
        size: 32.r,
        color: accentColor.withValues(alpha: 0.3),
      ),
    );
  }
}
