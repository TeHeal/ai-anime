import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'episode_card.dart';

/// 集分组：可折叠的集卡片网格
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
          delegate: SliverChildBuilderDelegate(
            (context, groupIndex) {
              final group = groups[groupIndex];
              final firstEp = group.first;
              final lastEp = group.last;
              final isExpanded = _expandedGroups.contains(groupIndex);
              final rangeLabel =
                  '第 ${firstEp.sortIndex + 1}-${lastEp.sortIndex + 1} 集';

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                child: Column(
                  children: [
                    _buildGroupHeader(
                        rangeLabel, group.length, isExpanded, groupIndex),
                    if (isExpanded) _buildGroupGrid(group),
                  ],
                ),
              );
            },
            childCount: groups.length,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 6),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: widget.titleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Icon(widget.titleIcon, size: 16, color: widget.titleColor),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: widget.titleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${widget.episodes.length}',
                style: TextStyle(
                  color: widget.titleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(
      String label, int count, bool isExpanded, int groupIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedGroups.remove(groupIndex);
          } else {
            _expandedGroups.add(groupIndex);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isExpanded
              ? widget.titleColor.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isExpanded
                ? widget.titleColor.withValues(alpha: 0.15)
                : Colors.grey[800]!.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($count 集)',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child:
                  Icon(AppIcons.expandMore, size: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupGrid(List<DashboardEpisode> group) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
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
              mainAxisSpacing: widget.compact ? 10 : 14,
              crossAxisSpacing: widget.compact ? 10 : 14,
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
                    offset: Offset(0, 10 * (1 - value)),
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
