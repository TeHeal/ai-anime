import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/script/page/provider.dart' show shotsProvider;
import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/pub/widgets/review_layout/review_scaffold.dart';
import 'package:anime_ui/pub/widgets/review_layout/shot_list_nav.dart';
import 'review_ui_provider.dart';
import 'widgets/review_center_panel.dart';
import 'widgets/review_right_panel.dart';

/// 镜图 · 审核编辑页
class ShotImageReviewPage extends ConsumerStatefulWidget {
  const ShotImageReviewPage({super.key});

  @override
  ConsumerState<ShotImageReviewPage> createState() =>
      _ShotImageReviewPageState();
}

class _ShotImageReviewPageState extends ConsumerState<ShotImageReviewPage> {
  bool _loaded = false;
  final _focusNode = FocusNode();

  void _loadIfReady() {
    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid != null && !_loaded) {
      _loaded = true;
      ref.read(episodesProvider.notifier).load();
      ref.read(shotsProvider.notifier).load();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfReady());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<StoryboardShot> _allShots() => ref.watch(shotsProvider).value ?? [];

  StoryboardShot? _currentShot(int? selectedShotId) {
    final shots = _allShots();
    if (selectedShotId == null && shots.isNotEmpty) return shots.first;
    return shots.where((s) => s.id == selectedShotId).firstOrNull;
  }

  void _navigateShot(int delta, int? currentShotId) {
    final shots = _allShots();
    if (shots.isEmpty) return;
    final idx = shots.indexWhere((s) => s.id == currentShotId);
    final newIdx = (idx + delta).clamp(0, shots.length - 1);
    ref
        .read(shotImageReviewUiProvider.notifier)
        .setSelectedShotId(shots[newIdx].id);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final uiState = ref.read(shotImageReviewUiProvider);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowLeft) {
      _navigateShot(-1, uiState.selectedShotId);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _navigateShot(1, uiState.selectedShotId);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyA) {
      _toast('已确认通过');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyR) {
      _toast('已退回');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyE) {
      ref.read(shotImageReviewUiProvider.notifier).toggleEditMode();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentProjectProvider, (_, next) {
      if (next.value?.id != null && !_loaded) {
        _loadIfReady();
      }
    });

    final episodes = ref.watch(episodesProvider).value ?? [];
    final allShots = _allShots();

    final uiState = ref.watch(shotImageReviewUiProvider);
    final uiNotifier = ref.read(shotImageReviewUiProvider.notifier);

    if (uiState.selectedEpisodeId == null && episodes.isNotEmpty) {
      final first = episodes.where((e) => e.id != null).firstOrNull;
      if (first != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          uiNotifier.setSelectedEpisodeId(first.id);
        });
      }
    }

    final selected = _currentShot(uiState.selectedShotId);
    final currentShotId = uiState.selectedShotId ?? allShots.firstOrNull?.id;

    final approvedCount = allShots
        .where((s) => s.reviewStatus == 'approved')
        .length;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: ReviewScaffold(
        leftWidth: 260,
        rightWidth: 280,
        leftNav: ShotListNav(
          episodes: episodes,
          selectedEpisodeId: uiState.selectedEpisodeId,
          onEpisodeChanged: (v) => uiNotifier.setSelectedEpisodeId(v),
          approvedCount: approvedCount,
          totalCount: allShots.length,
          filterOptions: const ['全部', '待审', '通过', '修改', '退回'],
          activeFilter: uiState.filterStatus,
          onFilterChanged: (f) => uiNotifier.setFilterStatus(f),
          shots: allShots
              .map(
                (s) => ShotNavItem(
                  id: s.id ?? 0,
                  shotNumber: s.sortIndex + 1,
                  label: s.cameraType ?? '',
                  thumbnailUrl: s.imageUrl,
                  reviewStatus: s.reviewStatus,
                  subtitle: s.prompt.isNotEmpty
                      ? (s.prompt.length > 15
                            ? '${s.prompt.substring(0, 15)}…'
                            : s.prompt)
                      : null,
                ),
              )
              .toList(),
          selectedShotId: currentShotId,
          onShotTap: (id) => uiNotifier.setSelectedShotId(id),
        ),
        center: selected != null
            ? ReviewCenterPanel(shot: selected, allShots: allShots)
            : Center(
                child: Text(
                  '从左侧选择镜头开始审核',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
        rightPanel: ReviewRightPanel(shot: selected),
      ),
    );
  }
}
