import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/services/audio_playback_svc.dart'
    show AudioPlaybackService, formatDuration;
import 'package:anime_ui/pub/widgets/image_lightbox.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';
import 'resource_form_dialog.dart';

/// 音色类素材（voice/voiceover/sfx/music）在详情弹窗中显示播放区
bool _isAudioResourceWithUrl(Resource r) {
  if (r.modality != 'audio') return false;
  const types = ['voice', 'voiceover', 'sfx', 'music'];
  return types.contains(r.libraryType) && r.audioUrl.isNotEmpty;
}

void showResourceDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required Resource resource,
  required Color accentColor,
}) {
  showDialog(
    context: context,
    builder: (_) => _ResourceDetailDialog(
      resource: resource,
      accentColor: accentColor,
    ),
  );
}

class _ResourceDetailDialog extends ConsumerWidget {
  const _ResourceDetailDialog({
    required this.resource,
    required this.accentColor,
  });

  final Resource resource;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libType = ResourceLibraryType.values
        .where((t) => t.name == resource.libraryType)
        .firstOrNull;

    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w, maxHeight: 640.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Spacing.xl.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resource.hasThumbnail &&
                        resource.modality == 'visual') ...[
                      GestureDetector(
                        onTap: () => showImageLightbox(
                          context,
                          imageUrl: resource.thumbnailUrl,
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.lg.r),
                          child: Image.network(
                            resolveFileUrl(resource.thumbnailUrl),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (_, Object? e, StackTrace? s) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      SizedBox(height: Spacing.lg.h),
                    ],
                    Text(
                      resource.name,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (libType != null)
                      Padding(
                        padding: EdgeInsets.only(top: Spacing.xxs.h),
                        child: Text(
                          libType.label,
                          style: AppTextStyles.caption.copyWith(
                            color: accentColor,
                          ),
                        ),
                      ),
                    if (_isAudioResourceWithUrl(resource)) ...[
                      SizedBox(height: Spacing.lg.h),
                      _VoicePlayerSection(
                        resource: resource,
                        accentColor: accentColor,
                      ),
                    ],
                    if (resource.description.isNotEmpty) ...[
                      SizedBox(height: Spacing.md.h),
                      Text(
                        '描述',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Spacing.xs.h),
                      Text(
                        resource.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                    if (resource.tags.isNotEmpty) ...[
                      SizedBox(height: Spacing.md.h),
                      Text(
                        '标签',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Spacing.xs.h),
                      Wrap(
                        spacing: Spacing.xs.w,
                        runSpacing: Spacing.xs.h,
                        children: resource.tags
                            .map((tag) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.sm.w,
                                    vertical: Spacing.xxs.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                      RadiusTokens.xs.r,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: AppTextStyles.caption.copyWith(
                                      color: accentColor,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                    if (resource.metadata.isNotEmpty) ...[
                      SizedBox(height: Spacing.md.h),
                      Text(
                        '元数据',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Spacing.xs.h),
                      ...resource.metadata.entries
                          .where((e) =>
                              e.value != null &&
                              e.value.toString().isNotEmpty)
                          .map((e) => Padding(
                                padding: EdgeInsets.only(bottom: Spacing.xs.h),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 100.w,
                                      child: Text(
                                        '${e.key}:',
                                        style: AppTextStyles.caption
                                            .copyWith(color: AppColors.muted),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value.toString(),
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: AppColors.onSurface),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ],
                    if (resource.bindingIds.isNotEmpty) ...[
                      SizedBox(height: Spacing.md.h),
                      Text(
                        '绑定',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Spacing.xs.h),
                      Text(
                        '${resource.bindingIds.length} 个绑定对象',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.lg.h,
        Spacing.md.w,
        Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '素材详情',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18.r, color: AppColors.muted),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.md.h,
        Spacing.xl.w,
        Spacing.lg.h,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () async {
              final libType = ResourceLibraryType.values
                  .where((t) => t.name == resource.libraryType)
                  .firstOrNull;
              if (libType == null) return;
              await showResourceFormDialog(
                context,
                ref,
                libraryType: libType,
                accentColor: accentColor,
                initial: resource,
              );
              if (context.mounted) Navigator.pop(context);
            },
            icon: Icon(AppIcons.edit, size: 16.r),
            label: const Text('编辑'),
            style: TextButton.styleFrom(foregroundColor: accentColor),
          ),
          SizedBox(width: Spacing.sm.w),
          TextButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('确认删除'),
                  content: Text(
                    '确定要删除「${resource.name}」吗？',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('删除'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(resourceListProvider.notifier).removeResource(
                      resource.id ?? '',
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: Icon(AppIcons.close, size: 16.r),
            label: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }
}

/// 音色播放区：播放、进度、波形
class _VoicePlayerSection extends StatelessWidget {
  const _VoicePlayerSection({
    required this.resource,
    required this.accentColor,
  });

  final Resource resource;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final playback = AudioPlaybackService.instance;
    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final isPlaying = playback.isPlayingUrl(resource.audioUrl);
        return Container(
          padding: EdgeInsets.all(Spacing.lg.r),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '试听',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Spacing.md.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        playback.stop();
                      } else {
                        playback.play(resource.audioUrl);
                      }
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.h,
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
                        isPlaying ? AppIcons.stop : AppIcons.playArrow,
                        size: 26.r,
                        color: accentColor,
                      ),
                    ),
                  ),
                  SizedBox(width: Spacing.gridGap.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPlaying ? '正在播放…' : '点击播放试听',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (resource.metadata['gender'] != null ||
                            resource.metadata['provider'] != null)
                          Padding(
                            padding: EdgeInsets.only(top: Spacing.xxs.h),
                            child: Wrap(
                              spacing: Spacing.sm.w,
                              children: [
                                if (resource.metadata['gender'] != null)
                                  _MetadataChip(
                                    label: resource.metadata['gender'].toString(),
                                    accentColor: accentColor,
                                  ),
                                if (resource.metadata['provider'] != null)
                                  _MetadataChip(
                                    label: resource.metadata['provider'].toString(),
                                    accentColor: accentColor,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildMiniWaveform(isPlaying),
                ],
              ),
              if (isPlaying && playback.duration.inMilliseconds > 0) ...[
                SizedBox(height: Spacing.md.h),
                Row(
                  children: [
                    Text(
                      formatDuration(playback.position),
                      style: AppTextStyles.labelTinySmall.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                    SizedBox(width: Spacing.sm.w),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: Spacing.progressBarHeight.r,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 5.r,
                          ),
                          activeTrackColor: accentColor,
                          inactiveTrackColor: accentColor.withValues(alpha: 0.15),
                          thumbColor: accentColor,
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 10.r,
                          ),
                        ),
                        child: Slider(
                          value: playback.progress,
                          onChanged: (v) {
                            final dur = playback.duration;
                            playback.seek(
                              Duration(
                                milliseconds:
                                    (v * dur.inMilliseconds).toInt(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.sm.w),
                    Text(
                      formatDuration(playback.duration),
                      style: AppTextStyles.labelTinySmall.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniWaveform(bool active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (i) {
        final h = active
            ? (8.0 + (i * 5) % 16)
            : (6.0 + (i * 3) % 10);
        return Container(
          width: 3.w,
          height: h.h,
          margin: EdgeInsets.symmetric(horizontal: Spacing.xxs.w),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: active ? 0.7 : 0.25),
            borderRadius: BorderRadius.circular((RadiusTokens.xs / 2).r),
          ),
        );
      }),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.label,
    required this.accentColor,
  });

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
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: accentColor.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
