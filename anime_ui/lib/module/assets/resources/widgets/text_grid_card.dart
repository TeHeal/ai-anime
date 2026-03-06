import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';
import 'resource_card.dart';

/// Grid 模式文本卡片 —— 便签墙
///
/// 上部为正文预览区（带底部渐隐），下部为名称 + 元数据 + 标签。
/// 类似便签纸 / 索引卡，文字内容为主角。
class TextGridCard extends StatefulWidget {
  const TextGridCard({
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
  State<TextGridCard> createState() => _TextGridCardState();
}

class _TextGridCardState extends State<TextGridCard> {
  bool _hovering = false;

  bool get _showActions =>
      _hovering && !widget.isBatchMode && widget.taskStatus == null;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final content = extractTextContent(widget.resource);
    final libType = ResourceLibraryType.values
        .where((t) => t.name == widget.resource.libraryType)
        .firstOrNull;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: widget.isSelected
                  ? widget.accentColor
                  : (_hovering
                      ? widget.accentColor.withValues(alpha: 0.4)
                      : AppColors.border),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.08),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.r),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular((RadiusTokens.lg - 1).r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 正文预览区（约 60%）
                    Expanded(
                      flex: 3,
                      child: _ContentPreview(
                        content: content,
                        icon: icon,
                        accentColor: widget.accentColor,
                      ),
                    ),

                    // 底部信息区（约 40%）
                    _BottomInfo(
                      resource: widget.resource,
                      accentColor: widget.accentColor,
                      libType: libType,
                    ),
                  ],
                ),

                // 左上角子库图标
                Positioned(
                  top: Spacing.sm.r,
                  left: Spacing.sm.r,
                  child: Container(
                    padding: EdgeInsets.all(Spacing.xs.r),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                    ),
                    child: Icon(
                      icon,
                      size: 14.r,
                      color: widget.accentColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                // Hover 操作
                if (_showActions)
                  Positioned(
                    top: Spacing.xs.r,
                    right: Spacing.xs.r,
                    child: _HoverActions(
                      accentColor: widget.accentColor,
                      onEdit: widget.onEdit,
                      onCopy: widget.onCopy,
                      onDelete: widget.onDelete,
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
                    ),
                  ),

                // 选中遮罩
                if (widget.isSelected)
                  Positioned.fill(
                    child: Container(
                      color: widget.accentColor.withValues(alpha: 0.08),
                    ),
                  ),

                // 底部 accent 色带
                if (_hovering)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 2.h,
                      color: widget.accentColor.withValues(alpha: 0.6),
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

/// 正文预览区：渐变背景 + 文字内容 + 底部渐隐
class _ContentPreview extends StatelessWidget {
  const _ContentPreview({
    required this.content,
    required this.icon,
    required this.accentColor,
  });

  final String content;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withValues(alpha: 0.04),
              accentColor.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28.r,
                color: accentColor.withValues(alpha: 0.2),
              ),
              SizedBox(height: Spacing.xs.h),
              Text(
                '暂无内容',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Spacing.md.w,
            Spacing.xl.h,
            Spacing.md.w,
            Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accentColor.withValues(alpha: 0.04),
                accentColor.withValues(alpha: 0.01),
              ],
            ),
          ),
          child: Text(
            content,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.75),
              height: 1.6,
            ),
            maxLines: 5,
            overflow: TextOverflow.fade,
          ),
        ),
        // 底部渐隐遮罩
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 24.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceContainer.withValues(alpha: 0.0),
                  AppColors.surfaceContainer,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 底部信息：名称 + 元数据 chip + 标签 + 字数
class _BottomInfo extends StatelessWidget {
  const _BottomInfo({
    required this.resource,
    required this.accentColor,
    this.libType,
  });

  final Resource resource;
  final Color accentColor;
  final ResourceLibraryType? libType;

  @override
  Widget build(BuildContext context) {
    final charCount = countChars(resource);
    final metaChip = _primaryMetaLabel();

    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.md.w,
        Spacing.xs.h,
        Spacing.md.w,
        Spacing.sm.h,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 名称
          Text(
            resource.name,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: Spacing.xxs.h),

          // 元数据 chip + 字数
          Row(
            children: [
              if (metaChip != null) ...[
                _SmallChip(label: metaChip, accentColor: accentColor),
                SizedBox(width: Spacing.xs.w),
              ],
              if (resource.tags.isNotEmpty)
                ...resource.tags.take(1).map((tag) => Padding(
                      padding: EdgeInsets.only(right: Spacing.xs.w),
                      child: ResourceTagChip(
                        label: tag,
                        accentColor: accentColor,
                        small: true,
                      ),
                    )),
              const Spacer(),
              if (charCount > 0)
                Text(
                  '$charCount字',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 提取首要 metadata 标签（用途 / 风格类型 / 台词类型 / 片段类型）
  String? _primaryMetaLabel() {
    final meta = resource.metadata;
    const keys = ['category', 'styleType', 'dialogueType', 'snippetType'];
    for (final key in keys) {
      final v = meta[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return libType?.label;
  }
}

/// 紧凑元数据 chip
class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label, required this.accentColor});

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
      ),
    );
  }
}

/// Hover 操作图标行
class _HoverActions extends StatelessWidget {
  const _HoverActions({
    required this.accentColor,
    this.onEdit,
    this.onCopy,
    this.onDelete,
  });

  final Color accentColor;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xs.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCopy != null)
            _ActionIcon(
              icon: AppIcons.copy,
              onTap: onCopy!,
              tooltip: '复制内容',
            ),
          if (onEdit != null)
            _ActionIcon(
              icon: AppIcons.edit,
              onTap: onEdit!,
              tooltip: '编辑',
            ),
          if (onDelete != null)
            _ActionIcon(
              icon: AppIcons.delete,
              onTap: onDelete!,
              tooltip: '删除',
              color: AppColors.error,
            ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
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
            color: color ?? AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
