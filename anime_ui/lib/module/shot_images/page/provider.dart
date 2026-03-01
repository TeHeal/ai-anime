import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/shot_image_svc.dart';

final shotImageServiceProvider = Provider((_) => ShotImageService());

// ─── 镜图生成配置 ───

class ShotImageConfig {
  final String globalPrompt;
  final String negativePrompt;
  final String provider;
  final String model;
  final int outputCount;
  final String aspectRatio;
  final bool cardMode;
  final bool includeAdjacent;

  const ShotImageConfig({
    this.globalPrompt = '',
    this.negativePrompt = '失真，穿帮，模糊，低质量',
    this.provider = '',
    this.model = '',
    this.outputCount = 1,
    this.aspectRatio = '16:9',
    this.cardMode = false,
    this.includeAdjacent = true,
  });

  ShotImageConfig copyWith({
    String? globalPrompt,
    String? negativePrompt,
    String? provider,
    String? model,
    int? outputCount,
    String? aspectRatio,
    bool? cardMode,
    bool? includeAdjacent,
  }) {
    return ShotImageConfig(
      globalPrompt: globalPrompt ?? this.globalPrompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      outputCount: outputCount ?? this.outputCount,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      cardMode: cardMode ?? this.cardMode,
      includeAdjacent: includeAdjacent ?? this.includeAdjacent,
    );
  }

  Map<String, dynamic> toJson() => {
        'global_prompt': globalPrompt,
        'negative_prompt': negativePrompt,
        'provider': provider,
        'model': model,
        'output_count': outputCount,
        'aspect_ratio': aspectRatio,
        'card_mode': cardMode,
        'include_adjacent': includeAdjacent,
      };
}

final shotImageConfigProvider =
    NotifierProvider<ShotImageConfigNotifier, ShotImageConfig>(
  ShotImageConfigNotifier.new,
);

class ShotImageConfigNotifier extends Notifier<ShotImageConfig> {
  @override
  ShotImageConfig build() => const ShotImageConfig();

  void update({
    String? globalPrompt,
    String? negativePrompt,
    String? provider,
    String? model,
    int? outputCount,
    String? aspectRatio,
    bool? cardMode,
    bool? includeAdjacent,
  }) {
    state = state.copyWith(
      globalPrompt: globalPrompt,
      negativePrompt: negativePrompt,
      provider: provider,
      model: model,
      outputCount: outputCount,
      aspectRatio: aspectRatio,
      cardMode: cardMode,
      includeAdjacent: includeAdjacent,
    );
  }
}

// ─── 镜图生成状态（按镜头） ───

enum ShotImageStatus { notStarted, generating, completed, failed, rejected }

class ShotImageState {
  final int shotId;
  final ShotImageStatus status;
  final int progress;
  final String? imageUrl;
  final int candidateCount;
  final String? error;

  const ShotImageState({
    required this.shotId,
    this.status = ShotImageStatus.notStarted,
    this.progress = 0,
    this.imageUrl,
    this.candidateCount = 0,
    this.error,
  });
}

final shotImageStatesProvider =
    NotifierProvider<ShotImageStatesNotifier, Map<int, ShotImageState>>(
  ShotImageStatesNotifier.new,
);

class ShotImageStatesNotifier extends Notifier<Map<int, ShotImageState>> {
  @override
  Map<int, ShotImageState> build() => {};

  void initFromShots(List<StoryboardShot> shots) {
    final map = <int, ShotImageState>{};
    for (final shot in shots) {
      final id = shot.id;
      if (id == null) continue;
      final status = _parseStatus(shot.status);
      final imageUrl = shot.imageUrl;
      map[id] = ShotImageState(
        shotId: id,
        status: status,
        progress: status == ShotImageStatus.completed ? 100 : 0,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      );
    }
    state = map;
  }

  Future<void> batchGenerate(List<int> shotIds) async {
    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid == null) return;
    final config = ref.read(shotImageConfigProvider);

    final updated = Map<int, ShotImageState>.from(state);
    for (final id in shotIds) {
      updated[id] = ShotImageState(
        shotId: id,
        status: ShotImageStatus.generating,
      );
    }
    state = updated;

    try {
      await ref
          .read(shotImageServiceProvider)
          .batchGenerate(pid, shotIds: shotIds, config: config.toJson());
    } catch (e) {
      final failed = Map<int, ShotImageState>.from(state);
      for (final id in shotIds) {
        failed[id] = ShotImageState(
          shotId: id,
          status: ShotImageStatus.failed,
          error: e.toString(),
        );
      }
      state = failed;
    }
  }

  ShotImageStatus _parseStatus(String? s) {
    switch (s) {
      case 'generating':
        return ShotImageStatus.generating;
      case 'completed':
        return ShotImageStatus.completed;
      case 'failed':
        return ShotImageStatus.failed;
      default:
        return ShotImageStatus.notStarted;
    }
  }
}
