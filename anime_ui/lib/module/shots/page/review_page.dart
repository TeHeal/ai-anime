import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/script/page/provider.dart' show shotsProvider;
import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/pub/widgets/review_layout/qa_checklist.dart';
import 'package:anime_ui/pub/widgets/review_layout/review_scaffold.dart';
import 'package:anime_ui/pub/widgets/review_layout/shot_list_nav.dart';
import 'review_ui_provider.dart';
import 'widgets/review_player_bar.dart';
import 'widgets/review_right_panel.dart';
import 'widgets/review_track_card.dart';

/// 镜头 · 审核编辑页（含播放器横条 + 分轨审核）
class ShotsReviewPage extends ConsumerStatefulWidget {
  const ShotsReviewPage({super.key});

  @override
  ConsumerState<ShotsReviewPage> createState() => _ShotsReviewPageState();
}

class _ShotsReviewPageState extends ConsumerState<ShotsReviewPage> {
  bool _loaded = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        ref.read(episodesProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  List<dynamic> _allShots() => ref.watch(shotsProvider).value ?? [];

  void _navigateShot(int delta) {
    final shots = _allShots();
    if (shots.isEmpty) return;
    final currentId = ref.read(shotsReviewUiProvider).selectedShotId;
    final idx = shots.indexWhere((s) => s.id == currentId);
    final newIdx = (idx + delta).clamp(0, shots.length - 1);
    ref
        .read(shotsReviewUiProvider.notifier)
        .setSelectedShotId(shots[newIdx].id);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _navigateShot(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _navigateShot(1);
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
    if (key == LogicalKeyboardKey.space) {
      _toast('播放/暂停');
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(episodesProvider).value ?? [];
    final allShots = _allShots();
    final uiState = ref.watch(shotsReviewUiProvider);
    final uiNotifier = ref.read(shotsReviewUiProvider.notifier);

    if (uiState.selectedEpisodeId == null && episodes.isNotEmpty) {
      final first = episodes.where((e) => e.id != null).firstOrNull;
      if (first != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          uiNotifier.setSelectedEpisodeId(first.id);
        });
      }
    }

    final selected =
        allShots.where((s) => s.id == uiState.selectedShotId).firstOrNull ??
            allShots.firstOrNull;
    final approvedCount =
        allShots.where((s) => s.reviewStatus == 'approved').length;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: ReviewScaffold(
        leftWidth: 240,
        rightWidth: 280,
        topBar: ReviewPlayerBar(shot: selected),
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
              .map((s) => ShotNavItem(
                    id: s.id ?? '',
                    shotNumber: (s.sortIndex ?? 0) + 1,
                    label: s.cameraType ?? '',
                    thumbnailUrl: s.imageUrl,
                    reviewStatus: s.reviewStatus ?? 'pending',
                  ))
              .toList(),
          selectedShotId:
              uiState.selectedShotId ?? allShots.firstOrNull?.id,
          onShotTap: (id) => uiNotifier.setSelectedShotId(id),
        ),
        center: selected != null
            ? _buildTrackReviewPanel(selected)
            : Center(
                child: Text('从左侧选择镜头开始审核',
                    style: TextStyle(color: Colors.grey[500]))),
        rightPanel: ReviewRightPanel(shot: selected),
      ),
    );
  }

  Widget _buildTrackReviewPanel(dynamic shot) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewTrackCard(
            title: '🎬 视频画面',
            score: 92,
            trackType: 'video',
            items: const [
              QACheckItem(name: '运镜流畅度', score: 88, feedback: '运镜平滑'),
              QACheckItem(name: '画面质量', score: 90, feedback: '清晰无伪影'),
              QACheckItem(name: '角色一致性', score: 85, feedback: '与设定一致'),
              QACheckItem(name: '镜图还原度', score: 92, feedback: '高度一致'),
              QACheckItem(name: '帧间一致性', score: 82, feedback: '基本稳定'),
            ],
          ),
          const SizedBox(height: 12),
          ReviewTrackCard(
            title: '🎤 VO 对白',
            score: 88,
            trackType: 'vo',
            items: const [
              QACheckItem(name: '台词准确性', score: 95, feedback: '台词完整'),
              QACheckItem(name: '音色匹配', score: 88, feedback: '音色一致'),
              QACheckItem(name: '语速', score: 80, feedback: '语速适中'),
              QACheckItem(name: '情绪表达', score: 85, feedback: '情绪到位'),
              QACheckItem(name: '音频质量', score: 92, feedback: '清晰无杂音'),
            ],
          ),
          const SizedBox(height: 12),
          ReviewTrackCard(
            title: '🎵 BGM 配乐',
            score: 90,
            trackType: 'bgm',
            items: const [
              QACheckItem(name: '情绪匹配', score: 90, feedback: '风格匹配'),
              QACheckItem(name: '节奏匹配', score: 85, feedback: '节奏配合'),
              QACheckItem(name: '音量平衡', score: 88, feedback: '不压盖对白'),
              QACheckItem(name: '过渡自然度', score: 78, feedback: '衔接稍突兀'),
            ],
          ),
          const SizedBox(height: 12),
          ReviewTrackCard(
            title: '🔊 音效',
            score: 72,
            trackType: 'sfx',
            items: const [
              QACheckItem(name: '音效质量', score: 85, feedback: '清晰'),
              QACheckItem(name: '触发时机', score: 72, feedback: '偏晚0.2s'),
            ],
          ),
          const SizedBox(height: 12),
          ReviewTrackCard(
            title: '👄 口型同步',
            score: 85,
            trackType: 'lip_sync',
            items: const [
              QACheckItem(name: '嘴型吻合度', score: 85, feedback: '基本同步'),
              QACheckItem(name: '自然度', score: 78, feedback: '闭合时轻微僵硬'),
              QACheckItem(name: '面部稳定', score: 90, feedback: '无面部扭曲'),
            ],
          ),
          const SizedBox(height: 12),
          ReviewTrackCard(
            title: '🎯 整体协调',
            score: 87,
            trackType: 'overall',
            items: const [
              QACheckItem(name: '视听同步', score: 88, feedback: '配合良好'),
              QACheckItem(name: '情绪一致', score: 85, feedback: '全轨道统一'),
              QACheckItem(name: '节奏感', score: 80, feedback: '整体适中'),
              QACheckItem(name: '转场衔接', score: 82, feedback: '衔接自然'),
              QACheckItem(name: '音量平衡', score: 90, feedback: '比例合理'),
            ],
          ),
        ],
      ),
    );
  }
}
