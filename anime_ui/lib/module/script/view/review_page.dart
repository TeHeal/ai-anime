import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/module/script/view/review_ui_provider.dart';
import 'package:anime_ui/module/script/view/script_provider.dart';
import 'package:anime_ui/module/script/view/widgets/review_editor.dart';
import 'package:anime_ui/module/script/view/widgets/review_left_nav.dart';
import 'package:anime_ui/module/script/view/widgets/review_right_panel.dart';

// ---------------------------------------------------------------------------
// 审核编辑页面（薄壳：组合三栏布局 + 快捷键）
// ---------------------------------------------------------------------------

class ScriptReviewPage extends ConsumerStatefulWidget {
  const ScriptReviewPage({super.key});

  @override
  ConsumerState<ScriptReviewPage> createState() => _ScriptReviewPageState();
}

class _ScriptReviewPageState extends ConsumerState<ScriptReviewPage> {
  bool _loaded = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        ref.read(episodesProvider.notifier).load();
        ref.read(assetCharactersProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final uiNotifier = ref.read(reviewUiProvider.notifier);
    if (key == LogicalKeyboardKey.arrowLeft) {
      uiNotifier.navigateShot(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      uiNotifier.navigateShot(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyA &&
        !HardwareKeyboard.instance.isControlPressed) {
      final shot = uiNotifier.currentShot();
      if (shot != null && shot.reviewStatus != 'approved') {
        uiNotifier.setReview(shot.shotNumber, 'approved');
        return KeyEventResult.handled;
      }
    }
    if (key == LogicalKeyboardKey.keyR &&
        !HardwareKeyboard.instance.isControlPressed) {
      final shot = uiNotifier.currentShot();
      if (shot != null && shot.reviewStatus != 'needsRevision') {
        uiNotifier.setReview(shot.shotNumber, 'needsRevision');
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(episodesProvider).value ?? [];
    final uiState = ref.watch(reviewUiProvider);
    final shotsMap = ref.watch(episodeShotsMapProvider);

    if (uiState.selectedEpisodeId == null && episodes.isNotEmpty) {
      final first = episodes.where((e) => e.id != null).firstOrNull;
      if (first != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(reviewUiProvider.notifier).selectEpisode(first.id);
          }
        });
      }
    }

    final allShots = reviewCurrentShots(uiState, shotsMap);
    final selected = reviewCurrentShot(uiState, shotsMap);

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Row(
        children: [
          SizedBox(
            width: 240,
            child: ReviewLeftNav(episodes: episodes, allShots: allShots),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFF2A2A3C),
          ),
          Expanded(
            child: selected != null
                ? ReviewEditor(shot: selected, allShots: allShots)
                : Center(
                    child: Text(
                      '从左侧选择镜头开始审核',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFF2A2A3C),
          ),
          SizedBox(
            width: 260,
            child: ReviewRightPanel(shot: selected, allShots: allShots),
          ),
        ],
      ),
    );
  }
}
