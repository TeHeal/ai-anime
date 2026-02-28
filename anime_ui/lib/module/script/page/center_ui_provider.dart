import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/storyboard_script.dart';

// ---------------------------------------------------------------------------
// 脚本生成中心 UI 状态
// ---------------------------------------------------------------------------

class ScriptCenterUiState {
  final Set<String> selectedEpisodeIds;
  final bool configExpanded;
  final EpisodeScriptStatus? statusFilter;
  final int pageGroup;

  const ScriptCenterUiState({
    this.selectedEpisodeIds = const {},
    this.configExpanded = true,
    this.statusFilter,
    this.pageGroup = 0,
  });

  ScriptCenterUiState copyWith({
    Set<String>? selectedEpisodeIds,
    bool? configExpanded,
    EpisodeScriptStatus? Function()? statusFilter,
    int? pageGroup,
  }) {
    return ScriptCenterUiState(
      selectedEpisodeIds: selectedEpisodeIds ?? this.selectedEpisodeIds,
      configExpanded: configExpanded ?? this.configExpanded,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      pageGroup: pageGroup ?? this.pageGroup,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ScriptCenterUiNotifier extends Notifier<ScriptCenterUiState> {
  @override
  ScriptCenterUiState build() => const ScriptCenterUiState();

  void toggleEpisodeSelection(String episodeId, bool isSelected) {
    final updated = Set<String>.from(state.selectedEpisodeIds);
    if (isSelected) {
      updated.add(episodeId);
    } else {
      updated.remove(episodeId);
    }
    state = state.copyWith(selectedEpisodeIds: updated);
  }

  void toggleSelectAll(List<String> allValidIds) {
    if (state.selectedEpisodeIds.length == allValidIds.length &&
        state.selectedEpisodeIds.isNotEmpty) {
      state = state.copyWith(selectedEpisodeIds: const {});
    } else {
      state = state.copyWith(selectedEpisodeIds: Set.from(allValidIds));
    }
  }

  void clearSelection() {
    state = state.copyWith(selectedEpisodeIds: const {});
  }

  void toggleConfigExpanded() {
    state = state.copyWith(configExpanded: !state.configExpanded);
  }

  void setStatusFilter(EpisodeScriptStatus? filter) {
    state = state.copyWith(statusFilter: () => filter);
  }

  void setPageGroup(int group) {
    state = state.copyWith(pageGroup: group);
  }

  void clearFilters() {
    state = state.copyWith(statusFilter: () => null, pageGroup: 0);
  }
}

final scriptCenterUiProvider =
    NotifierProvider<ScriptCenterUiNotifier, ScriptCenterUiState>(
        ScriptCenterUiNotifier.new);
