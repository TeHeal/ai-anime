import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

/// Abstract descriptor for a shot item in the left navigation list.
class ShotNavItem {
  final int id;
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
  final int? selectedEpisodeId;
  final ValueChanged<int?> onEpisodeChanged;

  final int approvedCount;
  final int totalCount;

  final List<String> filterOptions;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  final List<ShotNavItem> shots;
  final int? selectedShotId;
  final ValueChanged<int> onShotTap;

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
      color: const Color(0xFF15152A),
      child: Column(
        children: [
          // Episode selector
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              initialValue: selectedEpisodeId,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              dropdownColor: Colors.grey[900],
              items: episodes
                  .where((e) => e.id != null)
                  .map((e) => DropdownMenuItem(
                        value: e.id as int,
                        child: Text(
                          e.title?.isNotEmpty == true
                              ? e.title!
                              : '第${(e.sortIndex ?? 0) + 1}集',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ))
                  .toList(),
              onChanged: onEpisodeChanged,
            ),
          ),

          // Progress
          if (totalCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('$approvedCount/$totalCount 已确认',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      width: 60,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: totalCount == 0
                            ? 0
                            : approvedCount / totalCount,
                        backgroundColor: Colors.grey[800],
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (int i = 0; i < filterOptions.length; i++) ...[
                  _filterChip(filterOptions[i]),
                  if (i < filterOptions.length - 1) const SizedBox(width: 4),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFF2A2A3C)),

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

          const Divider(height: 1, color: Color(0xFF2A2A3C)),
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
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.grey[800]!,
            ),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? AppColors.primary : Colors.grey[500],
                )),
          ),
        ),
      ),
    );
  }

  Widget _defaultTile(ShotNavItem shot, bool isSelected) {
    return InkWell(
      onTap: () => onShotTap(shot.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        child: Row(
          children: [
            _reviewDot(shot.reviewStatus),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('#${shot.shotNumber}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[400],
                    )),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                shot.label.isNotEmpty ? shot.label : '—',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey[400],
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
        color = Colors.green;
      case 'needsRevision':
        color = Colors.orange;
      case 'rejected':
        color = Colors.red;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _legend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _legendDot(Colors.green, '已确认'),
          const SizedBox(width: 8),
          _legendDot(Colors.orange, '需修改'),
          const SizedBox(width: 8),
          _legendDot(Colors.grey, '待审核'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
