import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/main.dart';
import 'package:anime_ui/pub/models/project.dart';
import 'package:anime_ui/pub/services/project_svc.dart';
import 'lock_provider.dart';

class CurrentProjectNotifier extends Notifier<AsyncValue<Project?>> {
  @override
  AsyncValue<Project?> build() => const AsyncValue.data(null);

  final _svc = ProjectService();

  int? get projectId => state.value?.id;

  Future<void> load(int id) async {
    state = const AsyncValue.loading();
    try {
      final raw = await _svc.getRaw(id);
      final p = Project.fromJson(raw);
      state = AsyncValue.data(p);
      final lockJson = raw['lock_status'] as Map<String, dynamic>?;
      ref.read(lockProvider.notifier).updateFromProjectResponse(lockJson);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Project> create({
    required String name,
    String story = '',
    String storyMode = 'full_script',
    ProjectConfig? config,
  }) async {
    final p = await _svc.create(
      name: name,
      story: story,
      storyMode: storyMode,
      config: config,
    );
    state = AsyncValue.data(p);
    storageService.setCurrentProjectId(p.id!);
    return p;
  }

  Future<void> updateStory(String story, {String? storyMode}) async {
    final current = state.value;
    if (current?.id == null) return;
    final p = await _svc.update(current!.id!,
        story: story, storyMode: storyMode);
    state = AsyncValue.data(p);
  }

  Future<void> updateName(String name) async {
    final current = state.value;
    if (current?.id == null) return;
    final p = await _svc.update(current!.id!, name: name);
    state = AsyncValue.data(p);
  }

  Future<void> updateConfig(ProjectConfig config) async {
    final current = state.value;
    if (current?.id == null) return;
    final p = await _svc.update(current!.id!, config: config);
    state = AsyncValue.data(p);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current?.id == null) return;
    await load(current!.id!);
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final currentProjectProvider =
    NotifierProvider<CurrentProjectNotifier, AsyncValue<Project?>>(CurrentProjectNotifier.new);

final projectListProvider = FutureProvider<List<Project>>((ref) async {
  return ProjectService().list();
});
