import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'episode_card.dart';

/// 集分组：渐变区段头 + 可折叠集卡片网格
class EpisodeGroup extends StatefulWidget {
  const EpisodeGroup({
    super.key,
    required this.title,
    required this.titleColor,
    required this.titleIcon,
    required this.episodes,
    required this.onEpisodeTap,
    this.groupSize = 5,
    this.expandFirstGroup = false,
    this.defaultExpanded = false,
    this.compact = false,
  });

  final String title;
  final Color titleColor;
  final IconData titleIcon;
  final List<DashboardEpisode> episodes;
  final void Function(DashboardEpisode ep) onEpisodeTap;
  final int groupSize;
  final bool expandFirstGroup;
  final bool defaultExpanded;
  final bool compact;

  @override
  State<EpisodeGroup> createState() => _EpisodeGroupState();
}

class _EpisodeGroupState extends State<EpisodeGroup> {
  late final Set<int> _expandedGroups;

  @override
  void initState() {
    super.initState();
    final groupCount = (widget.episodes.length / widget.groupSize).ceil();
    _expandedGroups = {};
    if (widget.defaultExpanded) {
      for (int i = 0; i < groupCount; i++) {
        _expandedGroups.add(i);
      }
    } else if (widget.expandFirstGroup && groupCount > 0) {
      _expandedGroups.add(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <List<DashboardEpisode>>[];
    for (int i = 0; i < widget.episodes.length; i += widget.groupSize) {
      final end = (i + widget.groupSize).clamp(0, widget.episodes.length);
      groups.add(widget.episodes.sublist(i, end));
    }

    return SliverMainAxisGroup(
      slivers: [
        _buildSectionHeader(),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, groupIndex) {
            final group = groups[groupIndex];
            final firstEp = group.first;
            final lastEp = group.last;
            final isExpanded = _expandedGroups.contains(groupIndex);
            final rangeLabel =
                '第 ${firstEp.sortIndex + 1}-${lastEp.sortIndex + 1} 集';

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xxl.w,
                vertical: Spacing.xs.h,
              ),
              child: Column(
                children: [
                  _buildGroupHeader(
                    rangeLabel,
                    group.length,
                    isExpanded,
                    groupIndex,
                  ),
                  if (isExpanded) _buildGroupGrid(group),
                ],
              ),
            );
          }, childCount: groups.length),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        Spacing.xxl.w,
        Spacing.xl.h,
        Spacing.xxl.w,
        Spacing.sm.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: Spacing.tinyGap.w,
              height: Spacing.menuIconSize.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.titleColor,
                    widget.titleColor.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              ),
            ),
            SizedBox(width: RadiusTokens.lg.w),
            Icon(
              widget.titleIcon,
              size: Spacing.lg.r,
              color: widget.titleColor,
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              widget.title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: (RadiusTokens.md - 1).w,
                vertical: Spacing.xxs.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.titleColor.withValues(alpha: 0.15),
                    widget.titleColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              ),
              child: Text(
                '${widget.episodes.length}',
                style: AppTextStyles.tiny.copyWith(
                  color: widget.titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(
    String label,
    int count,
    bool isExpanded,
    int groupIndex,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedGroups.remove(groupIndex);
            } else {
              _expandedGroups.add(groupIndex);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.gridGap.w,
            vertical: RadiusTokens.lg.h,
          ),
          decoration: BoxDecoration(
            gradient: isExpanded
                ? LinearGradient(
                    colors: [
                      widget.titleColor.withValues(alpha: 0.08),
                      widget.titleColor.withValues(alpha: 0.02),
                    ],
                  )
                : null,
            color: isExpanded ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: isExpanded
                  ? widget.titleColor.withValues(alpha: 0.2)
                  : AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                '($count 集)',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  AppIcons.expandMore,
                  size: 16.r,
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupGrid(List<DashboardEpisode> group) {
    return Padding(
      padding: EdgeInsets.only(top: RadiusTokens.lg.r, bottom: Spacing.sm.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = widget.compact
              ? (constraints.maxWidth / 320).floor().clamp(1, 6)
              : (constraints.maxWidth / 360).floor().clamp(1, 5);
          final aspectRatio = widget.compact ? 2.8 : 1.3;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: widget.compact ? Spacing.md : Spacing.gridGap,
              crossAxisSpacing: widget.compact ? Spacing.md : Spacing.gridGap,
              childAspectRatio: aspectRatio,
            ),
            itemCount: group.length,
            itemBuilder: (_, i) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 250 + i * 40),
                curve: Curves.easeOut,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 10.h * (1 - value)),
                    child: child,
                  ),
                ),
                child: EpisodeCard(
                  episode: group[i],
                  onTap: () => widget.onEpisodeTap(group[i]),
                  compact: widget.compact,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
