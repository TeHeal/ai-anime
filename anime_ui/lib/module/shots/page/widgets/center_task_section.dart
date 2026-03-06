import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/providers/shots_provider.dart' show shotsProvider;
import 'package:anime_ui/module/shots/providers/center_ui.dart';
import 'package:anime_ui/module/shots/page/provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/generation_center/center_task_section.dart';
import 'package:anime_ui/pub/widgets/generation_center/filter_toolbar.dart';
import 'composite_task_card.dart';

/// 生成任务区域：筛选栏 + 批量操作 + 任务卡片网格
class CenterTaskSection extends ConsumerWidget {
  const CenterTaskSection({super.key});

  Future<void> _batchGenerate(
    BuildContext context,
    WidgetRef ref,
    Set<String> selected,
  ) async {
    if (selected.isEmpty) return;
    showToast(context, '开始复合生成 ${selected.length} 个镜头');
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

    return TaskSectionLayout(
      count: validShots.length,
      countLabel: '镜头',
      filters: [
        FilterChipData(key: 'all', label: '全部', count: validShots.length),
        const FilterChipData(
          key: 'notStarted',
          label: '待生成',
          color: AppColors.onSurface,
        ),
        const FilterChipData(
          key: 'generating',
          label: '生成中',
          color: AppColors.primary,
        ),
        const FilterChipData(
          key: 'partialComplete',
          label: '部分完成',
          color: AppColors.info,
        ),
        const FilterChipData(
          key: 'completed',
          label: '已完成',
          color: AppColors.success,
        ),
        const FilterChipData(
          key: 'failed',
          label: '失败',
          color: AppColors.error,
        ),
      ],
      activeFilter: uiState.statusFilter,
      onFilterChanged: (f) => uiNotifier.setStatusFilter(f),
      headerTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _viewModeChip(uiNotifier, uiState, '紧凑', 'compact'),
          SizedBox(width: Spacing.xs.w),
          _viewModeChip(uiNotifier, uiState, '标准', 'standard'),
          SizedBox(width: Spacing.xs.w),
          _viewModeChip(uiNotifier, uiState, '详细', 'detailed'),
          SizedBox(width: Spacing.md.w),
          if (validShots.isNotEmpty)
            BatchActionBar(
              totalCount: validShots.length,
              selectedCount: uiState.selectedShots.length,
              allSelected:
                  uiState.selectedShots.length == validShots.length &&
                  uiState.selectedShots.isNotEmpty,
              onToggleSelectAll: () => uiNotifier.toggleSelectAll(
                validShots
                    .where((s) => s.id != null && s.id!.isNotEmpty)
                    .map((s) => s.id!)
                    .toList(),
              ),
              onBatchAction: () =>
                  _batchGenerate(context, ref, uiState.selectedShots),
            ),
        ],
      ),
      child: validShots.isEmpty
          ? _emptyState()
          : _buildTaskGrid(
              ref,
              validShots,
              compositeStates,
              uiState,
              uiNotifier,
              config,
            ),
    );
  }

  Widget _viewModeChip(
    ShotsCenterUiNotifier uiNotifier,
    ShotsCenterUiState uiState,
    String label,
    String mode,
  ) {
    final active = uiState.viewMode == mode;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => uiNotifier.setViewMode(mode),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          ),
          child: Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              color: active
                  ? AppColors.primary
                  : AppColors.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskGrid(
    WidgetRef ref,
    List<dynamic> shots,
    Map<String, CompositeShotState> compositeStates,
    ShotsCenterUiState uiState,
    ShotsCenterUiNotifier uiNotifier,
    CompositeConfig config,
  ) {
    var filtered = shots;
    if (uiState.statusFilter != 'all') {
      filtered = shots.where((shot) {
        final sid = shot.id;
        if (sid == null || sid.isEmpty) return false;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardMinWidth = uiState.viewMode == 'compact' ? 180.0.w : 280.0.w;
        final crossAxisCount = (constraints.maxWidth / cardMinWidth)
            .floor()
            .clamp(2, 5);
        final cardWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * Spacing.gridGap.w) /
            crossAxisCount;

        return Wrap(
          spacing: Spacing.gridGap.w,
          runSpacing: Spacing.gridGap.h,
          children: filtered.map((shot) {
            final sid = shot.id!;
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
                onSelectChanged: (v) => uiNotifier.toggleShotSelection(sid, v),
                onGenerate: () => ref
                    .read(compositeShotStatesProvider.notifier)
                    .batchGenerate([sid]),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.emptyStatePadding.h),
      child: Column(
        children: [
          Icon(
            AppIcons.info,
            size: 28.r,
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
          SizedBox(height: Spacing.lg.h),
          Text(
            '暂无镜头',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            '请先完成「镜图」阶段的生成与审核',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
