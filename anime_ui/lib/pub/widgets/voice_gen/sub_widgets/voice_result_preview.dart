import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

/// Preview player for the generated voice result.
class VoiceResultPreview extends StatelessWidget {
  const VoiceResultPreview({
    super.key,
    required this.accent,
    required this.audioUrl,
    required this.isGenerating,
    required this.progress,
    this.errorMsg,
  });

  final Color accent;
  final String audioUrl;
  final bool isGenerating;
  final int progress;
  final String? errorMsg;

  @override
  Widget build(BuildContext context) {
    if (errorMsg != null) return _buildError();
    if (isGenerating) return _buildGenerating();
    if (audioUrl.isNotEmpty) return _buildResult();
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.mic, size: 32, color: Colors.grey[700]),
            const SizedBox(height: 10),
            Text(
              '生成结果将显示在此处',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              progress > 0 ? '生成中 $progress%…' : '音色生成中…',
              style: TextStyle(fontSize: 13, color: accent),
            ),
            const SizedBox(height: 6),
            Text(
              '此过程可能需要 10-60 秒',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.error, size: 20, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '生成失败',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
                if (errorMsg!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    errorMsg!,
                    style: TextStyle(fontSize: 12, color: Colors.red[300]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final playback = AudioPlaybackService.instance;
    return ListenableBuilder(
      listenable: playback,
      builder: (_, _) {
        final isPlaying = playback.isPlayingUrl(audioUrl);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => playback.play(audioUrl),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isPlaying ? 0.3 : 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        size: 26,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(AppIcons.check, size: 14, color: Colors.green[400]),
                            const SizedBox(width: 6),
                            Text(
                              '生成成功',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[400],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPlaying ? '正在播放试听…' : '点击播放试听效果',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  _buildMiniWaveform(isPlaying),
                ],
              ),
              if (isPlaying && playback.duration.inMilliseconds > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      formatDuration(playback.position),
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          activeTrackColor: accent,
                          inactiveTrackColor: accent.withValues(alpha: 0.15),
                          thumbColor: accent,
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                        ),
                        child: Slider(
                          value: playback.progress,
                          onChanged: (v) {
                            final dur = playback.duration;
                            playback.seek(Duration(
                              milliseconds: (v * dur.inMilliseconds).toInt(),
                            ));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatDuration(playback.duration),
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
            ? (8.0 + (i * 5 + DateTime.now().millisecond) % 16)
            : (6.0 + (i * 3) % 10);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 3,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: active ? 0.7 : 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
