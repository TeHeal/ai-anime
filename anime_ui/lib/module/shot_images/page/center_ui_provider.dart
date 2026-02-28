import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';

/// 镜图生成中心 UI 状态
class ShotImageCenterUiState {
  final Set<int> selectedShots;
  final String statusFilter;
  final ModelCatalogItem? selectedModel;

  const ShotImageCenterUiState({
    this.selectedShots = const {},
    this.statusFilter = 'all',
    this.selectedModel,
  });

  ShotImageCenterUiState copyWith({
    Set<int>? selectedShots,
    String? statusFilter,
    ModelCatalogItem? selectedModel,
  }) {
    return ShotImageCenterUiState(
      selectedShots: selectedShots ?? this.selectedShots,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }
}

class ShotImageCenterUiNotifier extends Notifier<ShotImageCenterUiState> {
  @override
  ShotImageCenterUiState build() => const ShotImageCenterUiState();

  void toggleShotSelection(int shotId, bool isSelected) {
    final newSelected = Set<int>.from(state.selectedShots);
    if (isSelected) {
      newSelected.add(shotId);
    } else {
      newSelected.remove(shotId);
    }
    state = state.copyWith(selectedShots: newSelected);
  }

  void toggleSelectAll(List<int> allValidShotIds) {
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
    );
  }
}

final shotImageCenterUiProvider =
    NotifierProvider<ShotImageCenterUiNotifier, ShotImageCenterUiState>(
  ShotImageCenterUiNotifier.new,
);
