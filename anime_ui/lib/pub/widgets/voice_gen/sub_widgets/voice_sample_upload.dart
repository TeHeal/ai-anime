import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

/// Upload area for voice clone sample audio.
class VoiceSampleUpload extends StatelessWidget {
  const VoiceSampleUpload({
    super.key,
    required this.accent,
    required this.sampleUrl,
    required this.sampleFileName,
    required this.onUpload,
    required this.onRemove,
  });

  final Color accent;
  final String sampleUrl;
  final String sampleFileName;
  final Future<void> Function(List<int> bytes, String fileName) onUpload;
  final VoidCallback onRemove;

  bool get _hasSample => sampleUrl.isNotEmpty;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    await onUpload(file.bytes!, file.name);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSample) return _buildUploaded(context);
    return _buildEmpty();
  }

  Widget _buildEmpty() {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accent.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.upload, size: 28, color: accent.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              '上传音频样本',
              style: TextStyle(fontSize: 13, color: accent.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 4),
            Text(
              '支持 MP3、WAV 格式，建议 10-60 秒',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploaded(BuildContext context) {
    final playback = AudioPlaybackService.instance;
    return ListenableBuilder(
      listenable: playback,
      builder: (_, _) {
        final isPlaying = playback.isPlayingUrl(sampleUrl);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => playback.play(sampleUrl),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isPlaying ? 0.25 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 22,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleFileName,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPlaying
                          ? '${formatDuration(playback.position)} / ${formatDuration(playback.duration)}'
                          : '已上传',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(AppIcons.close, size: 16, color: Colors.grey[500]),
                onPressed: onRemove,
                tooltip: '移除',
              ),
              IconButton(
                icon: Icon(AppIcons.refresh, size: 16, color: Colors.grey[500]),
                onPressed: _pick,
                tooltip: '重新选择',
              ),
            ],
          ),
        );
      },
    );
  }
}
