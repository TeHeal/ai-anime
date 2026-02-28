import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 镜头审核编辑 UI 状态
class ShotsReviewUiState {
  final int? selectedEpisodeId;
  final int? selectedShotId;
  final String filterStatus;
  final String playbackMode;

  const ShotsReviewUiState({
    this.selectedEpisodeId,
    this.selectedShotId,
    this.filterStatus = '全部',
    this.playbackMode = 'composite',
  });

  ShotsReviewUiState copyWith({
    int? selectedEpisodeId,
    int? selectedShotId,
    String? filterStatus,
    String? playbackMode,
    bool clearSelectedShot = false,
  }) {
    return ShotsReviewUiState(
      selectedEpisodeId: selectedEpisodeId ?? this.selectedEpisodeId,
      selectedShotId: clearSelectedShot
          ? null
          : (selectedShotId ?? this.selectedShotId),
      filterStatus: filterStatus ?? this.filterStatus,
      playbackMode: playbackMode ?? this.playbackMode,
    );
  }
}

class ShotsReviewUiNotifier extends Notifier<ShotsReviewUiState> {
  @override
  ShotsReviewUiState build() => const ShotsReviewUiState();

  void setSelectedEpisodeId(int? id) {
    state = state.copyWith(selectedEpisodeId: id, clearSelectedShot: true);
  }

  void setSelectedShotId(int? id) {
    state = state.copyWith(selectedShotId: id);
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }

  void setPlaybackMode(String mode) {
    state = state.copyWith(playbackMode: mode);
  }
}

final shotsReviewUiProvider =
    NotifierProvider<ShotsReviewUiNotifier, ShotsReviewUiState>(
        ShotsReviewUiNotifier.new);
