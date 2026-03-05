import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/const/actions.dart' show AppActions;
import 'package:anime_ui/pub/providers/permission_provider.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/generation_center/center_task_section.dart';
import 'package:anime_ui/pub/widgets/generation_center/filter_toolbar.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/providers/center_ui.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';
import 'package:anime_ui/module/script/page/widgets/episode_task_card.dart';

/// 生成任务区域：筛选栏 + 批量操作 + 任务卡片网格
class CenterTaskSection extends ConsumerWidget {
  const CenterTaskSection({super.key});

  Future<void> _batchGenerate(BuildContext context, WidgetRef ref) async {
    final selected = ref.read(scriptCenterUiProvider).selectedEpisodeIds;
    if (selected.isEmpty) return;
    final ids = selected.toList();
    showToast(context, '开始生成 ${ids.length} 集脚本');
    await ref.read(episodeStatesProvider.notifier).batchGenerate(ids.map((e) => e.toString()).toList());
    if (!context.mounted) return;
    showToast(context, '批量生成完成');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(episodesProvider).value ?? [];
    final states = ref.watch(episodeStatesProvider);
    final uiState = ref.watch(scriptCenterUiProvider);
    final uiNotifier = ref.read(scriptCenterUiProvider.notifier);

    final validEpisodes = episodes.where((e) => e.id != null).toList();

    final statusCounts = <EpisodeScriptStatus?, int>{
      null: validEpisodes.length,
    };
    for (final ep in validEpisodes) {
      final st = states[ep.id]?.status ?? EpisodeScriptStatus.notStarted;
      statusCounts[st] = (statusCounts[st] ?? 0) + 1;
    }

    var filtered = validEpisodes.toList();
    if (uiState.statusFilter != null) {
      filtered = filtered.where((ep) {
        final st = states[ep.id]?.status ?? EpisodeScriptStatus.notStarted;
        return st == uiState.statusFilter;
      }).toList();
    }

    final totalPages = (validEpisodes.length / 10).ceil();
    if (uiState.pageGroup > 0 && totalPages > 0) {
      final start = (uiState.pageGroup - 1) * 10;
      final end = uiState.pageGroup * 10;
      filtered = filtered
          .where((ep) => ep.sortIndex >= start && ep.sortIndex < end)
          .toList();
    }

    final generatingCount = states.values.where((s) => s.isGenerating).length;
    final activeFilterKey = uiState.statusFilter == null
        ? 'all'
        : uiState.statusFilter!.name;

    final groups = <GroupChipData>[
      const GroupChipData(key: '0', label: '全部'),
      for (int i = 1; i <= totalPages; i++)
        GroupChipData(key: '$i', label: '${(i - 1) * 10 + 1}-${i * 10}'),
    ];

    final completedCount =
        statusCounts[EpisodeScriptStatus.completed] ?? 0;
    final generatingCountForBar =
        statusCounts[EpisodeScriptStatus.generating] ?? 0;
    final failedCount =
        statusCounts[EpisodeScriptStatus.failed] ?? 0;
    final total = validEpisodes.length;
    final pct = total > 0 ? (completedCount * 100 ~/ total) : 0;

    return TaskSectionLayout(
      count: validEpisodes.length,
      countLabel: '集',
      progressBar: total > 0
          ? _buildProgressBar(
              total, completedCount, generatingCountForBar, failedCount, pct)
          : null,
      filters: [
        FilterChipData(key: 'all', label: '全部', count: statusCounts[null] ?? 0),
        FilterChipData(
          key: 'notStarted',
          label: '待生成',
          count: statusCounts[EpisodeScriptStatus.notStarted] ?? 0,
          color: AppColors.muted,
        ),
        FilterChipData(
          key: 'generating',
          label: '生成中',
          count: statusCounts[EpisodeScriptStatus.generating] ?? 0,
          color: AppColors.primary,
        ),
        FilterChipData(
          key: 'completed',
          label: '已完成',
          count: statusCounts[EpisodeScriptStatus.completed] ?? 0,
          color: AppColors.success,
        ),
        FilterChipData(
          key: 'failed',
          label: '失败',
          count: statusCounts[EpisodeScriptStatus.failed] ?? 0,
          color: AppColors.error,
        ),
      ],
      activeFilter: activeFilterKey,
      onFilterChanged: (f) {
        if (f == activeFilterKey) {
          uiNotifier.setStatusFilter(null);
        } else {
          uiNotifier.setStatusFilter(
            f == 'all' ? null : EpisodeScriptStatus.values.byName(f),
          );
        }
      },
      groups: totalPages > 1 ? groups : const [],
      activeGroup: uiState.pageGroup.toString(),
      onGroupChanged: totalPages > 1
          ? (k) {
              final g = int.tryParse(k) ?? 0;
              uiNotifier.setPageGroup(uiState.pageGroup == g ? 0 : g);
            }
          : null,
      headerTrailing: validEpisodes.isNotEmpty
          ? BatchActionBar(
              totalCount: validEpisodes.length,
              selectedCount: uiState.selectedEpisodeIds.length,
              allSelected:
                  uiState.selectedEpisodeIds.length == validEpisodes.length &&
                  uiState.selectedEpisodeIds.isNotEmpty,
              onToggleSelectAll: () => uiNotifier.toggleSelectAll(
                validEpisodes
                    .where((e) => e.id != null)
                    .map((e) => e.id!)
                    .toList(),
              ),
              onBatchAction: () => _batchGenerate(context, ref),
              batchEnabled: generatingCount == 0 &&
                  (ref.watch(projectPermissionsProvider).value?.can(AppActions.aiGenerate) ?? true),
            )
          : null,
      child: filtered.isEmpty && validEpisodes.isEmpty
          ? _buildEmptyState()
          : filtered.isEmpty
          ? _buildNoMatchState(uiNotifier)
          : _buildTaskGrid(context, ref, uiState, uiNotifier, filtered, states),
    );
  }

