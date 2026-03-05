import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

import '../models/resource_category.dart';
import 'resource_card.dart';

/// List 模式音频行 —— 工作管理列表
///
/// 左侧图标 + 名称/描述 + 内嵌迷你播放条 + 标签 + 时间 + 操作。
/// 非 hover 时播放区仅显示时长图标，hover 浮现播放按钮。
/// 播放中整行微变色高亮。
class AudioListTile extends StatefulWidget {
  const AudioListTile({
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
  State<AudioListTile> createState() => _AudioListTileState();
}

class _AudioListTileState extends State<AudioListTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final playback = AudioPlaybackService.instance;
    final libType = ResourceLibraryType.values
        .where((t) => t.name == widget.resource.libraryType)
        .firstOrNull;

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final isPlaying = playback.isPlayingUrl(widget.resource.audioUrl);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.isBatchMode ? widget.onTap : widget.onViewDetail,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: MotionTokens.durationFast,
              height: 72.h,
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.sm.h,
              ),
              decoration: BoxDecoration(
                color: isPlaying
                    ? widget.accentColor.withValues(alpha: 0.06)
                    : widget.isSelected
                        ? widget.accentColor.withValues(alpha: 0.08)
                        : (_hovering
                            ? AppColors.surfaceContainerHigh
                            : Colors.transparent),
              ),
              child: Row(
                children: [
                  // 批量 Checkbox
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

                  // 子库图标
                  _AudioIcon(
                    icon: icon,
                    accentColor: widget.accentColor,
                    isPlaying: isPlaying,
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

                  // 迷你播放条区域
                  SizedBox(
                    width: 160.w,
                    child: _MiniPlayer(
                      resource: widget.resource,
                      accentColor: widget.accentColor,
                      isPlaying: isPlaying,
                      isHovering: _hovering,
                      playback: playback,
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
                                  padding:
                                      EdgeInsets.only(right: Spacing.xs.w),
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

                  // 尾部操作 / 任务状态
                  SizedBox(
                    width: 80.w,
                    child: _buildTrailing(isPlaying),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailing(bool isPlaying) {
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

/// 左侧圆角方形图标（播放中有脉冲底色）
class _AudioIcon extends StatelessWidget {
  const _AudioIcon({
    required this.icon,
    required this.accentColor,
    required this.isPlaying,
  });

  final IconData icon;
  final Color accentColor;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MotionTokens.durationFast,
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isPlaying ? 0.15 : 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: isPlaying
            ? Border.all(color: accentColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 22.r,
          color: accentColor.withValues(alpha: isPlaying ? 0.9 : 0.4),
        ),
      ),
    );
  }
}

/// 内嵌迷你播放条
///
/// 非 hover 且非播放时：显示 ♪ + 静态时长
/// hover 或播放时：播放按钮 + 进度条 + 时间
class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({
    required this.resource,
    required this.accentColor,
    required this.isPlaying,
    required this.isHovering,
    required this.playback,
  });

  final Resource resource;
  final Color accentColor;
  final bool isPlaying;
  final bool isHovering;
  final AudioPlaybackService playback;

  @override
  Widget build(BuildContext context) {
    final hasAudio = resource.audioUrl.isNotEmpty;
    final durationStr = _extractDuration();

    // 播放中：播放按钮 + 进度条 + 时间
    if (isPlaying) {
      return Row(
        children: [
          _MiniPlayButton(
            accentColor: accentColor,
            isPlaying: true,
            onTap: hasAudio ? () => playback.play(resource.audioUrl) : null,
          ),
          SizedBox(width: Spacing.xs.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              child: LinearProgressIndicator(
                value: playback.progress,
                minHeight: Spacing.progressBarHeight.r,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            '${formatDuration(playback.position)}/${formatDuration(playback.duration)}',
            style: AppTextStyles.tiny.copyWith(color: accentColor),
          ),
        ],
      );
    }

    // hover 且有音频：浮现播放按钮 + 时长
    if (isHovering && hasAudio) {
      return Row(
        children: [
          _MiniPlayButton(
            accentColor: accentColor,
            isPlaying: false,
            onTap: () => playback.play(resource.audioUrl),
          ),
          SizedBox(width: Spacing.xs.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: Spacing.progressBarHeight.r,
                backgroundColor: accentColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
          ),
          if (durationStr.isNotEmpty) ...[
            SizedBox(width: Spacing.xs.w),
            Text(
              durationStr,
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
            ),
          ],
        ],
      );
    }

    // 默认：静态时长显示
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          AppIcons.music,
          size: 14.r,
          color: AppColors.mutedDark,
        ),
        if (durationStr.isNotEmpty) ...[
          SizedBox(width: Spacing.xs.w),
          Text(
            durationStr,
            style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
          ),
        ],
      ],
    );
  }

  String _extractDuration() {
    final meta = resource.metadata;
    final d = meta['duration'];
    if (d is num && d > 0) {
      return formatDuration(Duration(milliseconds: (d * 1000).toInt()));
    }
    if (d is String && d.isNotEmpty) return d;
    return '';
  }
}

/// 迷你播放/暂停按钮
class _MiniPlayButton extends StatelessWidget {
  const _MiniPlayButton({
    required this.accentColor,
    required this.isPlaying,
    this.onTap,
  });

  final Color accentColor;
  final bool isPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isPlaying ? 0.25 : 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          isPlaying ? AppIcons.stop : AppIcons.playArrow,
          size: 14.r,
          color: accentColor,
        ),
      ),
    );
  }
}

