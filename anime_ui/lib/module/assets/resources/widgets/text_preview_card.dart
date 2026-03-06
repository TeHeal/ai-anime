import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';
import 'resource_card.dart';

/// Preview 模式文本卡片 —— 阅读审阅
///
/// 上部为完整正文预览（带渐隐截断），下部为名称 + 元数据 + 标签。
/// 用户可在列表中直接阅读内容，无需打开详情弹窗。
class TextPreviewCard extends StatefulWidget {
  const TextPreviewCard({
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
  State<TextPreviewCard> createState() => _TextPreviewCardState();
}

class _TextPreviewCardState extends State<TextPreviewCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final content = extractTextContent(widget.resource);
    final charCount = countChars(widget.resource);
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
                  // 正文阅读区
                  _ReadingArea(
                    content: content,
                    icon: icon,
                    accentColor: widget.accentColor,
                    libType: libType,
                  ),

                  // 信息区
                  _InfoSection(
                    resource: widget.resource,
                    accentColor: widget.accentColor,
                    libType: libType,
                    charCount: charCount,
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
                  ),
                ),

              // Hover 操作菜单
              if (_hovering &&
                  !widget.isBatchMode &&
                  widget.taskStatus == null)
                Positioned(
                  top: Spacing.xs.r,
                  right: Spacing.xs.r,
                  child: _PreviewHoverMenu(
                    onViewDetail: widget.onViewDetail,
                    onEdit: widget.onEdit,
                    onCopy: widget.onCopy,
                    onDelete: widget.onDelete,
                  ),
                ),

