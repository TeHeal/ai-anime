import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/shot_svc.dart';

final shotServiceProvider = Provider((_) => ShotService());

/// 镜头列表
class ShotsNotifier extends Notifier<AsyncValue<List<StoryboardShot>>> {
  @override
  AsyncValue<List<StoryboardShot>> build() => const AsyncValue.data([]);

  ShotService get _svc => ref.read(shotServiceProvider);
  int? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> load() async {
    final pid = _projectId;
    if (pid == null) return;
    state = const AsyncValue.loading();
    try {
      final shots = await _svc.list(pid);
      state = AsyncValue.data(shots);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final shotsProvider =
    NotifierProvider<ShotsNotifier, AsyncValue<List<StoryboardShot>>>(
  ShotsNotifier.new,
);
