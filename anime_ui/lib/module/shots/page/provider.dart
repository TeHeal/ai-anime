import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/pub/services/shot_composite_svc.dart';

final shotCompositeServiceProvider = Provider((_) => ShotCompositeService());

// ─── 复合生成配置 ───

class CompositeConfig {
  final bool enableVideo;
  final bool enableVO;
  final bool enableBGM;
  final bool enableFoley;
  final bool enableDynamicSFX;
  final bool enableAmbient;
  final bool enableLipSync;

  final String videoPrompt;
  final String negativePrompt;
  final String aspectRatio;
  final int frameRate;

  final String videoProvider;
  final String videoModel;
  final String ttsProvider;
  final String ttsModel;
  final String bgmProvider;
  final String bgmModel;
  final String sfxProvider;
  final String sfxModel;
  final String lipSyncProvider;
  final String lipSyncModel;

  final int concurrency;
  final String failStrategy;
  final int maxRetry;

  const CompositeConfig({
    this.enableVideo = true,
    this.enableVO = true,
    this.enableBGM = true,
    this.enableFoley = false,
    this.enableDynamicSFX = false,
    this.enableAmbient = false,
    this.enableLipSync = true,
    this.videoPrompt = '',
    this.negativePrompt = '模糊，抖动，跳帧，画面撕裂',
    this.aspectRatio = '16:9',
    this.frameRate = 24,
    this.videoProvider = '',
    this.videoModel = '',
    this.ttsProvider = '',
    this.ttsModel = '',
    this.bgmProvider = '',
    this.bgmModel = '',
    this.sfxProvider = '',
    this.sfxModel = '',
    this.lipSyncProvider = '',
    this.lipSyncModel = '',
    this.concurrency = 3,
    this.failStrategy = 'skip',
    this.maxRetry = 3,
  });

  CompositeConfig copyWith({
    bool? enableVideo,
    bool? enableVO,
    bool? enableBGM,
    bool? enableFoley,
    bool? enableDynamicSFX,
    bool? enableAmbient,
    bool? enableLipSync,
    String? videoPrompt,
    String? negativePrompt,
    String? aspectRatio,
    int? frameRate,
    String? videoProvider,
    String? videoModel,
    String? ttsProvider,
    String? ttsModel,
    String? bgmProvider,
    String? bgmModel,
    String? sfxProvider,
    String? sfxModel,
    String? lipSyncProvider,
    String? lipSyncModel,
    int? concurrency,
    String? failStrategy,
    int? maxRetry,
  }) {
    return CompositeConfig(
      enableVideo: enableVideo ?? this.enableVideo,
      enableVO: enableVO ?? this.enableVO,
      enableBGM: enableBGM ?? this.enableBGM,
      enableFoley: enableFoley ?? this.enableFoley,
      enableDynamicSFX: enableDynamicSFX ?? this.enableDynamicSFX,
      enableAmbient: enableAmbient ?? this.enableAmbient,
      enableLipSync: enableLipSync ?? this.enableLipSync,
      videoPrompt: videoPrompt ?? this.videoPrompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      frameRate: frameRate ?? this.frameRate,
      videoProvider: videoProvider ?? this.videoProvider,
      videoModel: videoModel ?? this.videoModel,
      ttsProvider: ttsProvider ?? this.ttsProvider,
      ttsModel: ttsModel ?? this.ttsModel,
      bgmProvider: bgmProvider ?? this.bgmProvider,
      bgmModel: bgmModel ?? this.bgmModel,
      sfxProvider: sfxProvider ?? this.sfxProvider,
      sfxModel: sfxModel ?? this.sfxModel,
      lipSyncProvider: lipSyncProvider ?? this.lipSyncProvider,
      lipSyncModel: lipSyncModel ?? this.lipSyncModel,
      concurrency: concurrency ?? this.concurrency,
      failStrategy: failStrategy ?? this.failStrategy,
      maxRetry: maxRetry ?? this.maxRetry,
    );
  }

  Map<String, dynamic> toJson() => {
        'enable_video': enableVideo,
        'enable_vo': enableVO,
        'enable_bgm': enableBGM,
        'enable_foley': enableFoley,
        'enable_dynamic_sfx': enableDynamicSFX,
        'enable_ambient': enableAmbient,
        'enable_lip_sync': enableLipSync,
        'video_prompt': videoPrompt,
        'negative_prompt': negativePrompt,
        'aspect_ratio': aspectRatio,
        'frame_rate': frameRate,
        'video_provider': videoProvider,
        'video_model': videoModel,
        'tts_provider': ttsProvider,
        'tts_model': ttsModel,
        'bgm_provider': bgmProvider,
        'bgm_model': bgmModel,
        'sfx_provider': sfxProvider,
        'sfx_model': sfxModel,
        'lip_sync_provider': lipSyncProvider,
        'lip_sync_model': lipSyncModel,
        'concurrency': concurrency,
        'fail_strategy': failStrategy,
        'max_retry': maxRetry,
      };

