import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/page/script_provider.dart';

// ---------------------------------------------------------------------------
// 审核页面 UI 状态
// ---------------------------------------------------------------------------

class ReviewUiState {
  final String? selectedEpisodeId;
  final int? selectedShotNumber;
  final String filterStatus;
  final bool editModeOverride;
  final bool editModeManuallySet;
  final bool audioExpanded;
  final bool imageExpanded;
  final bool videoExpanded;

  const ReviewUiState({
    this.selectedEpisodeId,
    this.selectedShotNumber,
    this.filterStatus = 'all',
    this.editModeOverride = false,
    this.editModeManuallySet = false,
    this.audioExpanded = true,
    this.imageExpanded = false,
    this.videoExpanded = false,
  });

  ReviewUiState copyWith({
    String? Function()? selectedEpisodeId,
    int? Function()? selectedShotNumber,
    String? filterStatus,
    bool? editModeOverride,
    bool? editModeManuallySet,
    bool? audioExpanded,
    bool? imageExpanded,
    bool? videoExpanded,
  }) {
    return ReviewUiState(
      selectedEpisodeId: selectedEpisodeId != null
          ? selectedEpisodeId()
          : this.selectedEpisodeId,
      selectedShotNumber: selectedShotNumber != null
          ? selectedShotNumber()
          : this.selectedShotNumber,
      filterStatus: filterStatus ?? this.filterStatus,
      editModeOverride: editModeOverride ?? this.editModeOverride,
      editModeManuallySet: editModeManuallySet ?? this.editModeManuallySet,
      audioExpanded: audioExpanded ?? this.audioExpanded,
      imageExpanded: imageExpanded ?? this.imageExpanded,
      videoExpanded: videoExpanded ?? this.videoExpanded,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ReviewUiNotifier extends Notifier<ReviewUiState> {
  @override
  ReviewUiState build() => const ReviewUiState();

  void selectEpisode(String? id) {
    state = state.copyWith(
      selectedEpisodeId: () => id,
      selectedShotNumber: () => null,
      editModeManuallySet: false,
    );
  }

  void selectShot(int? number) {
    state = state.copyWith(
      selectedShotNumber: () => number,
      editModeManuallySet: false,
    );
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }

  void setEditMode(bool editing) {
    state = state.copyWith(
      editModeOverride: editing,
      editModeManuallySet: true,
    );
  }

  void toggleAudioExpanded() {
    state = state.copyWith(audioExpanded: !state.audioExpanded);
  }

  void toggleImageExpanded() {
    state = state.copyWith(imageExpanded: !state.imageExpanded);
  }

  void toggleVideoExpanded() {
    state = state.copyWith(videoExpanded: !state.videoExpanded);
  }

  void navigateShot(int delta) {
    final shots = _currentShots();
    if (shots.isEmpty) return;
    final idx =
        shots.indexWhere((s) => s.shotNumber == state.selectedShotNumber);
    final newIdx = (idx + delta).clamp(0, shots.length - 1);
    state = state.copyWith(
      selectedShotNumber: () => shots[newIdx].shotNumber,
      editModeManuallySet: false,
    );
  }

  void setReview(int shotNumber, String status) {
    if (state.selectedEpisodeId == null) return;
    ref
        .read(episodeShotsMapProvider.notifier)
        .setReviewStatus(state.selectedEpisodeId!, shotNumber, status);
    state = state.copyWith(editModeManuallySet: false);
  }

  void updateCurrentShot(ShotV4 Function(ShotV4) fn) {
    if (state.selectedEpisodeId == null) return;
    final shot = currentShot();
    if (shot == null) return;
    ref
        .read(episodeShotsMapProvider.notifier)
        .updateShot(state.selectedEpisodeId!, shot.shotNumber, fn);
  }

  List<ShotV4> _currentShots() {
    if (state.selectedEpisodeId == null) return [];
    return ref.read(episodeShotsMapProvider)[state.selectedEpisodeId!] ?? [];
  }

  ShotV4? currentShot() {
    final shots = _currentShots();
    if (state.selectedShotNumber == null && shots.isNotEmpty) {
      return shots.first;
    }
    return shots
        .where((s) => s.shotNumber == state.selectedShotNumber)
        .firstOrNull;
  }
}

final reviewUiProvider =
    NotifierProvider<ReviewUiNotifier, ReviewUiState>(ReviewUiNotifier.new);

// ---------------------------------------------------------------------------
// 派生数据辅助函数
// ---------------------------------------------------------------------------

List<ShotV4> reviewCurrentShots(
  ReviewUiState ui,
  Map<String, List<ShotV4>> shotsMap,
) {
  if (ui.selectedEpisodeId == null) return [];
  return shotsMap[ui.selectedEpisodeId!] ?? [];
}

List<ShotV4> reviewFilteredShots(
  ReviewUiState ui,
  Map<String, List<ShotV4>> shotsMap,
) {
  final shots = reviewCurrentShots(ui, shotsMap);
  if (ui.filterStatus == 'all') return shots;
  return shots.where((s) => s.reviewStatus == ui.filterStatus).toList();
}

ShotV4? reviewCurrentShot(
  ReviewUiState ui,
  Map<String, List<ShotV4>> shotsMap,
) {
  final shots = reviewCurrentShots(ui, shotsMap);
  if (ui.selectedShotNumber == null && shots.isNotEmpty) return shots.first;
  return shots
      .where((s) => s.shotNumber == ui.selectedShotNumber)
      .firstOrNull;
}

bool reviewIsEditMode(ReviewUiState ui, ShotV4? shot) {
  if (ui.editModeManuallySet) return ui.editModeOverride;
  if (shot == null) return false;
  return shot.reviewStatus != 'approved';
}
