import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

import '../models/resource_category.dart';
import 'resource_card.dart';

/// Preview 模式音频卡片 —— 沉浸审阅
///
/// 顶部为波形播放器区域（带播放按钮、进度条、时长），
/// 底部为详细信息区（名称、描述、标签、metadata chips、子库类型）。
class AudioPreviewCard extends StatefulWidget {
  const AudioPreviewCard({
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
    this.onGetPreviewUrl,
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
  /// 系统音色试听：当 audioUrl 为空时，调用此回调获取预览 URL 后播放
  final Future<String?> Function(Resource)? onGetPreviewUrl;

  @override
  State<AudioPreviewCard> createState() => _AudioPreviewCardState();
}

class _AudioPreviewCardState extends State<AudioPreviewCard> {
  bool _hovering = false;
  String? _resolvedPreviewUrl;

  String get _effectiveAudioUrl =>
      widget.resource.audioUrl.isNotEmpty
          ? widget.resource.audioUrl
          : (_resolvedPreviewUrl ?? '');

  @override
  Widget build(BuildContext context) {
    final playback = AudioPlaybackService.instance;
    final libType = ResourceLibraryType.values
        .where((t) => t.name == widget.resource.libraryType)
        .firstOrNull;

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final isPlaying = playback.isPlayingUrlFrom(_effectiveAudioUrl, 'list');

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
                      : isPlaying
                          ? widget.accentColor.withValues(alpha: 0.6)
                          : (_hovering
                              ? widget.accentColor.withValues(alpha: 0.4)
                              : AppColors.border),
                  width: widget.isSelected || isPlaying ? 2 : 1,
                ),
                boxShadow: isPlaying
                    ? [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.15),
                          blurRadius: 16.r,
                          spreadRadius: 1.r,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 波形播放器区域
                      _WaveformPlayer(
                        resource: widget.resource,
                        effectiveAudioUrl: _effectiveAudioUrl,
                        accentColor: widget.accentColor,
                        isPlaying: isPlaying,
                        isHovering: _hovering,
                        playback: playback,
                        onGetPreviewUrl: widget.onGetPreviewUrl,
                        onResolved: (url) {
                          if (mounted) setState(() => _resolvedPreviewUrl = url);
                        },
                      ),

                      // 信息区
                      _InfoSection(
                        resource: widget.resource,
                        accentColor: widget.accentColor,
                        libType: libType,
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
                      child: PreviewHoverMenu(
                        items: [
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
      },
    );
  }
}

/// 顶部波形播放器区域
class _WaveformPlayer extends StatelessWidget {
  const _WaveformPlayer({
    required this.resource,
    required this.effectiveAudioUrl,
    this.onGetPreviewUrl,
    this.onResolved,
    required this.accentColor,
    required this.isPlaying,
    required this.isHovering,
    required this.playback,
  });

  final Resource resource;
  final String effectiveAudioUrl;
  final Future<String?> Function(Resource)? onGetPreviewUrl;
  final void Function(String)? onResolved;
  final Color accentColor;
  final bool isPlaying;
  final bool isHovering;
  final AudioPlaybackService playback;

  @override
  Widget build(BuildContext context) {
    final hasAudio = effectiveAudioUrl.isNotEmpty || onGetPreviewUrl != null;
    final icon = resourceIcon(resource);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular((RadiusTokens.lg - 1).r),
      ),
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withValues(alpha: isPlaying ? 0.12 : 0.06),
              accentColor.withValues(alpha: isPlaying ? 0.04 : 0.02),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景装饰图标
            Positioned(
              right: Spacing.lg.w,
              top: Spacing.md.h,
              child: Opacity(
                opacity: 0.06,
                child: Icon(icon, size: 56.r, color: accentColor),
              ),
            ),

            // 波形条 + 播放控件
            Padding(
              padding: EdgeInsets.all(Spacing.lg.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 波形可视化
                  _WaveformBars(
                    accentColor: accentColor,
                    isPlaying: isPlaying,
                    progress: playback.progress,
                  ),

                  SizedBox(height: Spacing.md.h),

                  // 播放控件行
                  Row(
                    children: [
                      // 播放按钮
                      MouseRegion(
                        cursor: hasAudio ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: hasAudio ? () => _handlePlay() : null,
                          child: AnimatedContainer(
                            duration: MotionTokens.durationFast,
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                alpha: isPlaying ? 0.3 : 0.15,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Icon(
                              isPlaying
                                  ? AppIcons.stop
                                  : AppIcons.playArrow,
                              size: 20.r,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: Spacing.md.w),

                      // 进度条
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                RadiusTokens.xs.r,
                              ),
                              child: LinearProgressIndicator(
                                value: isPlaying ? playback.progress : 0,
                                minHeight: 4.r,
                                backgroundColor:
                                    accentColor.withValues(alpha: 0.12),
                                valueColor:
                                    AlwaysStoppedAnimation(accentColor),
                              ),
                            ),
                            SizedBox(height: Spacing.xs.h),
                            // 时间
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isPlaying
                                      ? formatDuration(playback.position)
                                      : '0:00',
                                  style: AppTextStyles.tiny.copyWith(
                                    color: isPlaying
                                        ? accentColor
                                        : AppColors.mutedDark,
                                  ),
                                ),
                                Text(
                                  _totalDuration(),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _totalDuration() {
    if (isPlaying && playback.duration.inMilliseconds > 0) {
      return formatDuration(playback.duration);
    }
    final meta = resource.metadata;
    final d = meta['duration'];
    if (d is num && d > 0) {
      return formatDuration(Duration(milliseconds: (d * 1000).toInt()));
    }
    if (d is String && d.isNotEmpty) return d;
    return '--:--';
  }

  Future<void> _handlePlay() async {
    if (effectiveAudioUrl.isNotEmpty) {
      playback.play(effectiveAudioUrl);
      return;
    }
    final url = await onGetPreviewUrl?.call(resource);
    if (url != null && url.isNotEmpty) {
      onResolved?.call(url);
      playback.play(url);
    }
  }
}

/// 伪波形可视化条
class _WaveformBars extends StatelessWidget {
  const _WaveformBars({
    required this.accentColor,
    required this.isPlaying,
    required this.progress,
  });

  final Color accentColor;
  final bool isPlaying;
  final double progress;

  static const _barCount = 32;
  // 预计算的伪随机高度比例（0~1），模拟真实波形
  static const _barHeights = [
    0.3, 0.5, 0.7, 0.4, 0.9, 0.6, 0.8, 0.3,
    0.5, 0.95, 0.7, 0.4, 0.6, 0.8, 0.5, 0.3,
    0.7, 0.6, 0.9, 0.4, 0.5, 0.8, 0.3, 0.7,
    0.6, 0.4, 0.8, 0.5, 0.9, 0.3, 0.7, 0.6,
  ];

  @override
  Widget build(BuildContext context) {
    final maxH = 36.h;
    final minH = 4.h;

    return SizedBox(
      height: maxH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_barCount, (i) {
          final ratio = _barHeights[i % _barHeights.length];
          final h = minH + (maxH - minH) * ratio;
          final barProgress = i / _barCount;
          final isPassed = isPlaying && barProgress <= progress;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: AnimatedContainer(
                duration: MotionTokens.durationFast,
                height: h,
                decoration: BoxDecoration(
                  color: isPassed
                      ? accentColor.withValues(alpha: 0.7)
                      : accentColor.withValues(
                          alpha: isPlaying ? 0.15 : 0.1,
                        ),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 信息区
class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.resource,
    required this.accentColor,
    this.libType,
  });

  final Resource resource;
  final Color accentColor;
  final ResourceLibraryType? libType;

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

          // 描述
          if (resource.description.isNotEmpty) ...[
            SizedBox(height: Spacing.xxs.h),
            Text(
              resource.description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.muted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

          // metadata chips（gender、provider 等）
          if (metaChips.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Wrap(
              spacing: Spacing.xs.w,
              runSpacing: Spacing.xxs.h,
              children: metaChips,
            ),
          ],

          SizedBox(height: Spacing.sm.h),

          // 底行：子库类型 + 时间
          Row(
            children: [
              if (libType != null) ...[
                Icon(
                  libType!.icon,
                  size: 14.r,
                  color: AppColors.mutedDark,
                ),
                SizedBox(width: Spacing.xxs.w),
                Text(
                  libType!.label,
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

  /// 从 metadata 中提取音频特有的信息展示为 chips
  List<Widget> _buildMetaChips() {
    final meta = resource.metadata;
    final chips = <Widget>[];

    final displayKeys = ['gender', 'provider', 'sampleRate', 'format'];
    final displayLabels = {
      'gender': null,
      'provider': null,
      'sampleRate': '采样率',
      'format': '格式',
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

