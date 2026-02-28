import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 镜图审核编辑 UI 状态
class ShotImageReviewUiState {
  final int? selectedEpisodeId;
  final int? selectedShotId;
  final String filterStatus;
  final bool editMode;

  const ShotImageReviewUiState({
    this.selectedEpisodeId,
    this.selectedShotId,
    this.filterStatus = '全部',
    this.editMode = false,
  });

  ShotImageReviewUiState copyWith({
    int? selectedEpisodeId,
    int? selectedShotId,
    String? filterStatus,
    bool? editMode,
    bool clearSelectedShot = false,
  }) {
    return ShotImageReviewUiState(
      selectedEpisodeId: selectedEpisodeId ?? this.selectedEpisodeId,
      selectedShotId: clearSelectedShot
          ? null
          : (selectedShotId ?? this.selectedShotId),
      filterStatus: filterStatus ?? this.filterStatus,
      editMode: editMode ?? this.editMode,
    );
  }
}

class ShotImageReviewUiNotifier extends Notifier<ShotImageReviewUiState> {
  @override
  ShotImageReviewUiState build() => const ShotImageReviewUiState();

  void setSelectedEpisodeId(int? id) {
    state = state.copyWith(
      selectedEpisodeId: id,
      clearSelectedShot: true,
    );
  }

  void setSelectedShotId(int? id) {
    state = state.copyWith(selectedShotId: id);
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }

  void toggleEditMode() {
    state = state.copyWith(editMode: !state.editMode);
  }

  void setEditMode(bool isEdit) {
    state = state.copyWith(editMode: isEdit);
  }
}

final shotImageReviewUiProvider =
    NotifierProvider<ShotImageReviewUiNotifier, ShotImageReviewUiState>(
  ShotImageReviewUiNotifier.new,
);
