import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

import '../models/resource_category.dart';
import 'resource_card.dart';

/// Preview 模式卡片 —— 细节审阅
///
/// 大图（3:2）+ 丰富信息区（名称、描述、标签、子库类型、时间）。
/// 可选显示分辨率标签。
class ResourcePreviewCard extends StatefulWidget {
  const ResourcePreviewCard({
    super.key,
    required this.resource,
    required this.accentColor,
    this.onTap,
    this.isSelected = false,
    this.isBatchMode = false,
    this.taskStatus,
    this.taskProgress,
    this.onRetry,
    this.onViewLargeImage,
    this.onViewDetail,
    this.onEdit,
    this.onCopy,
    this.onDelete,
  });

  final Resource resource;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isBatchMode;
  final ResourceTaskStatus? taskStatus;
  final int? taskProgress;
  final VoidCallback? onRetry;
  final VoidCallback? onViewLargeImage;
  final VoidCallback? onViewDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  @override
  State<ResourcePreviewCard> createState() => _ResourcePreviewCardState();
}

class _ResourcePreviewCardState extends State<ResourcePreviewCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final hasThumbnail = widget.resource.hasThumbnail;
    final libType = ResourceLibraryType.values
        .where((t) => t.name == widget.resource.libraryType)
        .firstOrNull;

    final resolution = _extractResolution(widget.resource.metadata);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          decoration: BoxDecoration(
            color: _hovering
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: widget.isSelected
                  ? widget.accentColor
                  : (_hovering
                      ? widget.accentColor.withValues(alpha: 0.4)
                      : AppColors.border),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 大图区
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular((RadiusTokens.lg - 1).r),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasThumbnail)
                            Image.network(
                              resolveFileUrl(widget.resource.thumbnailUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  ResourcePlaceholder(
                                icon: icon,
                                color: widget.accentColor,
                                iconSize: 40.r,
                              ),
                            )
                          else
                            ResourcePlaceholder(
                              icon: icon,
                              color: widget.accentColor,
                              iconSize: 40.r,
                            ),

                          // 分辨率标签
                          if (resolution != null)
                            Positioned(
                              top: Spacing.xs.r,
                              right: Spacing.xs.r,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.xs.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background
                                      .withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(
                                    RadiusTokens.xs.r,
                                  ),
                                ),
                                child: Text(
                                  resolution,
                                  style: AppTextStyles.tiny.copyWith(
                                    color: AppColors.mutedDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 信息区
                  Padding(
                    padding: EdgeInsets.all(Spacing.md.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resource.name,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.resource.description.isNotEmpty) ...[
                          SizedBox(height: Spacing.xxs.h),
                          Text(
                            widget.resource.description,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.muted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (widget.resource.tags.isNotEmpty) ...[
                          SizedBox(height: Spacing.sm.h),
                          Wrap(
                            spacing: Spacing.xs.w,
                            runSpacing: Spacing.xxs.h,
                            children: widget.resource.tags
                                .take(4)
                                .map((tag) => ResourceTagChip(
                                      label: tag,
                                      accentColor: widget.accentColor,
                                    ))
                                .toList(),
                          ),
                        ],
                        SizedBox(height: Spacing.sm.h),
                        Row(
                          children: [
                            if (libType != null) ...[
                              Icon(
                                libType.icon,
                                size: 14.r,
                                color: AppColors.mutedDark,
                              ),
                              SizedBox(width: Spacing.xxs.w),
                              Text(
                                libType.label,
                                style: AppTextStyles.tiny.copyWith(
                                  color: AppColors.mutedDark,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              formatRelativeTime(
                                widget.resource.createdAt,
                              ),
                              style: AppTextStyles.tiny.copyWith(
                                color: AppColors.mutedDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 批量勾选框
              if (widget.isBatchMode)
                Positioned(
                  top: Spacing.xs.r,
                  left: Spacing.xs.r,
                  child: BatchCheckbox(
                    isSelected: widget.isSelected,
                    accentColor: widget.accentColor,
                    onTap: widget.onTap,
                    onDarkBackground: hasThumbnail,
                  ),
                ),

              // Hover 操作菜单
              if (_hovering &&
                  !widget.isBatchMode &&
                  widget.taskStatus == null)
                Positioned(
                  top: Spacing.xs.r,
                  right: Spacing.xs.r,
                  child: PreviewHoverMenu(
                    items: [
                      if (widget.onViewLargeImage != null)
                        (value: 'viewLargeImage', label: '查看大图', icon: AppIcons.gallery),
                      if (widget.onViewDetail != null)
                        (value: 'viewDetail', label: '查看详情', icon: AppIcons.info),
                      if (widget.onEdit != null)
                        (value: 'edit', label: '编辑', icon: AppIcons.edit),
                      if (widget.onCopy != null)
                        (value: 'copy', label: '复制', icon: AppIcons.copy),
                      if (widget.onDelete != null)
                        (value: 'delete', label: '删除', icon: AppIcons.delete),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'viewLargeImage':
                          widget.onViewLargeImage?.call();
                        case 'viewDetail':
                          widget.onViewDetail?.call();
                        case 'edit':
                          widget.onEdit?.call();
                        case 'copy':
                          widget.onCopy?.call();
                        case 'delete':
                          widget.onDelete?.call();
                      }
                    },
                  ),
                ),

              // 任务覆盖层
              if (widget.taskStatus == ResourceTaskStatus.generating)
                Positioned.fill(
                  child: GeneratingOverlay(
                    accentColor: widget.accentColor,
                    progress: widget.taskProgress,
                  ),
                ),
              if (widget.taskStatus == ResourceTaskStatus.failed)
                Positioned.fill(
                  child: FailedOverlay(onRetry: widget.onRetry),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 从 metadata 中提取分辨率信息
  String? _extractResolution(Map<String, dynamic> meta) {
    final w = meta['width'] ?? meta['imageWidth'];
    final h = meta['height'] ?? meta['imageHeight'];
    if (w != null && h != null) return '${w}x$h';
    final res = meta['resolution'];
    if (res is String && res.isNotEmpty) return res;
    return null;
  }
}


