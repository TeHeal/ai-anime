import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';

/// 镜图生成中心 UI 状态
class ShotImageCenterUiState {
  final Set<String> selectedShots;
  final String statusFilter;
  final ModelCatalogItem? selectedModel;
  final bool configExpanded;

  const ShotImageCenterUiState({
    this.selectedShots = const {},
    this.statusFilter = 'all',
    this.selectedModel,
    this.configExpanded = true,
  });

  ShotImageCenterUiState copyWith({
    Set<String>? selectedShots,
    String? statusFilter,
    ModelCatalogItem? selectedModel,
    bool? configExpanded,
  }) {
    return ShotImageCenterUiState(
      selectedShots: selectedShots ?? this.selectedShots,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedModel: selectedModel ?? this.selectedModel,
      configExpanded: configExpanded ?? this.configExpanded,
    );
  }
}

class ShotImageCenterUiNotifier extends Notifier<ShotImageCenterUiState> {
  @override
  ShotImageCenterUiState build() => const ShotImageCenterUiState();

  void toggleShotSelection(String shotId, bool isSelected) {
    final newSelected = Set<String>.from(state.selectedShots);
    if (isSelected) {
      newSelected.add(shotId);
    } else {
      newSelected.remove(shotId);
    }
    state = state.copyWith(selectedShots: newSelected);
  }

  void toggleSelectAll(List<String> allValidShotIds) {
    if (state.selectedShots.length == allValidShotIds.length) {
      state = state.copyWith(selectedShots: const {});
    } else {
      state = state.copyWith(selectedShots: Set.from(allValidShotIds));
    }
  }

  void clearSelection() {
    state = state.copyWith(selectedShots: const {});
  }

  void setStatusFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setSelectedModel(ModelCatalogItem? model) {
    state = ShotImageCenterUiState(
      selectedShots: state.selectedShots,
      statusFilter: state.statusFilter,
      selectedModel: model,
      configExpanded: state.configExpanded,
    );
  }

  void toggleConfigExpanded() {
    state = state.copyWith(configExpanded: !state.configExpanded);
  }
}

final shotImageCenterUiProvider =
    NotifierProvider<ShotImageCenterUiNotifier, ShotImageCenterUiState>(
      ShotImageCenterUiNotifier.new,
    );
