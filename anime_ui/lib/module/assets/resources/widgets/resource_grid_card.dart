import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

import '../models/resource_category.dart';
import 'resource_card.dart';

/// Grid 模式卡片 —— 纯图灵感墙
///
/// 100% 面积为缩略图，名称和标签叠在底部渐变层上。
/// Hover 时渐变加深并浮现操作图标；批量模式显示勾选框。
class ResourceGridCard extends StatefulWidget {
  const ResourceGridCard({
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
  State<ResourceGridCard> createState() => _ResourceGridCardState();
}

class _ResourceGridCardState extends State<ResourceGridCard> {
  bool _hovering = false;

  bool get _showGradient => _hovering || widget.isBatchMode;
  bool get _showActions =>
      _hovering && !widget.isBatchMode && widget.taskStatus == null;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final hasThumbnail = widget.resource.hasThumbnail;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          decoration: BoxDecoration(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              (RadiusTokens.lg - 1).r,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 缩略图 / 占位
                if (hasThumbnail)
                  Image.network(
                    resolveFileUrl(widget.resource.thumbnailUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        ResourcePlaceholder(icon: icon, color: widget.accentColor),
                  )
                else
                  ResourcePlaceholder(icon: icon, color: widget.accentColor),

                // 选中遮罩
                if (widget.isSelected)
                  Container(
                    color: widget.accentColor.withValues(alpha: 0.12),
                  ),

                // 底部渐变层：名称 + 标签
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: _showGradient || !hasThumbnail ? 1.0 : 0.0,
                    duration: MotionTokens.durationFast,
                    child: _BottomGradient(
                      resource: widget.resource,
                      accentColor: widget.accentColor,
                      alwaysShow: !hasThumbnail,
                    ),
                  ),
                ),

                // Hover 操作图标
                if (_showActions)
                  Positioned(
                    top: Spacing.xs.r,
                    right: Spacing.xs.r,
                    child: CardHoverActions(
                      actions: [
                        if (widget.onViewLargeImage != null)
                          CardActionIcon(
                            icon: AppIcons.gallery,
                            onTap: widget.onViewLargeImage!,
                            tooltip: '查看大图',
                          ),
                        if (widget.onEdit != null)
                          CardActionIcon(
                            icon: AppIcons.edit,
                            onTap: widget.onEdit!,
                            tooltip: '编辑',
                          ),
                        if (widget.onDelete != null)
                          CardActionIcon(
                            icon: AppIcons.delete,
                            onTap: widget.onDelete!,
                            tooltip: '删除',
                            color: AppColors.error,
                          ),
                      ],
                    ),
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

                // 任务状态覆盖层
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
      ),
    );
  }
}

/// 底部渐变遮罩：名称 + 标签
class _BottomGradient extends StatelessWidget {
  const _BottomGradient({
    required this.resource,
    required this.accentColor,
    this.alwaysShow = false,
  });

  final Resource resource;
  final Color accentColor;

  /// 无缩略图时不用渐变，直接纯色底
  final bool alwaysShow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.sm.w,
        Spacing.xl.h,
        Spacing.sm.w,
        Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        gradient: alwaysShow
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xCC000000),
                ],
              ),
        color: alwaysShow ? AppColors.surfaceContainer : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            resource.name,
            style: AppTextStyles.caption.copyWith(
              color: alwaysShow ? AppColors.onSurface : Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (resource.tags.isNotEmpty) ...[
            SizedBox(height: Spacing.xxs.h),
            Row(
              children: resource.tags
                  .take(2)
                  .map((tag) => Padding(
                        padding: EdgeInsets.only(right: Spacing.xs.w),
                        child: ResourceTagChip(
                          label: tag,
                          accentColor: alwaysShow
                              ? accentColor
                              : Colors.white.withValues(alpha: 0.8),
                          small: true,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}


