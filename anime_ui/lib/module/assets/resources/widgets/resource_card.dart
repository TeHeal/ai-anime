import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';

// ── 共享工具函数 ──

/// 音色类 libraryType：voice / voiceover / sfx / music
bool isAudioResource(Resource r) {
  if (r.modality != 'audio') return false;
  const types = ['voice', 'voiceover', 'sfx', 'music'];
  return types.contains(r.libraryType);
}

/// 文本类素材（prompt / styleGuide / dialogueTemplate / scriptSnippet）
bool isTextResource(Resource r) => r.modality == 'text';

/// 从文本素材中提取正文内容（优先 description）
String extractTextContent(Resource r) {
  if (r.description.isNotEmpty) return r.description;
  final meta = r.metadata;
  final content = meta['content'];
  if (content is String && content.isNotEmpty) return content;
  return '';
}

/// 统计文本字数（按字符计）
int countChars(Resource r) => extractTextContent(r).length;

/// 根据 libraryType 获取图标
IconData resourceIcon(Resource r) {
  final libType = ResourceLibraryType.values
      .where((t) => t.name == r.libraryType)
      .firstOrNull;
  return libType?.icon ?? AppIcons.gallery;
}

/// 相对时间格式化（如 "3天前"、"刚刚"）
String formatRelativeTime(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inDays > 365) return '${diff.inDays ~/ 365}年前';
  if (diff.inDays > 30) return '${diff.inDays ~/ 30}个月前';
  if (diff.inDays > 0) return '${diff.inDays}天前';
  if (diff.inHours > 0) return '${diff.inHours}小时前';
  if (diff.inMinutes > 0) return '${diff.inMinutes}分钟前';
  return '刚刚';
}

// ── 共享覆盖层 ──

/// 生成中脉冲覆盖层
class GeneratingOverlay extends StatefulWidget {
  const GeneratingOverlay({
    super.key,
    required this.accentColor,
    this.progress,
  });

  final Color accentColor;
  final int? progress;

  @override
  State<GeneratingOverlay> createState() => _GeneratingOverlayState();
}

class _GeneratingOverlayState extends State<GeneratingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          color: AppColors.background
              .withValues(alpha: 0.5 + _ctrl.value * 0.15),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24.r,
                height: 24.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: widget.accentColor,
                  value: widget.progress != null
                      ? widget.progress! / 100.0
                      : null,
                ),
              ),
              SizedBox(height: Spacing.sm.h),
              Text(
                widget.progress != null
                    ? '生成中 ${widget.progress}%'
                    : '生成中…',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface,
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

/// 生成失败覆盖层
class FailedOverlay extends StatelessWidget {
  const FailedOverlay({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        color: AppColors.error.withValues(alpha: 0.15),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.error, size: 28.r, color: AppColors.error),
            SizedBox(height: Spacing.xs.h),
            Text(
              '生成失败',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: Spacing.sm.h),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 14.r),
                label: const Text('重试'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 共享小标签组件 ──

/// 资源标签 chip（用于所有视图模式）
class ResourceTagChip extends StatelessWidget {
  const ResourceTagChip({
    super.key,
    required this.label,
    required this.accentColor,
    this.small = false,
  });

  final String label;
  final Color accentColor;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? Spacing.xs.w : Spacing.inputGapSm.w,
        vertical: small ? 1.h : Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(
        label,
        style: (small ? AppTextStyles.tiny : AppTextStyles.caption).copyWith(
          color: accentColor.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

// ── 共享批量勾选框 ──

/// 批量模式勾选框（圆形，支持在任意背景上显示）
class BatchCheckbox extends StatelessWidget {
  const BatchCheckbox({
    super.key,
    required this.isSelected,
    required this.accentColor,
    this.onTap,
    this.onDarkBackground = false,
  });

  final bool isSelected;
  final Color accentColor;
  final VoidCallback? onTap;

  /// 在深色/图片背景上显示时加白色半透明底
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionTokens.durationFast,
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor
              : onDarkBackground
                  ? AppColors.background.withValues(alpha: 0.6)
                  : AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? accentColor : AppColors.muted,
            width: 1.5,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, size: 14.r, color: AppColors.onPrimary)
            : null,
      ),
    );
  }
}

// ── 共享 Hover 操作组件 ──

/// 小图标按钮（Grid/Preview 卡片右上角操作栏内使用）
class CardActionIcon extends StatelessWidget {
  const CardActionIcon({
    super.key,
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

/// 小图标按钮（List 行尾 hover 操作使用，默认 muted 色）
class TileActionIcon extends StatelessWidget {
  const TileActionIcon({
    super.key,
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

/// 弹出菜单项构建
PopupMenuItem<String> buildMenuItem(
  String value,
  String label,
  IconData icon,
) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: Spacing.menuIconSize.r, color: AppColors.onSurface),
        SizedBox(width: Spacing.iconGapSm.w),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ],
    ),
  );
}

// ── 共享占位组件 ──

/// 无缩略图占位（统一尺寸由 [iconSize] 控制）
class ResourcePlaceholder extends StatelessWidget {
  const ResourcePlaceholder({
    super.key,
    required this.icon,
    required this.color,
    this.iconSize,
  });

  final IconData icon;
  final Color color;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          icon,
          size: iconSize ?? 32.r,
          color: color.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ── 共享 Hover 操作栏（Grid 卡片右上角） ──

/// Grid 模式卡片 hover 操作按钮组，通过 actions 灵活组装
class CardHoverActions extends StatelessWidget {
  const CardHoverActions({
    super.key,
    required this.actions,
  });

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xs.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions,
      ),
    );
  }
}

// ── 共享 Preview Hover 菜单 ──

/// Preview 模式卡片 hover 弹出菜单
class PreviewHoverMenu extends StatelessWidget {
  const PreviewHoverMenu({
    super.key,
    required this.items,
    required this.onSelected,
  });

  /// 菜单项列表（value, label, icon）
  final List<({String value, String label, IconData icon})> items;
  final ValueChanged<String> onSelected;

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
            color: AppColors.background.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            AppIcons.moreVert,
            size: Spacing.menuIconSize.r,
            color: AppColors.onSurface,
          ),
        ),
        onSelected: onSelected,
        itemBuilder: (ctx) => items
            .map((e) => buildMenuItem(e.value, e.label, e.icon))
            .toList(),
      ),
    );
  }
}

// ── 共享 List Tile 任务状态 ──

/// List 模式尾部任务状态指示器（生成中/失败）
class TileTaskStatus extends StatelessWidget {
  const TileTaskStatus({
    super.key,
    required this.taskStatus,
    required this.accentColor,
    this.taskProgress,
    this.onRetry,
  });

  final ResourceTaskStatus taskStatus;
  final Color accentColor;
  final int? taskProgress;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (taskStatus == ResourceTaskStatus.generating) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 16.r,
            height: 16.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accentColor,
              value: taskProgress != null ? taskProgress! / 100.0 : null,
            ),
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            taskProgress != null ? '$taskProgress%' : '生成中',
            style: AppTextStyles.caption.copyWith(color: accentColor),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(AppIcons.error, size: 16.r, color: AppColors.error),
        if (onRetry != null) ...[
          SizedBox(width: Spacing.xs.w),
          GestureDetector(
            onTap: onRetry,
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
}
