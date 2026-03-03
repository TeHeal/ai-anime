import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/shot_svc.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/primary_btn.dart';
import 'package:anime_ui/pub/widgets/secondary_btn.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

/// 音频/字幕管理页：配音状态、字幕预览、批量 TTS、SRT 导出
class AudioSubtitlePage extends ConsumerStatefulWidget {
  const AudioSubtitlePage({super.key});

  @override
  ConsumerState<AudioSubtitlePage> createState() => _AudioSubtitlePageState();
}

class _AudioSubtitlePageState extends ConsumerState<AudioSubtitlePage> {
  final _shotSvc = ShotService();
  bool _generating = false;

  Future<void> _batchTTS(String projectId, List<StoryboardShot> shots) async {
    final shotsWithDialogue = shots
        .where((s) => s.id != null && (s.dialogue ?? '').isNotEmpty)
        .toList();
    if (shotsWithDialogue.isEmpty) {
      if (mounted) {
        showToast(context, '没有可生成配音的镜头（需有台词）');

      }
      return;
    }
    setState(() => _generating = true);
    try {
      await _shotSvc.batchGenerateVideos(
        projectId,
        shotIds: shotsWithDialogue.map((s) => s.id!).toList(),
      );
      if (mounted) {
        showToast(context, '配音生成任务已提交');

        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        showToast(context, '配音生成失败: $e', isError: true);

      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  String _exportSubtitles(List<StoryboardShot> shots) {
    final buffer = StringBuffer();
    int index = 1;
    double currentTime = 0;
    for (final shot in shots) {
      final dialogue = shot.dialogue ?? '';
      if (dialogue.isEmpty) {
        currentTime += shot.duration.toDouble();
        continue;
      }
      final start = _formatSrtTime(currentTime);
      final end = _formatSrtTime(currentTime + shot.duration.toDouble());
      buffer.writeln('$index');
      buffer.writeln('$start --> $end');
      buffer.writeln(dialogue);
      buffer.writeln();
      index++;
      currentTime += shot.duration.toDouble();
    }
    return buffer.toString();
  }

  String _formatSrtTime(double seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = ((seconds % 60).toInt()).toString().padLeft(2, '0');
    final ms = ((seconds * 1000 % 1000).toInt()).toString().padLeft(3, '0');
    return '$h:$m:$s,$ms';
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(currentProjectProvider).value;
    if (project?.id == null) {
      return _buildEmpty('请先选择项目');
    }
    final projectId = project!.id!;

    return FutureBuilder<List<StoryboardShot>>(
      future: _shotSvc.list(projectId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (snap.hasError) {
          return _buildError(snap.error);
        }
        final shots = snap.data ?? [];
        if (shots.isEmpty) {
          return _buildEmpty('暂无镜头数据，请先在镜头模块生成');
        }
        return _buildContent(projectId, shots);
      },
    );
  }

  Widget _buildContent(String projectId, List<StoryboardShot> shots) {
    final shotsWithDialogue =
        shots.where((s) => (s.dialogue ?? '').isNotEmpty).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.xl.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(projectId, shots),
          SizedBox(height: Spacing.xl.h),
          _buildAudioSection(shots),
          SizedBox(height: Spacing.xl.h),
          _buildSubtitleSection(shotsWithDialogue),
        ],
      ),
    );
  }

