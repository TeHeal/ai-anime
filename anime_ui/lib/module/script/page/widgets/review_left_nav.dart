import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/page/review_ui_provider.dart';
import 'package:anime_ui/module/script/page/script_provider.dart';

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

    final approvedCount =
        allShots.where((s) => s.reviewStatus == 'approved').length;
    final filtered = reviewFilteredShots(uiState, shotsMap);

    return Container(
      color: const Color(0xFF15152A),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              initialValue: uiState.selectedEpisodeId,
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
                        value: e.id,
                        child: Text(
                          e.title.isNotEmpty
                              ? e.title
                              : '第${e.sortIndex + 1}集',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => uiNotifier.selectEpisode(v),
            ),
          ),

          if (allShots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('$approvedCount/${allShots.length} 已确认',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      width: 60,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: allShots.isEmpty
                            ? 0
                            : approvedCount / allShots.length,
                        backgroundColor: Colors.grey[800],
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _filterChip(
                    uiState.filterStatus, '全部', 'all', uiNotifier),
                const SizedBox(width: 4),
                _filterChip(
                    uiState.filterStatus, '待审', 'pending', uiNotifier),
                const SizedBox(width: 4),
                _filterChip(
                    uiState.filterStatus, '通过', 'approved', uiNotifier),
                const SizedBox(width: 4),
                _filterChip(uiState.filterStatus, '修改', 'needsRevision',
                    uiNotifier),
              ],
            ),
          ),
          const SizedBox(height: 8),

          const Divider(height: 1, color: Color(0xFF2A2A3C)),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final shot = filtered[i];
                final isSel = shot.shotNumber ==
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
                    _toast(context, '已在 #${shot.shotNumber} 后插入新镜头');
                  },
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFF2A2A3C)),

          Padding(
            padding: const EdgeInsets.all(8),
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
                            shots.isEmpty ? 1 : shots.last.shotNumber + 1);
                        _toast(context, '已添加新镜头');
                      },
                icon: const Icon(AppIcons.add, size: 14),
                label: const Text('新建镜头'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                _legendDot(Colors.green, '已确认'),
                const SizedBox(width: 8),
                _legendDot(Colors.orange, '需修改'),
                const SizedBox(width: 8),
                _legendDot(Colors.grey, '待审核'),
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

void _toast(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: isError ? Colors.red[700] : Colors.green[700],
    behavior: SnackBarBehavior.floating,
  ));
}

Widget _filterChip(String currentFilter, String label, String value,
    ReviewUiNotifier notifier) {
  final active = currentFilter == value;
  return Expanded(
    child: GestureDetector(
      onTap: () => notifier.setFilterStatus(value),
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? AppColors.primary : Colors.grey[500],
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
              child: const Row(
                children: [
                  Icon(AppIcons.add, size: 14),
                  SizedBox(width: 8),
                  Text('在此之后插入', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        );
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  color:
                      isSelected ? AppColors.primary : Colors.grey[800],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                    child: Text(
                  '#${shot.shotNumber}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : Colors.grey[400],
                  ),
                )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  shot.cameraScale.isNotEmpty ? shot.cameraScale : '—',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isSelected ? Colors.white : Colors.grey[400],
                  ),
                ),
              ),
              Text(
                shot.priority.isNotEmpty ? shot.priority : '—',
                style: TextStyle(
                  fontSize: 10,
                  color: shot.priority.contains('P0')
                      ? Colors.red[300]
                      : shot.priority.contains('P1')
                          ? Colors.orange[300]
                          : Colors.grey[500],
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
        color = Colors.green;
      case 'needsRevision':
        color = Colors.orange;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
