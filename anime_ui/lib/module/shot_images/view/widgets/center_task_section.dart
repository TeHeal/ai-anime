import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/module/script/view/provider.dart' show shotsProvider;
import 'package:anime_ui/module/shot_images/view/center_ui_provider.dart';
import 'package:anime_ui/module/shot_images/view/provider.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/services/api.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/theme/text.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/generation_center/filter_toolbar.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'shot_image_task_card.dart';

/// 镜图生成任务区域
class CenterTaskSection extends ConsumerWidget {
  const CenterTaskSection({super.key});

  void _toast(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _batchGenerate(
    BuildContext context,
    WidgetRef ref,
    Set<int> selected,
  ) async {
    if (selected.isEmpty) return;
    _toast(context, '开始生成 ${selected.length} 个镜图');
    await ref
        .read(shotImageStatesProvider.notifier)
        .batchGenerate(selected.toList());
    if (!context.mounted) return;
    _toast(context, '批量生成已提交');
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

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                child: const Icon(
                  AppIcons.magicStick,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '生成任务',
                style: AppTextStyles.h4.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${validShots.length} 镜头',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (validShots.isNotEmpty)
                BatchActionBar(
                  totalCount: validShots.length,
                  selectedCount: uiState.selectedShots.length,
                  allSelected:
                      uiState.selectedShots.length == validShots.length &&
                          uiState.selectedShots.isNotEmpty,
                  onToggleSelectAll: () {
                    uiNotifier.toggleSelectAll(
                      validShots
                          .where((s) => s.id != null)
                          .map((s) => s.id!)
                          .toList(),
                    );
                  },
                  onBatchAction: () =>
                      _batchGenerate(context, ref, uiState.selectedShots),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilterToolbar(
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
                color: Colors.grey,
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
                color: Colors.green,
              ),
              FilterChipData(
                key: 'failed',
                label: '失败',
                count: statusCounts['failed'] ?? 0,
                color: Colors.red,
              ),
            ],
            activeFilter: uiState.statusFilter,
            onFilterChanged: (f) => uiNotifier.setStatusFilter(f),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _emptyState(validShots.isEmpty)
          else
            _buildTaskGrid(
              context,
              ref,
              filtered,
              imgStates,
              uiState,
              uiNotifier,
            ),
        ],
      ),
    );
  }

  Widget _buildTaskGrid(
    BuildContext context,
    WidgetRef ref,
    List<StoryboardShot> shots,
    Map<int, ShotImageState> imgStates,
    ShotImageCenterUiState uiState,
    ShotImageCenterUiNotifier uiNotifier,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cardMinWidth = 240.0;
        final crossAxisCount =
            (constraints.maxWidth / cardMinWidth).floor().clamp(2, 5);

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: shots.map((shot) {
            final sid = shot.id!;
            final imgState = imgStates[sid];
            final cardWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 14) /
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
                onSelectChanged: (v) =>
                    uiNotifier.toggleShotSelection(sid, v),
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
          Text(
            noShots ? '暂无镜头' : '无匹配任务',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noShots ? '请先在「脚本」模块完成脚本生成' : '尝试清除筛选条件',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
