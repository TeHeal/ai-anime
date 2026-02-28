import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/shots/page/review_ui_provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// 顶部播放器栏：视频预览 + 音轨混音器 + 播放模式选择
class ReviewPlayerBar extends ConsumerWidget {
  final dynamic shot;

  const ReviewPlayerBar({super.key, required this.shot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(shotsReviewUiProvider);
    final uiNotifier = ref.read(shotsReviewUiProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rightPanelBackground,
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _videoPlaceholder(),
              const SizedBox(width: 16),
              Expanded(child: _audioMixer()),
            ],
          ),
          const SizedBox(height: 12),
          _playbackModeRow(uiState, uiNotifier),
        ],
      ),
    );
  }

  Widget _videoPlaceholder() {
    return Container(
      width: 320,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.play, size: 36, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text('视频播放器',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text('00:00 / ${shot?.duration ?? 0}s',
                style: TextStyle(fontSize: 11, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _audioMixer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '#${(shot?.sortIndex ?? 0) + 1} ${shot?.cameraType ?? ''} · ${shot?.duration ?? 0}s',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 12),
        _audioTrackRow('🎤 VO', 0.8),
        _audioTrackRow('🎵 BGM', 0.6),
        _audioTrackRow('🔊 拟声', 0.7),
        _audioTrackRow('🔊 氛围', 0.4),
      ],
    );
  }

  Widget _audioTrackRow(String label, double volume) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ),
          Icon(AppIcons.play, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: volume,
                backgroundColor: Colors.grey[800],
                color: AppColors.primary.withValues(alpha: 0.6),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(volume.toStringAsFixed(1),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _playbackModeRow(
      ShotsReviewUiState uiState, ShotsReviewUiNotifier uiNotifier) {
    const modes = [
      ('composite', '🎬 完整合成'),
      ('video_only', '📹 仅视频'),
      ('vo_only', '🎤 仅VO'),
      ('bgm_only', '🎵 仅BGM'),
      ('video_vo', '📹+🎤'),
      ('lip_focus', '👄 口型聚焦'),
    ];

    return Row(
      children: [
        Text('播放模式:',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(width: 8),
        for (final (key, label) in modes) ...[
          _playbackModeChip(key, label, uiState, uiNotifier),
          const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _playbackModeChip(String mode, String label,
      ShotsReviewUiState uiState, ShotsReviewUiNotifier uiNotifier) {
    final active = uiState.playbackMode == mode;
    return GestureDetector(
      onTap: () => uiNotifier.setPlaybackMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.grey[800]!,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: active ? AppColors.primary : Colors.grey[500])),
      ),
    );
  }
}
