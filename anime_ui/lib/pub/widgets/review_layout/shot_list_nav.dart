import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// Abstract descriptor for a shot item in the left navigation list.
class ShotNavItem {
  final String id;
  final int shotNumber;
  final String label;
  final String? thumbnailUrl;
  final String reviewStatus;
  final String? subtitle;

  const ShotNavItem({
    required this.id,
    required this.shotNumber,
    this.label = '',
    this.thumbnailUrl,
    this.reviewStatus = 'pending',
    this.subtitle,
  });
}

/// Reusable left-column shot navigation with episode selector, progress bar,
/// filter chips, and a scrollable shot list.
class ShotListNav extends StatelessWidget {
  final List<dynamic> episodes;
  final String? selectedEpisodeId;
  final ValueChanged<String?> onEpisodeChanged;

  final int approvedCount;
  final int totalCount;

  final List<String> filterOptions;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  final List<ShotNavItem> shots;
  final String? selectedShotId;
  final ValueChanged<String> onShotTap;

  /// Optional builder to customise each list tile.
  final Widget Function(ShotNavItem shot, bool isSelected)? itemBuilder;

  const ShotListNav({
    super.key,
    required this.episodes,
    this.selectedEpisodeId,
    required this.onEpisodeChanged,
    this.approvedCount = 0,
    this.totalCount = 0,
    this.filterOptions = const ['全部', '待审', '通过', '修改'],
    this.activeFilter = '全部',
    required this.onFilterChanged,
    required this.shots,
    this.selectedShotId,
    required this.onShotTap,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rightPanelBackground,
      child: Column(
        children: [
          // Episode selector
          Padding(
            padding: EdgeInsets.all(Spacing.md.r),
            child: DropdownButtonFormField<String>(
              value: selectedEpisodeId,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Spacing.lg.w,
                  vertical: Spacing.sm.h,
                ),
                border: const OutlineInputBorder(),
              ),
              dropdownColor: AppColors.surfaceMutedDarker,
              items: episodes
                  .where((e) => e.id != null)
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e.id.toString(),
                      child: Text(
                        e.title?.isNotEmpty == true
                            ? e.title!
                            : '第${(e.sortIndex ?? 0) + 1}集',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onEpisodeChanged,
            ),
          ),

          // Progress
          if (totalCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Row(
                children: [
                  Text(
                    '$approvedCount/$totalCount 已确认',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedDark,
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      (RadiusTokens.xs - 1).r,
                    ),
                    child: SizedBox(
                      width: 60.w,
                      height: 4.h,
                      child: LinearProgressIndicator(
                        value: totalCount == 0 ? 0 : approvedCount / totalCount,
                        backgroundColor: AppColors.surfaceContainer,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: Spacing.sm.h),

          // Filter chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            child: Row(
              children: [
                for (int i = 0; i < filterOptions.length; i++) ...[
                  _filterChip(filterOptions[i]),
                  if (i < filterOptions.length - 1)
                    SizedBox(width: Spacing.xs.w),
                ],
              ],
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Divider(height: 1.h, color: AppColors.divider),

          // Shot list
          Expanded(
            child: ListView.builder(
              itemCount: shots.length,
              itemBuilder: (_, i) {
                final shot = shots[i];
                final isSel = shot.id == selectedShotId;
                if (itemBuilder != null) return itemBuilder!(shot, isSel);
                return _defaultTile(shot, isSel);
              },
            ),
          ),

          Divider(height: 1.h, color: AppColors.divider),
          _legend(),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final active = activeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(label),
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
    );
  }

  Widget _defaultTile(ShotNavItem shot, bool isSelected) {
    return InkWell(
      onTap: () => onShotTap(shot.id),
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
            SizedBox(width: Spacing.lg.w),
            Expanded(
              child: Text(
                shot.label.isNotEmpty ? shot.label : '—',
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.onPrimary : AppColors.muted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
      case 'rejected':
        color = AppColors.error;
      default:
        color = AppColors.muted;
    }
    return Container(
      width: 8.w,
      height: 8.h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _legend() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md.w,
        Spacing.sm.h,
        Spacing.md.w,
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
        SizedBox(width: (RadiusTokens.xs - 1).w),
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
        ),
      ],
    );
  }
}
