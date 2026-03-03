import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/providers/shots_provider.dart' show shotsProvider;
import 'package:anime_ui/module/shot_images/providers/center_ui.dart';
import 'package:anime_ui/module/shot_images/page/provider.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/generation_center/center_task_section.dart';
import 'package:anime_ui/pub/widgets/generation_center/filter_toolbar.dart';
import 'shot_image_task_card.dart';

/// 镜图生成任务区域
class CenterTaskSection extends ConsumerWidget {
  const CenterTaskSection({super.key});

  Future<void> _batchGenerate(
    BuildContext context,
    WidgetRef ref,
    Set<String> selected,
  ) async {
    if (selected.isEmpty) return;
    showToast(context, '开始生成 ${selected.length} 个镜图');
    await ref
        .read(shotImageStatesProvider.notifier)
        .batchGenerate(selected.toList());
    if (!context.mounted) return;
    showToast(context, '批量生成已提交');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shots = ref.watch(shotsProvider).value ?? [];
    final imgStates = ref.watch(shotImageStatesProvider);
    final uiState = ref.watch(shotImageCenterUiProvider);
    final uiNotifier = ref.read(shotImageCenterUiProvider.notifier);

    if (shots.isNotEmpty && imgStates.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(shotImageStatesProvider.notifier).initFromShots(shots);
      });
    }

    final validShots = shots.where((s) => s.id != null).toList();

    final statusCounts = <String, int>{'all': validShots.length};
    for (final s in validShots) {
      final st = imgStates[s.id]?.status ?? ShotImageStatus.notStarted;
      final key = st.name;
      statusCounts[key] = (statusCounts[key] ?? 0) + 1;
    }

    var filtered = validShots.toList();
    if (uiState.statusFilter != 'all') {
      filtered = filtered.where((s) {
        final st = imgStates[s.id]?.status ?? ShotImageStatus.notStarted;
        return st.name == uiState.statusFilter;
      }).toList();
    }

    return TaskSectionLayout(
      count: validShots.length,
      countLabel: '镜头',
      filters: [
        FilterChipData(
          key: 'all',
          label: '全部',
          count: statusCounts['all'] ?? 0,
        ),
        FilterChipData(
          key: 'notStarted',
          label: '待生成',
          count: statusCounts['notStarted'] ?? 0,
          color: AppColors.muted,
        ),
        FilterChipData(
          key: 'generating',
          label: '生成中',
          count: statusCounts['generating'] ?? 0,
          color: AppColors.primary,
        ),
        FilterChipData(
          key: 'completed',
          label: '已完成',
          count: statusCounts['completed'] ?? 0,
          color: AppColors.success,
        ),
        FilterChipData(
          key: 'failed',
          label: '失败',
          count: statusCounts['failed'] ?? 0,
          color: AppColors.error,
        ),
      ],
      activeFilter: uiState.statusFilter,
      onFilterChanged: (f) => uiNotifier.setStatusFilter(f),
      headerTrailing: validShots.isNotEmpty
          ? BatchActionBar(
              totalCount: validShots.length,
              selectedCount: uiState.selectedShots.length,
              allSelected:
                  uiState.selectedShots.length == validShots.length &&
                  uiState.selectedShots.isNotEmpty,
              onToggleSelectAll: () {
                uiNotifier.toggleSelectAll(
                  validShots
                      .where((s) => s.id != null && s.id!.isNotEmpty)
                      .map((s) => s.id!)
                      .toList(),
                );
              },
              onBatchAction: () =>
                  _batchGenerate(context, ref, uiState.selectedShots),
            )
          : null,
      child: filtered.isEmpty
          ? _emptyState(validShots.isEmpty)
          : _buildTaskGrid(
              context,
              ref,
              filtered,
              imgStates,
              uiState,
              uiNotifier,
            ),
    );
  }

  Widget _buildTaskGrid(
    BuildContext context,
    WidgetRef ref,
    List<StoryboardShot> shots,
    Map<String, ShotImageState> imgStates,
    ShotImageCenterUiState uiState,
    ShotImageCenterUiNotifier uiNotifier,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardMinWidth = 240.0.w;
        final crossAxisCount = (constraints.maxWidth / cardMinWidth)
            .floor()
            .clamp(2, 5);

        return Wrap(
          spacing: Spacing.gridGap.w,
          runSpacing: Spacing.gridGap.h,
          children: shots.map((shot) {
            final sid = shot.id!;
            final imgState = imgStates[sid];
            final cardWidth =
                (constraints.maxWidth -
                    (crossAxisCount - 1) * Spacing.gridGap.w) /
                crossAxisCount;

            return SizedBox(
              width: cardWidth,
              child: ShotImageTaskCard(
                shotId: sid,
                shotNumber: shot.sortIndex + 1,
                cameraScale: shot.cameraType ?? '',
                prompt: shot.prompt,
                imageUrl: _resolveUrl(imgState?.imageUrl ?? shot.imageUrl),
                status: imgState?.status ?? ShotImageStatus.notStarted,
                progress: imgState?.progress ?? 0,
                candidateCount: imgState?.candidateCount ?? 0,
                isSelected: uiState.selectedShots.contains(sid),
                onSelectChanged: (v) => uiNotifier.toggleShotSelection(sid, v),
                onGenerate: () => ref
                    .read(shotImageStatesProvider.notifier)
                    .batchGenerate([sid]),
                onReview: () => context.go(Routes.shotImagesReview),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _resolveUrl(String url) {
    if (url.isEmpty) return url;
    return resolveFileUrl(url);
  }

  Widget _emptyState(bool noShots) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.emptyStatePadding.h),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
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
          SizedBox(height: Spacing.lg.h),
          Text(
            noShots ? '暂无镜头' : '无匹配任务',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            noShots ? '请先在「脚本」模块完成脚本生成' : '尝试清除筛选条件',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedDarker,
            ),
          ),
        ],
      ),
    );
  }
}
