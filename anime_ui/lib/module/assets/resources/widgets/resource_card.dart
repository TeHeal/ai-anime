import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/const/motion.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/services/audio_playback_svc.dart';
import 'package:anime_ui/pub/widgets/image_lightbox.dart';

import '../models/resource_category.dart';
import 'audio_play_overlay.dart';

/// 音色类 libraryType：voice / voiceover / sfx / music
bool _isAudioResource(Resource r) {
  if (r.modality != 'audio') return false;
  const types = ['voice', 'voiceover', 'sfx', 'music'];
  return types.contains(r.libraryType);
}

/// 视觉类素材
bool _isVisualResource(Resource r) => r.modality == 'visual';

/// 资源卡片：缩略图、名称、标签；音色可播放，视觉可大图预览；Hover 时显示操作菜单
class ResourceCard extends StatefulWidget {
  const ResourceCard({
    super.key,
    required this.resource,
    required this.accentColor,
    this.aspectRatio = 3 / 2,
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
  final double aspectRatio;
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
  State<ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<ResourceCard>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.taskStatus == ResourceTaskStatus.generating) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ResourceCard old) {
    super.didUpdateWidget(old);
    if (widget.taskStatus == ResourceTaskStatus.generating &&
        !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (widget.taskStatus != ResourceTaskStatus.generating &&
        _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libType = ResourceLibraryType.values
        .where((t) => t.name == widget.resource.libraryType)
        .firstOrNull;
    final icon = libType?.icon ?? AppIcons.gallery;
    final isAudio = _isAudioResource(widget.resource);
    final isVisual = _isVisualResource(widget.resource);
    final hasMenuActions = widget.onViewLargeImage != null ||
        widget.onViewDetail != null ||
        widget.onEdit != null ||
        widget.onCopy != null ||
        widget.onDelete != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: MotionTokens.durationFast,
            decoration: BoxDecoration(
              color: _hovering
                  ? AppColors.surfaceContainerHigh
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              border: Border.all(
                color: widget.isSelected
                    ? widget.accentColor
                    : (_hovering ? widget.accentColor.withValues(alpha: 0.4) : AppColors.border),
                width: widget.isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ThumbnailArea(
                  resource: widget.resource,
                  accentColor: widget.accentColor,
                  aspectRatio: widget.aspectRatio,
                  icon: icon,
                  isAudio: isAudio,
                  isVisual: isVisual,
                  isBatchMode: widget.isBatchMode,
                  onTap: widget.onTap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
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
                          if (widget.resource.tags.isNotEmpty) ...[
                            SizedBox(height: Spacing.xs.h),
                            Wrap(
                              spacing: Spacing.xs.w,
                              runSpacing: Spacing.xxs.h,
                              children: widget.resource.tags
                                  .take(3)
                                  .map((tag) => Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Spacing.inputGapSm.w,
                                          vertical: Spacing.xxs.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.accentColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            RadiusTokens.xs.r,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style:
                                              AppTextStyles.caption.copyWith(
                                            color: widget.accentColor
                                                .withValues(alpha: 0.9),
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
                ),
              ],
            ),
          ),
          // 批量模式勾选框
          if (widget.isBatchMode)
            Positioned(
              top: Spacing.xs.r,
              left: Spacing.xs.r,
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: MotionTokens.durationFast,
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.accentColor
                        : AppColors.surfaceContainerHigh
                            .withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isSelected
                          ? widget.accentColor
                          : AppColors.muted,
                      width: 1.5,
                    ),
                  ),
                  child: widget.isSelected
                      ? Icon(Icons.check,
                          size: 14.r, color: AppColors.onPrimary)
                      : null,
                ),
              ),
            ),
          // 生成中覆盖层
          if (widget.taskStatus == ResourceTaskStatus.generating)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(RadiusTokens.lg.r),
                    color: AppColors.background
                        .withValues(alpha: 0.5 + _pulseCtrl.value * 0.15),
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
                            value: widget.taskProgress != null
                                ? widget.taskProgress! / 100.0
                                : null,
                          ),
                        ),
                        SizedBox(height: Spacing.sm.h),
                        Text(
                          widget.taskProgress != null
                              ? '生成中 ${widget.taskProgress}%'
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
              ),
            ),
          // 生成失败覆盖层
          if (widget.taskStatus == ResourceTaskStatus.failed)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                  color: AppColors.error.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.error,
                          size: 28.r, color: AppColors.error),
                      SizedBox(height: Spacing.xs.h),
                      Text(
                        '生成失败',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.onRetry != null) ...[
                        SizedBox(height: Spacing.sm.h),
                        TextButton.icon(
                          onPressed: widget.onRetry,
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
              ),
            ),
          // Hover 操作菜单
          if (_hovering &&
              hasMenuActions &&
              !widget.isBatchMode &&
              widget.taskStatus == null)
            Positioned(
              top: Spacing.xs.r,
              right: Spacing.xs.r,
              child: Material(
                color: Colors.transparent,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 140.w),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(RadiusTokens.md.r),
                  ),
                  color: AppColors.surfaceContainerHigh,
                  icon: Container(
                    padding: EdgeInsets.all(Spacing.xs.r),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh
                          .withValues(alpha: 0.9),
                      borderRadius:
                          BorderRadius.circular(RadiusTokens.sm.r),
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
                  itemBuilder: (ctx) {
                    final items = <PopupMenuEntry<String>>[];
                    if (widget.onViewLargeImage != null) {
                      items.add(_menuItem(
                          'viewLargeImage', '查看大图', AppIcons.gallery));
                    }
                    if (widget.onViewDetail != null) {
                      items.add(
                          _menuItem('viewDetail', '查看详情', AppIcons.info));
                    }
                    if (widget.onEdit != null) {
                      items.add(_menuItem('edit', '编辑', AppIcons.edit));
                    }
                    if (widget.onCopy != null) {
                      items.add(_menuItem('copy', '复制', AppIcons.copy));
                    }
                    if (widget.onDelete != null) {
                      items.add(
                          _menuItem('delete', '删除', AppIcons.delete));
                    }
                    return items;
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: Spacing.menuIconSize.r, color: AppColors.onSurface),
          SizedBox(width: Spacing.iconGapSm.w),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _ThumbnailArea extends StatelessWidget {
  const _ThumbnailArea({
    required this.resource,
    required this.accentColor,
    required this.aspectRatio,
    required this.icon,
    required this.isAudio,
    required this.isVisual,
    required this.isBatchMode,
    required this.onTap,
  });

  final Resource resource;
  final Color accentColor;
  final double aspectRatio;
  final IconData icon;
  final bool isAudio;
  final bool isVisual;
  final bool isBatchMode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final thumbnailTap = isBatchMode
        ? onTap
        : (isVisual && resource.hasThumbnail)
            ? () => showImageLightbox(context, imageUrl: resource.thumbnailUrl)
            : (isAudio && resource.audioUrl.isNotEmpty)
                ? () => AudioPlaybackService.instance.play(resource.audioUrl)
                : null;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: thumbnailTap ?? onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
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
                        errorBuilder: (_, Object? err, StackTrace? stack) =>
                            _buildPlaceholder(icon),
                      ),
                    )
                  : _buildPlaceholder(icon),
            ),
            if (isAudio && resource.audioUrl.isNotEmpty && !isBatchMode)
              AudioPlayOverlay(
                resource: resource,
                accentColor: accentColor,
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

