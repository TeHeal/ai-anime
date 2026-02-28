import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/board/provider.dart';
import 'package:anime_ui/module/assets/characters/providers/characters_provider.dart';
import 'package:anime_ui/module/script/provider.dart';

/// 对象状态枚举
enum StepStatus { notStarted, inProgress, completed }

/// 各对象的状态集合 (6 个核心对象: 剧本/资产/脚本/镜图/镜头/成片)
class StepStatuses {
  final List<StepStatus> statuses;
  const StepStatuses(this.statuses);

  StepStatus operator [](int i) =>
      i >= 0 && i < statuses.length ? statuses[i] : StepStatus.notStarted;
}

/// 对象状态提供者 — 计算 6 个核心对象的完成状态
final stepStatusProvider = Provider<StepStatuses>((ref) {
  final episodes = ref.watch(episodesProvider).value ?? [];
  final chars = ref.watch(assetCharactersProvider).value ?? [];
  final shots = ref.watch(shotsProvider).value ?? [];

  final hasEpisodes = episodes.isNotEmpty;
  final hasScenes = episodes.any((e) => e.scenes.isNotEmpty);
  final hasChars = chars.isNotEmpty;
  final hasShots = shots.isNotEmpty;
  final allShotsHaveImages =
      shots.isNotEmpty && shots.every((s) => s.imageUrl.isNotEmpty);
  final allShotsHaveVideos =
      shots.isNotEmpty && shots.every((s) => s.videoUrl.isNotEmpty);

  // ① 剧本 Story
  final story = hasScenes
      ? StepStatus.completed
      : hasEpisodes
          ? StepStatus.inProgress
          : StepStatus.notStarted;

  // ② 资产 Assets
  final assets = hasChars ? StepStatus.completed : StepStatus.notStarted;

  // ③ 脚本 Script
  final script = hasShots
      ? (shots.every((s) => s.prompt.isNotEmpty)
          ? StepStatus.completed
          : StepStatus.inProgress)
      : StepStatus.notStarted;

  // ④ 镜图 Shot Images (replaces storyboard)
  final shotImages = allShotsHaveImages
      ? StepStatus.completed
      : (shots.any((s) => s.imageUrl.isNotEmpty)
          ? StepStatus.inProgress
          : StepStatus.notStarted);

  // ⑤ 镜头 Shots (composite: video + audio + lip sync)
  final shotsStatus = allShotsHaveVideos
      ? StepStatus.completed
      : (shots.any((s) => s.videoUrl.isNotEmpty)
          ? StepStatus.inProgress
          : StepStatus.notStarted);

  // ⑥ 成片 Episode
  const episode = StepStatus.notStarted;

  return StepStatuses([story, assets, script, shotImages, shotsStatus, episode]);
});
