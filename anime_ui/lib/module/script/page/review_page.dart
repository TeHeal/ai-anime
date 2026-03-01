import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/review_layout/review_scaffold.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/providers/review_ui.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';
import 'package:anime_ui/module/script/page/widgets/review_editor.dart';
import 'package:anime_ui/module/script/page/widgets/review_left_nav.dart';
import 'package:anime_ui/module/script/page/widgets/review_right_panel.dart';

// ---------------------------------------------------------------------------
// 审核编辑页面（薄壳：组合三栏布局 + 快捷键）
// 使用 ReviewScaffold 与 shots/shot_images 审核页保持一致
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
      child: ReviewScaffold(
        leftNav: ReviewLeftNav(episodes: episodes, allShots: allShots),
        center: selected != null
            ? ReviewEditor(shot: selected, allShots: allShots)
            : Center(
                child: Text(
                  '从左侧选择镜头开始审核',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
              ),
        rightPanel: ReviewRightPanel(shot: selected, allShots: allShots),
      ),
    );
  }
}
