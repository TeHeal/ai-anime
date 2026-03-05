import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

import '../models/resource_category.dart';
import 'resource_card.dart';

/// List 模式行 —— 工作台表格行
///
/// 横向 Row 布局：缩略图 + 名称/描述 + 标签 + 时间 + 操作。
/// 批量模式下左侧滑入 Checkbox，整行可点击切换选中。
class ResourceListTile extends StatefulWidget {
  const ResourceListTile({
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
  State<ResourceListTile> createState() => _ResourceListTileState();
}

class _ResourceListTileState extends State<ResourceListTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final hasThumbnail = widget.resource.hasThumbnail;
    final libType = ResourceLibraryType.values
        .where((t) => t.name == widget.resource.libraryType)
        .firstOrNull;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          height: 72.h,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.accentColor.withValues(alpha: 0.08)
                : (_hovering
                    ? AppColors.surfaceContainerHigh
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              // 批量 Checkbox（滑入动画）
              AnimatedSize(
                duration: MotionTokens.durationMedium,
                curve: MotionTokens.curveStandard,
                child: widget.isBatchMode
                    ? Padding(
                        padding: EdgeInsets.only(right: Spacing.sm.w),
                        child: BatchCheckbox(
                          isSelected: widget.isSelected,
                          accentColor: widget.accentColor,
                          onTap: widget.onTap,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // 缩略图
              ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                child: SizedBox(
                  width: 56.r,
                  height: 56.r,
                  child: hasThumbnail
                      ? Image.network(
                          resolveFileUrl(widget.resource.thumbnailUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ResourcePlaceholder(
                            icon: icon,
                            color: widget.accentColor,
                            iconSize: 24.r,
                          ),
                        )
                      : ResourcePlaceholder(
                          icon: icon,
                          color: widget.accentColor,
                          iconSize: 24.r,
                        ),
                ),
              ),

              SizedBox(width: Spacing.md.w),

              // 名称 + 描述
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.resource.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Spacing.xxs.h),
                    Text(
                      widget.resource.description.isNotEmpty
                          ? widget.resource.description
                          : (libType?.label ?? ''),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(width: Spacing.md.w),

              // 标签
              if (widget.resource.tags.isNotEmpty)
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: widget.resource.tags
                        .take(2)
                        .map((tag) => Padding(
                              padding: EdgeInsets.only(right: Spacing.xs.w),
                              child: ResourceTagChip(
                                label: tag,
                                accentColor: widget.accentColor,
                                small: true,
                              ),
                            ))
                        .toList(),
                  ),
                ),

              SizedBox(width: Spacing.md.w),

              // 时间
              SizedBox(
                width: 64.w,
                child: Text(
                  formatRelativeTime(widget.resource.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedDark,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              SizedBox(width: Spacing.sm.w),

              // Hover 操作 / 任务状态指示
              SizedBox(
                width: 80.w,
                child: _buildTrailing(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (widget.taskStatus != null) {
      return TileTaskStatus(
        taskStatus: widget.taskStatus!,
        accentColor: widget.accentColor,
        taskProgress: widget.taskProgress,
        onRetry: widget.onRetry,
      );
    }

    if (_hovering && !widget.isBatchMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.onViewLargeImage != null)
            TileActionIcon(
              icon: AppIcons.gallery,
              onTap: widget.onViewLargeImage!,
              tooltip: '查看大图',
            ),
          if (widget.onEdit != null)
            TileActionIcon(
              icon: AppIcons.edit,
              onTap: widget.onEdit!,
              tooltip: '编辑',
            ),
          if (widget.onDelete != null)
            TileActionIcon(
              icon: AppIcons.delete,
              onTap: widget.onDelete!,
              tooltip: '删除',
              color: AppColors.error,
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

