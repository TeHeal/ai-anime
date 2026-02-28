import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 镜头生成中心 UI 状态
class ShotsCenterUiState {
  final Set<int> selectedShots;
  final String statusFilter;
  final String viewMode;

  const ShotsCenterUiState({
    this.selectedShots = const {},
    this.statusFilter = 'all',
    this.viewMode = 'standard',
  });

  ShotsCenterUiState copyWith({
    Set<int>? selectedShots,
    String? statusFilter,
    String? viewMode,
  }) {
    return ShotsCenterUiState(
      selectedShots: selectedShots ?? this.selectedShots,
      statusFilter: statusFilter ?? this.statusFilter,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

class ShotsCenterUiNotifier extends Notifier<ShotsCenterUiState> {
  @override
  ShotsCenterUiState build() => const ShotsCenterUiState();

  void toggleShotSelection(int shotId, bool isSelected) {
    final updated = Set<int>.from(state.selectedShots);
    if (isSelected) {
      updated.add(shotId);
    } else {
      updated.remove(shotId);
    }
    state = state.copyWith(selectedShots: updated);
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

  void setViewMode(String mode) {
    state = state.copyWith(viewMode: mode);
  }
}

final shotsCenterUiProvider =
    NotifierProvider<ShotsCenterUiNotifier, ShotsCenterUiState>(
        ShotsCenterUiNotifier.new);
