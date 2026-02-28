import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/module/script/view/center_ui_provider.dart';
import 'package:anime_ui/module/script/view/script_provider.dart';
import 'package:anime_ui/module/script/view/widgets/episode_task_card.dart';

/// 生成任务区域：筛选栏 + 批量操作 + 任务卡片网格
class CenterTaskSection extends ConsumerWidget {
  const CenterTaskSection({super.key});

  void _toast(BuildContext context, String msg, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _batchGenerate(BuildContext context, WidgetRef ref) async {
    final selected = ref.read(scriptCenterUiProvider).selectedEpisodeIds;
    if (selected.isEmpty) return;
    final ids = selected.toList();
    _toast(context, '开始生成 ${ids.length} 集脚本');
    await ref.read(episodeStatesProvider.notifier).batchGenerate(ids);
    if (!context.mounted) return;
    _toast(context, '批量生成完成');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(episodesProvider).value ?? [];
    final states = ref.watch(episodeStatesProvider);
    final uiState = ref.watch(scriptCenterUiProvider);
    final uiNotifier = ref.read(scriptCenterUiProvider.notifier);

    final validEpisodes = episodes.where((e) => e.id != null).toList();

    // 计算各状态数量用于筛选器
    final statusCounts = <EpisodeScriptStatus?, int>{null: validEpisodes.length};
    for (final ep in validEpisodes) {
      final st = states[ep.id]?.status ?? EpisodeScriptStatus.notStarted;
      statusCounts[st] = (statusCounts[st] ?? 0) + 1;
    }

    // 应用筛选
    var filtered = validEpisodes.toList();
    if (uiState.statusFilter != null) {
      filtered = filtered.where((ep) {
        final st = states[ep.id]?.status ?? EpisodeScriptStatus.notStarted;
        return st == uiState.statusFilter;
      }).toList();
    }

    // 计算分组
    final totalPages = (validEpisodes.length / 10).ceil();
    if (uiState.pageGroup > 0 && totalPages > 0) {
      final start = (uiState.pageGroup - 1) * 10;
      final end = uiState.pageGroup * 10;
      filtered = filtered
          .where((ep) => ep.sortIndex >= start && ep.sortIndex < end)
          .toList();
    }

    final generatingCount = states.values.where((s) => s.isGenerating).length;

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${validEpisodes.length} 集',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              // 全选
              if (validEpisodes.isNotEmpty) ...[
                _buildSelectAllChip(uiState, uiNotifier, validEpisodes),
                const SizedBox(width: 12),
                _buildBatchButton(
                    context, ref, uiState, generatingCount),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // 筛选工具栏
          _buildFilterBar(uiState, uiNotifier, statusCounts, totalPages),
          const SizedBox(height: 16),

          // 任务网格/列表
          if (filtered.isEmpty && validEpisodes.isEmpty)
            _buildEmptyState()
          else if (filtered.isEmpty)
            _buildNoMatchState(uiNotifier)
          else
            _buildTaskGrid(context, ref, uiState, uiNotifier, filtered, states),
        ],
      ),
    );
  }

  Widget _buildSelectAllChip(
    ScriptCenterUiState uiState,
    ScriptCenterUiNotifier uiNotifier,
    List<dynamic> validEpisodes,
  ) {
    final allSelected = uiState.selectedEpisodeIds.length ==
            validEpisodes.where((e) => e.id != null).length &&
        uiState.selectedEpisodeIds.isNotEmpty;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => uiNotifier.toggleSelectAll(
            validEpisodes.where((e) => e.id != null).map((e) => e.id as int).toList()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: allSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.grey[800]!.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: allSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.grey[700]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                allSelected ? AppIcons.checkOutline : AppIcons.circleOutline,
                size: 14,
                color: allSelected ? AppColors.primary : Colors.grey[400],
              ),
              const SizedBox(width: 6),
              Text(
                allSelected ? '取消全选' : '全选',
                style: TextStyle(
                    fontSize: 12,
                    color: allSelected ? AppColors.primary : Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchButton(
    BuildContext context,
    WidgetRef ref,
    ScriptCenterUiState uiState,
    int generatingCount,
  ) {
    final enabled =
        uiState.selectedEpisodeIds.isNotEmpty && generatingCount == 0;
    return FilledButton.icon(
      onPressed: enabled ? () => _batchGenerate(context, ref) : null,
      icon: const Icon(AppIcons.magicStick, size: 15),
      label: Text('批量生成 (${uiState.selectedEpisodeIds.length})'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── 筛选工具栏 ──

  Widget _buildFilterBar(
    ScriptCenterUiState uiState,
    ScriptCenterUiNotifier uiNotifier,
    Map<EpisodeScriptStatus?, int> statusCounts,
    int totalPages,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(AppIcons.tune, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 10),
          // 状态筛选
          _buildFilterChip(
            label: '全部',
            count: statusCounts[null] ?? 0,
            isActive: uiState.statusFilter == null,
            onTap: () => uiNotifier.setStatusFilter(null),
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            label: '待生成',
            count: statusCounts[EpisodeScriptStatus.notStarted] ?? 0,
            isActive: uiState.statusFilter == EpisodeScriptStatus.notStarted,
            color: Colors.grey,
            onTap: () => uiNotifier.setStatusFilter(
                uiState.statusFilter == EpisodeScriptStatus.notStarted
                    ? null
                    : EpisodeScriptStatus.notStarted),
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            label: '生成中',
            count: statusCounts[EpisodeScriptStatus.generating] ?? 0,
            isActive: uiState.statusFilter == EpisodeScriptStatus.generating,
            color: AppColors.primary,
            onTap: () => uiNotifier.setStatusFilter(
                uiState.statusFilter == EpisodeScriptStatus.generating
                    ? null
                    : EpisodeScriptStatus.generating),
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            label: '已完成',
            count: statusCounts[EpisodeScriptStatus.completed] ?? 0,
            isActive: uiState.statusFilter == EpisodeScriptStatus.completed,
            color: Colors.green,
            onTap: () => uiNotifier.setStatusFilter(
                uiState.statusFilter == EpisodeScriptStatus.completed
                    ? null
                    : EpisodeScriptStatus.completed),
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            label: '失败',
            count: statusCounts[EpisodeScriptStatus.failed] ?? 0,
            isActive: uiState.statusFilter == EpisodeScriptStatus.failed,
            color: Colors.red,
            onTap: () => uiNotifier.setStatusFilter(
                uiState.statusFilter == EpisodeScriptStatus.failed
                    ? null
                    : EpisodeScriptStatus.failed),
          ),

          const Spacer(),

          // 分组选择
          if (totalPages > 1) ...[
            Text('分组:', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(width: 8),
            _buildGroupChip(
              label: '全部',
              isActive: uiState.pageGroup == 0,
              onTap: () => uiNotifier.setPageGroup(0),
            ),
            for (int i = 1; i <= totalPages; i++) ...[
              const SizedBox(width: 4),
              _buildGroupChip(
                label: '${(i - 1) * 10 + 1}-${i * 10}',
                isActive: uiState.pageGroup == i,
                onTap: () => uiNotifier.setPageGroup(
                    uiState.pageGroup == i ? 0 : i),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isActive,
    Color? color,
    required VoidCallback onTap,
  }) {
    final activeColor = color ?? AppColors.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? activeColor : Colors.grey[400],
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  )),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text('$count',
                    style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? activeColor.withValues(alpha: 0.7)
                            : Colors.grey[600])),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.primary : Colors.grey[500],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              )),
        ),
      ),
    );
  }

  // ── 任务网格 ──

  Widget _buildTaskGrid(
    BuildContext context,
    WidgetRef ref,
    ScriptCenterUiState uiState,
    ScriptCenterUiNotifier uiNotifier,
    List<dynamic> filtered,
    Map<int, EpisodeGenerateState> states,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardMinWidth = 260.0;
        final crossAxisCount =
            (constraints.maxWidth / cardMinWidth).floor().clamp(2, 5);
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: filtered.map((ep) {
            final eid = ep.id as int;
            final epState = states[eid];
            final cardWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 14) /
                    crossAxisCount;
            return SizedBox(
              width: cardWidth,
              child: EpisodeTaskCard(
                episodeId: eid,
                title: ep.title.isNotEmpty
                    ? ep.title
                    : '第${ep.sortIndex + 1}集',
                sortIndex: ep.sortIndex,
                state: epState,
                isSelected: uiState.selectedEpisodeIds.contains(eid),
                onSelectChanged: (v) =>
                    uiNotifier.toggleEpisodeSelection(eid, v),
                onGenerate: () =>
                    ref.read(episodeStatesProvider.notifier).generateSingle(eid),
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
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.info, size: 28, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text('暂无集数',
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('请先在「剧本」模块创建集数',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNoMatchState(ScriptCenterUiNotifier uiNotifier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(AppIcons.search, size: 28, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text('无匹配任务',
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => uiNotifier.clearFilters(),
              child: const Text('清除筛选',
                  style:
                      TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