  /// 纤细分段进度条 + 百分比
  Widget _buildProgressBar(
    int total,
    int completed,
    int generating,
    int failed,
    int pct,
  ) {
    final pending = (total - completed - generating - failed).clamp(0, total);
    double frac(int v) => total > 0 ? v / total : 0;

    Widget segment(double fraction, Color color) {
      if (fraction <= 0) return const SizedBox.shrink();
      return Flexible(
        flex: (fraction * 1000).round().clamp(1, 1000),
        child: Container(color: color),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.cardPadding.w,
        vertical: Spacing.sm.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              child: SizedBox(
                height: 4.h,
                child: Row(
                  children: [
                    segment(frac(completed), AppColors.success),
                    segment(frac(generating), AppColors.primary),
                    segment(frac(failed), AppColors.error),
                    segment(frac(pending), AppColors.surfaceContainer),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Text(
            '$pct%',
            style: AppTextStyles.tiny.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface.withValues(alpha: 0.6),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskGrid(
    BuildContext context,
    WidgetRef ref,
    ScriptCenterUiState uiState,
    ScriptCenterUiNotifier uiNotifier,
    List<dynamic> filtered,
    Map<String, EpisodeGenerateState> states,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cardMinWidth = 260.0;
        final crossAxisCount = (constraints.maxWidth / cardMinWidth)
            .floor()
            .clamp(2, 5);
        return Wrap(
          spacing: Spacing.gridGap,
          runSpacing: Spacing.gridGap,
          children: filtered.map((ep) {
            final eid = ep.id!;
            final epState = states[eid];
            final cardWidth =
                (constraints.maxWidth -
                    (crossAxisCount - 1) * Spacing.gridGap) /
                crossAxisCount;
            return SizedBox(
              width: cardWidth,
              child: EpisodeTaskCard(
                episodeId: eid,
                title: ep.title.isNotEmpty ? ep.title : '第${ep.sortIndex + 1}集',
                sortIndex: ep.sortIndex,
                state: epState,
                isSelected: uiState.selectedEpisodeIds.contains(eid),
                onSelectChanged: (v) =>
                    uiNotifier.toggleEpisodeSelection(eid, v),
                onGenerate: () => ref
                    .read(episodeStatesProvider.notifier)
                    .generateSingle(eid),
                onReview: () => context.go(Routes.scriptReview),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.info,
              size: 28.r,
              color: AppColors.mutedDarker,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            '暂无集数',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '请先在「剧本」模块创建集数',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedDarker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchState(ScriptCenterUiNotifier uiNotifier) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Icon(AppIcons.search, size: 28.r, color: AppColors.mutedDarker),
            const SizedBox(height: Spacing.md),
            Text(
              '无匹配任务',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDark,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            TextButton(
              onPressed: () => uiNotifier.clearFilters(),
              child: Text(
                '清除筛选',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
