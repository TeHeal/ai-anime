import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/timeline.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/timeline_svc.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/primary_btn.dart';
import 'package:anime_ui/pub/widgets/secondary_btn.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

/// 可视化时间线预览：时间标尺、视频轨、字幕轨
class TimelinePreview extends ConsumerStatefulWidget {
  const TimelinePreview({super.key});

  @override
  ConsumerState<TimelinePreview> createState() => _TimelinePreviewState();
}

class _TimelinePreviewState extends ConsumerState<TimelinePreview> {
  final _timelineSvc = TimelineService();
  final _scrollController = ScrollController();
  ProjectTimeline? _timeline;
  bool _loading = true;
  bool _regenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> _load() async {
    final pid = _projectId;
    if (pid == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tl = await _timelineSvc.get(pid);
      if (mounted) setState(() => _timeline = tl);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _autoGenerate() async {
    final pid = _projectId;
    if (pid == null) return;
    setState(() {
      _regenerating = true;
      _error = null;
    });
    try {
      final tl = await _timelineSvc.autoGenerate(pid);
      if (mounted) {
        setState(() => _timeline = tl);
        showToast(context, '时间线已重新生成');

      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        showToast(context, '生成失败: $e', isError: true);

      }
    } finally {
      if (mounted) setState(() => _regenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error != null && _timeline == null) return _buildError();

    final timeline = _timeline;
    if (timeline == null || timeline.tracks.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToolbar(timeline),
        SizedBox(height: Spacing.md.h),
        Expanded(child: _buildTimelineArea(timeline)),
      ],
    );
  }

  Widget _buildToolbar(ProjectTimeline timeline) {
    final totalMs = timeline.duration;
    final totalSec = (totalMs / 1000).toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.xl.w),
      child: Row(
        children: [
          Icon(AppIcons.video, color: AppColors.primary, size: 20.r),
          SizedBox(width: Spacing.sm.w),
          Text(
            '时间线预览',
            style: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
          ),
          SizedBox(width: Spacing.md.w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            ),
            child: Text(
              '总时长 ${totalSec}s',
              style:
                  AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
            ),
          ),
          const Spacer(),
          PrimaryBtn(
            label: _regenerating ? '生成中…' : '自动生成时间线',
            onPressed: _regenerating ? null : _autoGenerate,
          ),
          SizedBox(width: Spacing.sm.w),
          SecondaryBtn(label: '导出成片', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildTimelineArea(ProjectTimeline timeline) {
    final totalMs = math.max(timeline.duration, 1.0);
    final pixelsPerMs = 0.12.w;
    final totalWidth = totalMs * pixelsPerMs;

    final videoTrack = timeline.tracks
        .where((t) => t.type == 'video')
        .toList();
    final subtitleTrack = timeline.tracks
        .where((t) => t.type == 'subtitle')
        .toList();
    final otherTracks = timeline.tracks
        .where((t) => t.type != 'video' && t.type != 'subtitle')
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Spacing.xl.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(totalWidth, MediaQuery.of(context).size.width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimeRuler(totalMs: totalMs, pixelsPerMs: pixelsPerMs),
                ...videoTrack.map(
                  (t) => _TrackRow(
                    track: t,
                    totalMs: totalMs,
                    pixelsPerMs: pixelsPerMs,
                    color: AppColors.primary,
                    labelPrefix: 'V',
                  ),
                ),
                ...subtitleTrack.map(
                  (t) => _TrackRow(
                    track: t,
                    totalMs: totalMs,
                    pixelsPerMs: pixelsPerMs,
                    color: AppColors.info,
                    labelPrefix: 'S',
                  ),
                ),
                ...otherTracks.map(
                  (t) => _TrackRow(
                    track: t,
                    totalMs: totalMs,
                    pixelsPerMs: pixelsPerMs,
                    color: AppColors.secondary,
                    labelPrefix: 'A',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: Spacing.lg.h),
          Text(
            '加载时间线…',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.video, size: 48.r, color: AppColors.mutedDarker),
          SizedBox(height: Spacing.lg.h),
          Text(
            '暂无时间线数据',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
          SizedBox(height: Spacing.lg.h),
          PrimaryBtn(
            label: _regenerating ? '生成中…' : '自动生成时间线',
            onPressed: _regenerating ? null : _autoGenerate,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 48.r, color: AppColors.mutedDarker),
          SizedBox(height: Spacing.lg.h),
          Text(
            '加载失败: $_error',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Spacing.lg.h),
          SecondaryBtn(label: '重试', onPressed: _load),
        ],
      ),
    );
  }
}

/// 时间标尺
class _TimeRuler extends StatelessWidget {
  const _TimeRuler({required this.totalMs, required this.pixelsPerMs});

  final double totalMs;
  final double pixelsPerMs;

  @override
  Widget build(BuildContext context) {
    final intervalMs = _calcInterval(totalMs);
    final tickCount = (totalMs / intervalMs).ceil() + 1;

    return Container(
      height: 28.h,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Stack(
        children: List.generate(tickCount, (i) {
          final ms = i * intervalMs;
          final x = ms * pixelsPerMs;
          return Positioned(
            left: x,
            top: 0,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(width: 1, height: 10.h, color: AppColors.mutedDark),
                SizedBox(width: 2.w),
                Text(
                  _formatTime(ms),
                  style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.mutedDark,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  double _calcInterval(double totalMs) {
    if (totalMs <= 10000) return 1000;
    if (totalMs <= 30000) return 2000;
    if (totalMs <= 60000) return 5000;
    return 10000;
  }

  String _formatTime(double ms) {
    final sec = ms / 1000;
    final m = (sec ~/ 60);
    final s = (sec % 60).toInt();
    if (m > 0) return '$m:${s.toString().padLeft(2, '0')}';
    return '0:${s.toString().padLeft(2, '0')}';
  }
}

/// 单个轨道行
class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.totalMs,
    required this.pixelsPerMs,
    required this.color,
    required this.labelPrefix,
  });

  final Track track;
  final double totalMs;
  final double pixelsPerMs;
  final Color color;
  final String labelPrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Stack(
        children: [
          // 轨道标签
          Positioned(
            left: Spacing.sm.w,
            top: Spacing.xs.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xs.w,
                vertical: Spacing.xxs.h,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              ),
              child: Text(
                track.name.isNotEmpty ? track.name : track.type,
                style: AppTextStyles.labelTiny.copyWith(color: color),
              ),
            ),
          ),
          // 轨道块
          ...track.items.map((item) {
            final left = item.startAt * pixelsPerMs;
            final width =
                math.max(item.duration * pixelsPerMs, 20.w);
            return Positioned(
              left: left,
              top: 18.h,
              child: _TrackBlock(
                item: item,
                width: width,
                color: color,
                labelPrefix: labelPrefix,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 轨道上的单个块
class _TrackBlock extends StatefulWidget {
  const _TrackBlock({
    required this.item,
    required this.width,
    required this.color,
    required this.labelPrefix,
  });

  final TrackItem item;
  final double width;
  final Color color;
  final String labelPrefix;

  @override
  State<_TrackBlock> createState() => _TrackBlockState();
}

class _TrackBlockState extends State<_TrackBlock> {
  bool _hovered = false;

  String get _durationText {
    final sec = widget.item.duration / 1000;
    return '${sec.toStringAsFixed(1)}s';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: '${widget.item.label}\n时长: $_durationText',
        waitDuration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: 32.h,
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.5)
                : widget.color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: _hovered
                  ? widget.color
                  : widget.color.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: Spacing.xs.w),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  widget.item.label,
                  style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.width > 60.w) ...[
                SizedBox(width: Spacing.xxs.w),
                Text(
                  _durationText,
                  style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