  int get enabledCount => [
        enableVideo,
        enableVO,
        enableBGM,
        enableFoley,
        enableDynamicSFX,
        enableAmbient,
        enableLipSync,
      ].where((e) => e).length;
}

final compositeConfigProvider =
    NotifierProvider<CompositeConfigNotifier, CompositeConfig>(
        CompositeConfigNotifier.new);

class CompositeConfigNotifier extends Notifier<CompositeConfig> {
  @override
  CompositeConfig build() => const CompositeConfig();

  void toggleTask(String type, bool enabled) {
    state = switch (type) {
      'video' => state.copyWith(enableVideo: enabled),
      'vo' => state.copyWith(enableVO: enabled),
      'bgm' => state.copyWith(enableBGM: enabled),
      'foley' => state.copyWith(enableFoley: enabled),
      'dynamic_sfx' => state.copyWith(enableDynamicSFX: enabled),
      'ambient' => state.copyWith(enableAmbient: enabled),
      'lip_sync' => state.copyWith(enableLipSync: enabled),
      _ => state,
    };
  }

  void updateModel(String type, String provider, String model) {
    state = switch (type) {
      'video' => state.copyWith(videoProvider: provider, videoModel: model),
      'tts' => state.copyWith(ttsProvider: provider, ttsModel: model),
      'bgm' => state.copyWith(bgmProvider: provider, bgmModel: model),
      'sfx' => state.copyWith(sfxProvider: provider, sfxModel: model),
      'lip_sync' =>
        state.copyWith(lipSyncProvider: provider, lipSyncModel: model),
      _ => state,
    };
  }

  void update({
    String? videoPrompt,
    String? negativePrompt,
    int? concurrency,
  }) {
    state = state.copyWith(
      videoPrompt: videoPrompt,
      negativePrompt: negativePrompt,
      concurrency: concurrency,
    );
  }
}

// ─── 复合镜头状态 ───

enum CompositeShotStatus {
  notStarted,
  generating,
  partialComplete,
  completed,
  failed,
}

class CompositeShotState {
  final String shotId;
  final CompositeShotStatus status;
  final Map<String, SubtaskState> subtasks;

  const CompositeShotState({
    required this.shotId,
    this.status = CompositeShotStatus.notStarted,
    this.subtasks = const {},
  });

  int get completedCount => subtasks.values.where((s) => s.isComplete).length;
  int get totalCount => subtasks.length;
  int get progressPercent =>
      totalCount > 0 ? (completedCount * 100 ~/ totalCount) : 0;
}

class SubtaskState {
  final String type;
  final String status;
  final int progress;
  final String? outputUrl;

  const SubtaskState({
    required this.type,
    this.status = 'pending',
    this.progress = 0,
    this.outputUrl,
  });

  bool get isComplete => status == 'completed';
  bool get isRunning => status == 'running';
  bool get isFailed => status == 'failed';
  bool get isWaiting => status == 'waiting';
}

final compositeShotStatesProvider =
    NotifierProvider<CompositeShotStatesNotifier, Map<String, CompositeShotState>>(
        CompositeShotStatesNotifier.new);

class CompositeShotStatesNotifier
    extends Notifier<Map<String, CompositeShotState>> {
  @override
  Map<String, CompositeShotState> build() => {};

  Future<void> batchGenerate(List<String> shotIds) async {
    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid == null) return;
    final config = ref.read(compositeConfigProvider);

    final updated = Map<String, CompositeShotState>.from(state);
    for (final id in shotIds) {
      updated[id] = CompositeShotState(
          shotId: id, status: CompositeShotStatus.generating);
    }
    state = updated;

    try {
      await ref
          .read(shotCompositeServiceProvider)
          .batchGenerate(pid, shotIds: shotIds, config: config.toJson());
    } catch (e, st) {
      debugPrint('ShotCompositeNotifier.batchGenerate: $e');
      debugPrint(st.toString());
      final failed = Map<String, CompositeShotState>.from(state);
      for (final id in shotIds) {
        failed[id] =
            CompositeShotState(shotId: id, status: CompositeShotStatus.failed);
      }
      state = failed;
    }
  }
}
