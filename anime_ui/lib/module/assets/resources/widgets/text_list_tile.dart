import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';
import 'resource_card.dart';

/// List 模式文本行 —— 工作管理列表
///
/// 左侧彩色图标 + 名称/摘要 + 关键 metadata chip + 字数 + 标签 + 时间 + 操作。
/// hover 时第一个操作为"复制内容"，突出文本素材的高频使用场景。
class TextListTile extends StatefulWidget {
  const TextListTile({
    super.key,
    required this.resource,
    required this.accentColor,
    this.onTap,
    this.isSelected = false,
    this.isBatchMode = false,
    this.taskStatus,
    this.taskProgress,
    this.onRetry,
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
  final VoidCallback? onViewDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  @override
  State<TextListTile> createState() => _TextListTileState();
}

class _TextListTileState extends State<TextListTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final content = extractTextContent(widget.resource);
    final charCount = countChars(widget.resource);
    final libType = ResourceLibraryType.values
        .where((t) => t.name == widget.resource.libraryType)
        .firstOrNull;
    final metaLabel = _primaryMetaLabel(widget.resource, libType);

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

              // 子库彩色图标
              _TextIcon(icon: icon, accentColor: widget.accentColor),

              SizedBox(width: Spacing.md.w),

              // 名称 + 摘要
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
                      content.isNotEmpty
                          ? content.replaceAll('\n', ' ')
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

              // 关键 metadata chip
              if (metaLabel != null)
                SizedBox(
                  width: 80.w,
                  child: _MetaChip(
                    label: metaLabel,
                    accentColor: widget.accentColor,
                  ),
                ),

              SizedBox(width: Spacing.md.w),

              // 标签
              if (widget.resource.tags.isNotEmpty)
                Flexible(
                  flex: 2,
                  child: Row(
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

              // 字数
              SizedBox(
                width: 48.w,
                child: Text(
                  charCount > 0 ? '$charCount字' : '',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedDark,
                  ),
                  textAlign: TextAlign.right,
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

              // Hover 操作 / 任务状态
              SizedBox(
                width: 96.w,
                child: _buildTrailing(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (widget.taskStatus == ResourceTaskStatus.generating) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 16.r,
            height: 16.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.accentColor,
              value: widget.taskProgress != null
                  ? widget.taskProgress! / 100.0
                  : null,
            ),
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            widget.taskProgress != null ? '${widget.taskProgress}%' : '生成中',
            style: AppTextStyles.caption.copyWith(
              color: widget.accentColor,
            ),
          ),
        ],
      );
    }

    if (widget.taskStatus == ResourceTaskStatus.failed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(AppIcons.error, size: 16.r, color: AppColors.error),
          if (widget.onRetry != null) ...[
            SizedBox(width: Spacing.xs.w),
            GestureDetector(
              onTap: widget.onRetry,
              child: Text(
                '重试',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // 非批量模式 hover 时显示操作按钮（复制优先）
    if (_hovering && !widget.isBatchMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.onCopy != null)
            _TileActionIcon(
              icon: AppIcons.copy,
              onTap: widget.onCopy!,
              tooltip: '复制内容',
            ),
          if (widget.onEdit != null)
            _TileActionIcon(
              icon: AppIcons.edit,
              onTap: widget.onEdit!,
              tooltip: '编辑',
            ),
          if (widget.onDelete != null)
            _TileActionIcon(
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

  /// 提取首要 metadata 标签
  static String? _primaryMetaLabel(
    Resource r,
    ResourceLibraryType? libType,
  ) {
    final meta = r.metadata;
    const keys = ['category', 'styleType', 'dialogueType', 'snippetType'];
    for (final key in keys) {
      final v = meta[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }
}

/// 左侧彩色圆角方形图标
class _TextIcon extends StatelessWidget {
  const _TextIcon({required this.icon, required this.accentColor});

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 22.r,
          color: accentColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// 行内 metadata chip
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xs.w,
        vertical: 1.h,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: accentColor.withValues(alpha: 0.85),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TileActionIcon extends StatelessWidget {
  const _TileActionIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
        child: Padding(
          padding: EdgeInsets.all(Spacing.xs.r),
          child: Icon(
            icon,
            size: 16.r,
            color: color ?? AppColors.muted,
          ),
        ),
      ),
    );
  }
}