  Widget _buildHeader(String projectId, List<StoryboardShot> shots) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '音频 / 字幕管理',
                style: AppTextStyles.h2.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(height: Spacing.xs.h),
              Text(
                '管理配音、背景音乐和字幕',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
        PrimaryBtn(
          label: _generating ? '生成中…' : '一键生成配音',
          onPressed: _generating ? null : () => _batchTTS(projectId, shots),
        ),
        SizedBox(width: Spacing.sm.w),
        SecondaryBtn(
          label: '导出字幕',
          onPressed: () {
            final srt = _exportSubtitles(shots);
            if (srt.isEmpty) {
              showToast(context, '没有可导出的字幕内容');

              return;
            }
            showToast(context, '字幕内容已生成（SRT 格式）');

          },
        ),
      ],
    );
  }

  Widget _buildAudioSection(List<StoryboardShot> shots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.mic, color: AppColors.primary, size: 20.r),
            SizedBox(width: Spacing.sm.w),
            Text(
              '音频',
              style: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
            ),
            SizedBox(width: Spacing.sm.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xxs.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Text(
                '${shots.length} 个镜头',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        ...shots.asMap().entries.map(
              (entry) => _AudioShotRow(index: entry.key, shot: entry.value),
            ),
      ],
    );
  }

  Widget _buildSubtitleSection(List<StoryboardShot> shotsWithDialogue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.document, color: AppColors.info, size: 20.r),
            SizedBox(width: Spacing.sm.w),
            Text(
              '字幕',
              style: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
            ),
            SizedBox(width: Spacing.sm.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xxs.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Text(
                '${shotsWithDialogue.length} 条字幕',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.info,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        if (shotsWithDialogue.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Spacing.xl.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            ),
            child: Center(
              child: Text(
                '暂无字幕内容（镜头尚无台词）',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            ),
          )
        else
          ...shotsWithDialogue.asMap().entries.map(
                (entry) =>
                    _SubtitleRow(index: entry.key, shot: entry.value),
              ),
      ],
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
            '加载镜头数据…',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.music, size: 48.r, color: AppColors.mutedDarker),
          SizedBox(height: Spacing.lg.h),
          Text(
            msg,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object? e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 48.r, color: AppColors.mutedDarker),
          SizedBox(height: Spacing.lg.h),
          Text(
            '加载失败: $e',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 音频列表中的单个镜头行
class _AudioShotRow extends StatelessWidget {
  const _AudioShotRow({required this.index, required this.shot});

  final int index;
  final StoryboardShot shot;

  @override
  Widget build(BuildContext context) {
    final hasDialogue = (shot.dialogue ?? '').isNotEmpty;
    final hasVoice = (shot.voiceName ?? '').isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(Spacing.md.r),
        child: Row(
          children: [
            // 缩略图占位
            Container(
              width: Spacing.thumbnailSize.w,
              height: Spacing.thumbnailSize.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Center(
                child: Icon(
                  AppIcons.video,
                  size: 20.r,
                  color: AppColors.mutedDark,
                ),
              ),
            ),
            SizedBox(width: Spacing.md.w),
            // 镜头信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shot ${index + 1}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: Spacing.xxs.h),
                  Text(
                    hasDialogue ? (shot.dialogue ?? '') : '（无台词）',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: hasDialogue
                          ? AppColors.onSurface.withValues(alpha: 0.8)
                          : AppColors.mutedDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: Spacing.md.w),
            // 时长
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
                '${shot.duration}s',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.mutedLight,
                ),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            // 配音状态
            _StatusBadge(
              label: hasVoice ? '已配音' : '未配音',
              color: hasVoice ? AppColors.success : AppColors.mutedDark,
            ),
            SizedBox(width: Spacing.sm.w),
            // BGM 状态
            _StatusBadge(
              label: (shot.audioDesign ?? '').isNotEmpty ? 'BGM' : '无BGM',
              color: (shot.audioDesign ?? '').isNotEmpty
                  ? AppColors.info
                  : AppColors.mutedDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// 字幕预览行
class _SubtitleRow extends StatelessWidget {
  const _SubtitleRow({required this.index, required this.shot});

  final int index;
  final StoryboardShot shot;

  String _formatTimestamp(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds.toInt() % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final dialogue = shot.dialogue ?? '';
    final startTime = shot.sortIndex * shot.duration.toDouble();

    return Card(
      margin: EdgeInsets.only(bottom: Spacing.xs.h),
      color: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg.w,
          vertical: Spacing.md.h,
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ),
            SizedBox(width: Spacing.md.w),
            Text(
              _formatTimestamp(startTime),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedDark,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(width: Spacing.md.w),
            if ((shot.characterName ?? '').isNotEmpty) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.xxs.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                ),
                child: Text(
                  shot.characterName!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
            ],
            Expanded(
              child: Text(
                dialogue,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '${shot.duration}s',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 小型状态徽章
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: color),
      ),
    );
  }
}
