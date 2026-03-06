import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

/// Global singleton for audio playback. Ensures only one audio plays at a time.
class AudioPlaybackService extends ChangeNotifier {
  AudioPlaybackService._();
  static final instance = AudioPlaybackService._();

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;

  String _currentUrl = '';
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  /// 播放来源标记，用于区分同一 URL 在不同上下文（列表 vs 详情弹窗）的播放
  String _source = 'list';

  String get currentUrl => _currentUrl;
  bool get isPlaying => _playing;
  String get source => _source;
  Duration get position => _position;
  Duration get duration => _duration;

  double get progress =>
      _duration.inMilliseconds > 0
          ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0, 1)
          : 0;

  bool isPlayingUrl(String url) => _playing && _currentUrl == url;

  /// 按来源判断是否正在播放，避免详情弹窗的试听影响列表项图标
  bool isPlayingUrlFrom(String url, String fromSource) =>
      _playing && _currentUrl == url && _source == fromSource;

  /// 播放音频。[source] 标记播放来源（默认 'list'）
  /// [onError] 在加载/播放失败时回调
  Future<void> play(
    String url, {
    String source = 'list',
    void Function(String message)? onError,
  }) async {
    final resolved = resolveFileUrl(url);

    if (_currentUrl == url && _playing) {
      await stop();
      return;
    }

    await _player.stop();
    _playing = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _currentUrl = url;
    _source = source;
    notifyListeners();

    try {
      final dur = await _player.setUrl(resolved);
      _duration = dur ?? Duration.zero;

      _stateSub?.cancel();
      _stateSub = _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _playing = false;
          _position = Duration.zero;
          notifyListeners();
        }
      });

      _posSub?.cancel();
      _posSub = _player.positionStream.listen((pos) {
        _position = pos;
        notifyListeners();
      });

      _playing = true;
      notifyListeners();
      await _player.play();
    } catch (e) {
      debugPrint('AudioPlaybackService.play error: $e');
      _playing = false;
      _currentUrl = '';
      notifyListeners();
      onError?.call(e.toString().replaceFirst(RegExp(r'^Exception: '), ''));
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _playing = false;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

/// Format [Duration] as "m:ss".
String formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
