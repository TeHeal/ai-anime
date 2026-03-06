import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/providers/review_ui.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';

// ---------------------------------------------------------------------------
// 左栏：导航 (240px)
// ---------------------------------------------------------------------------

class ReviewLeftNav extends ConsumerWidget {
  final List<Episode> episodes;
  final List<ShotV4> allShots;

  const ReviewLeftNav({
    super.key,
    required this.episodes,
    required this.allShots,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(reviewUiProvider);
    final uiNotifier = ref.read(reviewUiProvider.notifier);
    final shotsMap = ref.watch(episodeShotsMapProvider);

    final approvedCount = allShots
        .where((s) => s.reviewStatus == 'approved')
        .length;
    final filtered = reviewFilteredShots(uiState, shotsMap);

    return Container(
      color: AppColors.rightPanelBackground,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Spacing.md.r),
            child: DropdownButtonFormField<String>(
              value: uiState.selectedEpisodeId,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.sm.h,
                ),
                border: const OutlineInputBorder(),
              ),
              dropdownColor: AppColors.surfaceMutedDarker,
              items: episodes
                  .where((e) => e.id != null)
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e.id,
                      child: Text(
                        e.title.isNotEmpty ? e.title : '第${e.sortIndex + 1}集',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => uiNotifier.selectEpisode(v),
            ),
          ),

          if (allShots.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Row(
                children: [
                  Text(
                    '$approvedCount/${allShots.length} 已确认',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.mutedDark,
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                    child: SizedBox(
                      width: 60.w,
                      height: 4.h,
                      child: LinearProgressIndicator(
                        value: allShots.isEmpty
                            ? 0
                            : approvedCount / allShots.length,
                        backgroundColor: AppColors.surfaceContainer,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: Spacing.sm.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            child: Row(
              children: [
                _filterChip(uiState.filterStatus, '全部', 'all', uiNotifier),
                SizedBox(width: Spacing.xs.w),
                _filterChip(uiState.filterStatus, '待审', 'pending', uiNotifier),
                SizedBox(width: Spacing.xs.w),
                _filterChip(uiState.filterStatus, '通过', 'approved', uiNotifier),
                SizedBox(width: Spacing.xs.w),
                _filterChip(
                  uiState.filterStatus,
                  '修改',
                  'needsRevision',
                  uiNotifier,
                ),
              ],
            ),
          ),
          SizedBox(height: Spacing.sm.h),

          const Divider(height: 1, color: AppColors.divider),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final shot = filtered[i];
                final isSel =
                    shot.shotNumber ==
                    (uiState.selectedShotNumber ??
                        allShots.firstOrNull?.shotNumber);
                return _ShotListTile(
                  shot: shot,
                  isSelected: isSel,
                  onTap: () => uiNotifier.selectShot(shot.shotNumber),
                  onInsertAfter: () {
                    final episodeId = uiState.selectedEpisodeId;
                    if (episodeId == null) return;
                    ref
                        .read(episodeShotsMapProvider.notifier)
                        .insertShot(episodeId, shot.shotNumber);
                    uiNotifier.selectShot(shot.shotNumber + 1);
                    showToast(context, '已在 #${shot.shotNumber} 后插入新镜头');
                  },
                );
              },
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          Padding(
            padding: EdgeInsets.all(Spacing.sm.r),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: uiState.selectedEpisodeId == null
                    ? null
                    : () {
                        final episodeId = uiState.selectedEpisodeId!;
                        ref
                            .read(episodeShotsMapProvider.notifier)
                            .addShot(episodeId);
                        final shots = reviewCurrentShots(
                          ref.read(reviewUiProvider),
                          ref.read(episodeShotsMapProvider),
                        );
                        uiNotifier.selectShot(
                          shots.isEmpty ? 1 : shots.last.shotNumber + 1,
                        );
                        showToast(context, '已添加新镜头');
                      },
                icon: Icon(AppIcons.add, size: 14.r),
                label: const Text('新建镜头'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                  textStyle: AppTextStyles.labelMedium,
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              Spacing.sm.w,
              0,
              Spacing.sm.w,
              Spacing.sm.h,
            ),
            child: Row(
              children: [
                _legendDot(AppColors.success, '已确认'),
                SizedBox(width: Spacing.sm.w),
                _legendDot(AppColors.warning, '需修改'),
                SizedBox(width: Spacing.sm.w),
                _legendDot(AppColors.muted, '待审核'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 私有辅助组件
// ---------------------------------------------------------------------------

Widget _filterChip(
  String currentFilter,
  String label,
  String value,
  ReviewUiNotifier notifier,
) {
  final active = currentFilter == value;
  return Expanded(
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => notifier.setFilterStatus(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.surfaceContainer,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.tiny.copyWith(
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? AppColors.primary : AppColors.mutedDark,
              ),
            ),
        ),
      ),
      ),
    ),
  );
}

Widget _legendDot(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6.w,
        height: 6.h,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      SizedBox(width: Spacing.tinyGap.w),
      Text(
        label,
        style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// 镜头列表项（支持右键菜单插入）
// ---------------------------------------------------------------------------

class _ShotListTile extends StatelessWidget {
  final ShotV4 shot;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onInsertAfter;

  const _ShotListTile({
    required this.shot,
    required this.isSelected,
    required this.onTap,
    required this.onInsertAfter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            overlay.size.width - details.globalPosition.dx,
            overlay.size.height - details.globalPosition.dy,
          ),
          items: [
            PopupMenuItem(
              onTap: onInsertAfter,
              child: Row(
                children: [
                  Icon(AppIcons.add, size: 14.r),
                  SizedBox(width: Spacing.sm.w),
                  Text('在此之后插入', style: AppTextStyles.labelMedium),
                ],
              ),
            ),
          ],
        );
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          child: Row(
            children: [
              _reviewDot(shot.reviewStatus),
              SizedBox(width: Spacing.sm.w),
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                ),
                child: Center(
                  child: Text(
                    '#${shot.shotNumber}',
                    style: AppTextStyles.tiny.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.onPrimary : AppColors.muted,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: Text(
                  shot.cameraScale.isNotEmpty ? shot.cameraScale : '—',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.muted,
                  ),
                ),
              ),
              Text(
                shot.priority.isNotEmpty ? shot.priority : '—',
                style: AppTextStyles.tiny.copyWith(
                  color: shot.priority.contains('P0')
                      ? AppColors.error
                      : shot.priority.contains('P1')
                      ? AppColors.warning
                      : AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewDot(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = AppColors.success;
      case 'needsRevision':
        color = AppColors.warning;
      default:
        color = AppColors.muted;
    }
    return Container(
      width: 8.w,
      height: 8.h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
