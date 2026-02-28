import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/script/view/provider.dart' show shotsProvider;
import 'package:anime_ui/module/shots/view/center_ui_provider.dart';
import 'package:anime_ui/module/shots/view/provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/generation_center/filter_toolbar.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'composite_task_card.dart';

/// 生成任务区域：筛选栏 + 批量操作 + 任务卡片网格
class CenterTaskSection extends ConsumerWidget {
  const CenterTaskSection({super.key});

  void _toast(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _batchGenerate(
      BuildContext context, WidgetRef ref, Set<int> selected) async {
    if (selected.isEmpty) return;
    _toast(context, '开始复合生成 ${selected.length} 个镜头');
    await ref
        .read(compositeShotStatesProvider.notifier)
        .batchGenerate(selected.toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shots = ref.watch(shotsProvider).value ?? [];
    final compositeStates = ref.watch(compositeShotStatesProvider);
    final uiState = ref.watch(shotsCenterUiProvider);
    final uiNotifier = ref.read(shotsCenterUiProvider.notifier);
    final config = ref.watch(compositeConfigProvider);

    final validShots = shots.where((s) => s.id != null).toList();

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, uiState, uiNotifier, validShots),
          const SizedBox(height: 16),
          FilterToolbar(
            filters: [
              FilterChipData(
                  key: 'all', label: '全部', count: validShots.length),
              const FilterChipData(
                  key: 'notStarted', label: '待生成', color: Colors.grey),
              const FilterChipData(
                  key: 'generating',
                  label: '生成中',
                  color: AppColors.primary),
              const FilterChipData(
                  key: 'partialComplete',
                  label: '部分完成',
                  color: Colors.blue),
              const FilterChipData(
                  key: 'completed', label: '已完成', color: Colors.green),
              const FilterChipData(
                  key: 'failed', label: '失败', color: Colors.red),
            ],
            activeFilter: uiState.statusFilter,
            onFilterChanged: (f) => uiNotifier.setStatusFilter(f),
          ),
          const SizedBox(height: 16),
          if (validShots.isEmpty)
            _emptyState()
          else
            _buildTaskGrid(
                ref, validShots, compositeStates, uiState, uiNotifier, config),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ShotsCenterUiState uiState,
    ShotsCenterUiNotifier uiNotifier,
    List<dynamic> validShots,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.08),
            ]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(AppIcons.magicStick,
              size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        const Text('生成任务',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${validShots.length} 镜头',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
        ),
        const Spacer(),
        _viewModeChip(uiNotifier, uiState, '紧凑', 'compact'),
        const SizedBox(width: 4),
        _viewModeChip(uiNotifier, uiState, '标准', 'standard'),
        const SizedBox(width: 4),
        _viewModeChip(uiNotifier, uiState, '详细', 'detailed'),
        const SizedBox(width: 12),
        if (validShots.isNotEmpty)
          BatchActionBar(
            totalCount: validShots.length,
            selectedCount: uiState.selectedShots.length,
            allSelected: uiState.selectedShots.length == validShots.length &&
                uiState.selectedShots.isNotEmpty,
            onToggleSelectAll: () => uiNotifier.toggleSelectAll(
                validShots.where((s) => s.id != null).map((s) => s.id as int).toList()),
            onBatchAction: () =>
                _batchGenerate(context, ref, uiState.selectedShots),
          ),
      ],
    );
  }

  Widget _viewModeChip(ShotsCenterUiNotifier uiNotifier,
      ShotsCenterUiState uiState, String label, String mode) {
    final active = uiState.viewMode == mode;
    return GestureDetector(
      onTap: () => uiNotifier.setViewMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: active ? AppColors.primary : Colors.grey[500])),
      ),
    );
  }

  Widget _buildTaskGrid(
    WidgetRef ref,
    List<dynamic> shots,
    Map<int, CompositeShotState> compositeStates,
    ShotsCenterUiState uiState,
    ShotsCenterUiNotifier uiNotifier,
    CompositeConfig config,
  ) {
    // 按 statusFilter 筛选
    var filtered = shots;
    if (uiState.statusFilter != 'all') {
      filtered = shots.where((shot) {
        final sid = shot.id as int?;
        if (sid == null) return false;
        final cs = compositeStates[sid];
        final status = cs?.status ?? CompositeShotStatus.notStarted;
        final key = switch (status) {
          CompositeShotStatus.notStarted => 'notStarted',
          CompositeShotStatus.generating => 'generating',
          CompositeShotStatus.partialComplete => 'partialComplete',
          CompositeShotStatus.completed => 'completed',
          CompositeShotStatus.failed => 'failed',
        };
        return key == uiState.statusFilter;
      }).toList();
    }

    return LayoutBuilder(builder: (context, constraints) {
      final cardMinWidth = uiState.viewMode == 'compact' ? 180.0 : 280.0;
      final crossAxisCount =
          (constraints.maxWidth / cardMinWidth).floor().clamp(2, 5);
      final cardWidth =
          (constraints.maxWidth - (crossAxisCount - 1) * 14) / crossAxisCount;

      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: filtered.map((shot) {
          final sid = shot.id as int;
          final cs = compositeStates[sid];

          return SizedBox(
            width: cardWidth,
            child: CompositeTaskCard(
              shotId: sid,
              shotNumber: (shot.sortIndex ?? 0) + 1,
              cameraScale: shot.cameraType ?? '',
              prompt: shot.prompt ?? '',
              imageUrl: shot.imageUrl ?? '',
              status: cs?.status ?? CompositeShotStatus.notStarted,
              completedSubtasks: cs?.completedCount ?? 0,
              totalSubtasks: cs?.totalCount ?? config.enabledCount,
              subtasks: cs?.subtasks ?? {},
              isSelected: uiState.selectedShots.contains(sid),
              viewMode: uiState.viewMode,
              onSelectChanged: (v) =>
                  uiNotifier.toggleShotSelection(sid, v),
              onGenerate: () => ref
                  .read(compositeShotStatesProvider.notifier)
                  .batchGenerate([sid]),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(AppIcons.info, size: 28, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text('暂无镜头',
              style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          const SizedBox(height: 8),
          Text('请先完成「镜图」阶段的生成与审核',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}
