import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

import '../models/resource_category.dart';
import 'resource_card.dart';

/// Grid 模式音频卡片 —— 快速试听墙
///
/// 以子库图标为视觉中心，点击卡片即播放/暂停。
/// 底部显示名称 + 时长，播放时贴底出现进度条并有边框发光效果。
class AudioGridCard extends StatefulWidget {
  const AudioGridCard({
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
  final VoidCallback? onDelete;

  @override
  State<AudioGridCard> createState() => _AudioGridCardState();
}

class _AudioGridCardState extends State<AudioGridCard> {
  bool _hovering = false;

  bool get _showActions =>
      _hovering && !widget.isBatchMode && widget.taskStatus == null;

  @override
  Widget build(BuildContext context) {
    final icon = resourceIcon(widget.resource);
    final playback = AudioPlaybackService.instance;

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final isPlaying = playback.isPlayingUrl(widget.resource.audioUrl);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.isBatchMode
                ? widget.onTap
                : () => _handlePlayTap(playback),
            child: AnimatedContainer(
              duration: MotionTokens.durationFast,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.accentColor
                      : isPlaying
                          ? widget.accentColor.withValues(alpha: 0.7)
                          : (_hovering
                              ? widget.accentColor.withValues(alpha: 0.4)
                              : AppColors.border),
                  width: widget.isSelected || isPlaying ? 2 : 1,
                ),
                boxShadow: isPlaying
                    ? [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.2),
                          blurRadius: 12.r,
                          spreadRadius: 1.r,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  (RadiusTokens.lg - 1).r,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 渐变背景
                    _AudioBackground(
                      icon: icon,
                      accentColor: widget.accentColor,
                      isPlaying: isPlaying,
                      isHovering: _hovering,
                    ),

                    // 中央播放按钮
                    Center(
                      child: _PlayButton(
                        accentColor: widget.accentColor,
                        isPlaying: isPlaying,
                        isHovering: _hovering,
                      ),
                    ),

                    // 底部信息 + 进度条
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BottomInfo(
                        resource: widget.resource,
                        accentColor: widget.accentColor,
                        isPlaying: isPlaying,
                        progress: playback.progress,
                        position: playback.position,
                        duration: playback.duration,
                      ),
                    ),

                    // 选中遮罩
                    if (widget.isSelected)
                      Container(
                        color: widget.accentColor.withValues(alpha: 0.12),
                      ),

                    // Hover 操作图标
                    if (_showActions)
                      Positioned(
                        top: Spacing.xs.r,
                        right: Spacing.xs.r,
                        child: CardHoverActions(
                          actions: [
                            if (widget.onViewDetail != null)
                              CardActionIcon(
                                icon: AppIcons.info,
                                onTap: widget.onViewDetail!,
                                tooltip: '查看详情',
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
      },
    );
  }

  void _handlePlayTap(AudioPlaybackService playback) {
    final url = widget.resource.audioUrl;
    if (url.isEmpty) {
      widget.onViewDetail?.call();
      return;
    }
    playback.play(url);
  }
}

/// 渐变背景 + 子库图标
class _AudioBackground extends StatelessWidget {
  const _AudioBackground({
    required this.icon,
    required this.accentColor,
    required this.isPlaying,
    required this.isHovering,
  });

  final IconData icon;
  final Color accentColor;
  final bool isPlaying;
  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MotionTokens.durationMedium,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: isPlaying ? 0.12 : 0.06),
            accentColor.withValues(alpha: isPlaying ? 0.06 : 0.02),
          ],
        ),
      ),
      child: Align(
        alignment: const Alignment(0.6, -0.5),
        child: AnimatedOpacity(
          duration: MotionTokens.durationFast,
          opacity: isHovering ? 0.12 : 0.08,
          child: Icon(icon, size: 64.r, color: accentColor),
        ),
      ),
    );
  }
}

/// 中央播放/暂停圆形按钮
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.accentColor,
    required this.isPlaying,
    required this.isHovering,
  });

  final Color accentColor;
  final bool isPlaying;
  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    final double size = isHovering ? 52 : 48;
    return AnimatedContainer(
      duration: MotionTokens.durationFast,
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: isPlaying
            ? accentColor.withValues(alpha: 0.3)
            : accentColor.withValues(alpha: isHovering ? 0.2 : 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: isPlaying ? 0.6 : 0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        isPlaying ? AppIcons.stop : AppIcons.playArrow,
        size: 24.r,
        color: accentColor,
      ),
    );
  }
}

/// 底部区域：进度条 + 名称 + 时长 + 标签
class _BottomInfo extends StatelessWidget {
  const _BottomInfo({
    required this.resource,
    required this.accentColor,
    required this.isPlaying,
    required this.progress,
    required this.position,
    required this.duration,
  });

  final Resource resource;
  final Color accentColor;
  final bool isPlaying;
  final double progress;
  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final durationStr = _extractDuration();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 播放进度条
        AnimatedContainer(
          duration: MotionTokens.durationFast,
          height: Spacing.progressBarHeight.r,
          color: AppColors.border.withValues(alpha: 0.3),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: isPlaying ? progress : 0,
            child: Container(color: accentColor),
          ),
        ),

        // 信息区
        Container(
          padding: EdgeInsets.fromLTRB(
            Spacing.sm.w,
            Spacing.xs.h,
            Spacing.sm.w,
            Spacing.sm.h,
          ),
          color: AppColors.surfaceContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 名称 + 时长
              Row(
                children: [
                  Expanded(
                    child: Text(
                      resource.name,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (durationStr.isNotEmpty) ...[
                    SizedBox(width: Spacing.xs.w),
                    Text(
                      isPlaying
                          ? formatDuration(position)
                          : durationStr,
                      style: AppTextStyles.tiny.copyWith(
                        color: isPlaying
                            ? accentColor
                            : AppColors.mutedDark,
                      ),
                    ),
                  ],
                ],
              ),

              // 标签
              if (resource.tags.isNotEmpty) ...[
                SizedBox(height: Spacing.xxs.h),
                Row(
                  children: resource.tags
                      .take(2)
                      .map((tag) => Padding(
                            padding: EdgeInsets.only(right: Spacing.xs.w),
                            child: ResourceTagChip(
                              label: tag,
                              accentColor: accentColor,
                              small: true,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 从 metadata 中提取时长，或使用播放服务的 duration
  String _extractDuration() {
    final meta = resource.metadata;
    final d = meta['duration'];
    if (d is num && d > 0) {
      return formatDuration(Duration(milliseconds: (d * 1000).toInt()));
    }
    if (d is String && d.isNotEmpty) return d;
    if (isPlaying && duration.inMilliseconds > 0) {
      return formatDuration(duration);
    }
    return '';
  }
}


