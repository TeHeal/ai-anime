import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

/// 音频资源卡片的播放覆盖层：播放/暂停按钮、进度条
class AudioPlayOverlay extends StatelessWidget {
  const AudioPlayOverlay({
    super.key,
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
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(Spacing.sm.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  accentColor.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(
                            alpha: isPlaying ? 0.35 : 0.2,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Icon(
                          isPlaying ? AppIcons.stop : AppIcons.playArrow,
                          size: 18.r,
                          color: accentColor,
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.sm.w),
                    Expanded(
                      child: Text(
                        isPlaying ? '播放中' : '点击播放',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isPlaying && playback.duration.inMilliseconds > 0) ...[
                  SizedBox(height: Spacing.xs.h),
                  Row(
                    children: [
                      Text(
                        formatDuration(playback.position),
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.mutedDark,
                        ),
                      ),
                      SizedBox(width: Spacing.xs.w),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2.r,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 4.r,
                            ),
                            activeTrackColor: accentColor,
                            inactiveTrackColor:
                                accentColor.withValues(alpha: 0.2),
                            thumbColor: accentColor,
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 8.r,
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
                      SizedBox(width: Spacing.xs.w),
                      Text(
                        formatDuration(playback.duration),
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