              // hover 时右下角"复制全文"快捷按钮
              if (_hovering &&
                  !widget.isBatchMode &&
                  widget.taskStatus == null &&
                  content.isNotEmpty)
                Positioned(
                  bottom: Spacing.sm.r,
                  right: Spacing.sm.r,
                  child: _CopyButton(
                    content: content,
                    accentColor: widget.accentColor,
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
}

/// 上部正文阅读区
class _ReadingArea extends StatelessWidget {
  const _ReadingArea({
    required this.content,
    required this.icon,
    required this.accentColor,
    this.libType,
  });

  final String content;
  final IconData icon;
  final Color accentColor;
  final ResourceLibraryType? libType;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular((RadiusTokens.lg - 1).r),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: 120.h),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.03),
        ),
        child: Stack(
          children: [
            // 右上装饰图标
            Positioned(
              right: Spacing.md.w,
              top: Spacing.sm.h,
              child: Opacity(
                opacity: 0.05,
                child: Icon(icon, size: 48.r, color: accentColor),
              ),
            ),

            // 正文
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.lg.w,
                Spacing.lg.h,
                Spacing.lg.w,
                Spacing.xl.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 子库标签
                  if (libType != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: Spacing.sm.h),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 14.r,
                            color: accentColor.withValues(alpha: 0.5),
                          ),
                          SizedBox(width: Spacing.xxs.w),
                          Text(
                            libType!.label,
                            style: AppTextStyles.tiny.copyWith(
                              color: accentColor.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 正文内容
                  if (content.isNotEmpty)
                    Text(
                      content,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.8),
                        height: 1.7,
                      ),
                      maxLines: 8,
                      overflow: TextOverflow.fade,
                    )
                  else
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: Spacing.xl.h),
                        child: Column(
                          children: [
                            Icon(
                              icon,
                              size: 32.r,
                              color: accentColor.withValues(alpha: 0.15),
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
                    ),
                ],
              ),
            ),

            // 底部渐隐遮罩
            if (content.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 32.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withValues(alpha: 0.0),
                        AppColors.surfaceContainer.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 下部信息区
class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.resource,
    required this.accentColor,
    this.libType,
    required this.charCount,
  });

  final Resource resource;
  final Color accentColor;
  final ResourceLibraryType? libType;
  final int charCount;

  @override
  Widget build(BuildContext context) {
    final metaChips = _buildMetaChips();

    return Padding(
      padding: EdgeInsets.all(Spacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称
          Text(
            resource.name,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // 元数据 chips
          if (metaChips.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Wrap(
              spacing: Spacing.xs.w,
              runSpacing: Spacing.xxs.h,
              children: metaChips,
            ),
          ],

          // 标签
          if (resource.tags.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Wrap(
              spacing: Spacing.xs.w,
              runSpacing: Spacing.xxs.h,
              children: resource.tags
                  .take(4)
                  .map((tag) => ResourceTagChip(
                        label: tag,
                        accentColor: accentColor,
                      ))
                  .toList(),
            ),
          ],

          SizedBox(height: Spacing.sm.h),

          // 底行：字数 + 时间
          Row(
            children: [
              if (charCount > 0) ...[
                Icon(
                  AppIcons.document,
                  size: 14.r,
                  color: AppColors.mutedDark,
                ),
                SizedBox(width: Spacing.xxs.w),
                Text(
                  '$charCount字',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                formatRelativeTime(resource.createdAt),
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

  /// 从 metadata 中提取文本特有的信息展示为 chips
  List<Widget> _buildMetaChips() {
    final meta = resource.metadata;
    final chips = <Widget>[];

    final displayKeys = [
      'category',
      'styleType',
      'dialogueType',
      'snippetType',
      'language',
      'targetModel',
      'characterRole',
      'genre',
    ];
    final displayLabels = {
      'category': null,
      'styleType': null,
      'dialogueType': null,
      'snippetType': null,
      'language': '语言',
      'targetModel': '模型',
      'characterRole': '角色',
      'genre': '题材',
    };

    for (final key in displayKeys) {
      final value = meta[key];
      if (value == null || value.toString().isEmpty) continue;
      final label = displayLabels[key];
      final text = label != null ? '$label: $value' : value.toString();
      chips.add(_MetaChip(label: text, accentColor: accentColor));
    }

    return chips;
  }
}

/// metadata 标签
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.inputGapSm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
        ),
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

/// "复制全文"按钮
class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.content, required this.accentColor});

  final String content;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: content));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('已复制到剪贴板'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              width: 180.w,
            ),
          );
        },
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.copy,
                size: 14.r,
                color: accentColor,
              ),
              SizedBox(width: Spacing.xxs.w),
              Text(
                '复制全文',
                style: AppTextStyles.tiny.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hover 弹出菜单
class _PreviewHoverMenu extends StatelessWidget {
  const _PreviewHoverMenu({
    this.onViewDetail,
    this.onEdit,
    this.onCopy,
    this.onDelete,
  });

  final VoidCallback? onViewDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 140.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        ),
        color: AppColors.surfaceContainerHigh,
        icon: Container(
          padding: EdgeInsets.all(Spacing.xs.r),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            AppIcons.moreVert,
            size: Spacing.menuIconSize.r,
            color: AppColors.onSurface,
          ),
        ),
        onSelected: (value) {
          switch (value) {
            case 'viewDetail':
              onViewDetail?.call();
            case 'edit':
              onEdit?.call();
            case 'copy':
              onCopy?.call();
            case 'delete':
              onDelete?.call();
          }
        },
        itemBuilder: (ctx) {
          final items = <PopupMenuEntry<String>>[];
          if (onViewDetail != null) {
            items.add(
              buildMenuItem('viewDetail', '查看详情', AppIcons.info),
            );
          }
          if (onCopy != null) {
            items.add(buildMenuItem('copy', '复制', AppIcons.copy));
          }
          if (onEdit != null) {
            items.add(buildMenuItem('edit', '编辑', AppIcons.edit));
          }
          if (onDelete != null) {
            items.add(buildMenuItem('delete', '删除', AppIcons.delete));
          }
          return items;
        },
      ),
    );
  }
}
