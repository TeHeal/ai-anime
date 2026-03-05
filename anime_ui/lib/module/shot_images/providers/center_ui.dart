import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';

/// 镜图生成中心 UI 状态
class ShotImageCenterUiState {
  final Set<String> selectedShots;
  final String statusFilter;
  final ModelCatalogItem? selectedModel;
  final bool configExpanded;

  /// 快速验证：通过的镜头 ID
  final Set<String> proofApproved;

  /// 快速验证：需调整的镜头 ID
  final Set<String> proofNeedsRevision;

  const ShotImageCenterUiState({
    this.selectedShots = const {},
    this.statusFilter = 'all',
    this.selectedModel,
    this.configExpanded = true,
    this.proofApproved = const {},
    this.proofNeedsRevision = const {},
  });

  ShotImageCenterUiState copyWith({
    Set<String>? selectedShots,
    String? statusFilter,
    ModelCatalogItem? selectedModel,
    bool? configExpanded,
    Set<String>? proofApproved,
    Set<String>? proofNeedsRevision,
  }) {
    return ShotImageCenterUiState(
      selectedShots: selectedShots ?? this.selectedShots,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedModel: selectedModel ?? this.selectedModel,
      configExpanded: configExpanded ?? this.configExpanded,
      proofApproved: proofApproved ?? this.proofApproved,
      proofNeedsRevision: proofNeedsRevision ?? this.proofNeedsRevision,
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
    // copyWith 无法将 nullable 字段重置为新值，此处手动构造完整状态
    state = ShotImageCenterUiState(
      selectedShots: state.selectedShots,
      statusFilter: state.statusFilter,
      selectedModel: model,
      configExpanded: state.configExpanded,
      proofApproved: state.proofApproved,
      proofNeedsRevision: state.proofNeedsRevision,
    );
  }

  void toggleConfigExpanded() {
    state = state.copyWith(configExpanded: !state.configExpanded);
  }

  /// 快速验证：标记为通过
  void markProofApproved(String shotId) {
    final approved = Set<String>.from(state.proofApproved)..add(shotId);
    final revision = Set<String>.from(state.proofNeedsRevision)..remove(shotId);
    state = state.copyWith(
      proofApproved: approved,
      proofNeedsRevision: revision,
    );
  }

  /// 快速验证：标记为需调整
  void markProofNeedsRevision(String shotId) {
    final revision = Set<String>.from(state.proofNeedsRevision)..add(shotId);
    final approved = Set<String>.from(state.proofApproved)..remove(shotId);
    state = state.copyWith(
      proofApproved: approved,
      proofNeedsRevision: revision,
    );
  }

  /// 快速验证：批量全部通过
  void markAllProofApproved(List<String> shotIds) {
    state = state.copyWith(
      proofApproved: Set.from(shotIds),
      proofNeedsRevision: const {},
    );
  }
}

final shotImageCenterUiProvider =
    NotifierProvider<ShotImageCenterUiNotifier, ShotImageCenterUiState>(
      ShotImageCenterUiNotifier.new,
    );
