import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/main.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/dashboard_svc.dart';

final dashboardServiceProvider = Provider((_) => DashboardService());

class DashboardNotifier extends Notifier<AsyncValue<Dashboard>> {
  @override
  AsyncValue<Dashboard> build() => const AsyncValue.data(Dashboard());

  DashboardService get _svc => ref.read(dashboardServiceProvider);

  int? get _projectId {
    final fromProvider = ref.read(currentProjectProvider).value?.id;
    if (fromProvider != null) return fromProvider;
    return storageService.currentProjectId;
  }

  Future<void> load() async {
    final pid = _projectId;
    if (pid == null) return;
    state = const AsyncValue.loading();
    try {
      final data = await _svc.get(pid);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dashboardProvider =
    NotifierProvider<DashboardNotifier, AsyncValue<Dashboard>>(
  DashboardNotifier.new,
);
