import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/script/page/review_ui_provider.dart';
import 'package:anime_ui/module/script/page/widgets/editor_common.dart';
import 'package:anime_ui/module/script/page/widgets/editor_header.dart';
import 'package:anime_ui/module/script/page/widgets/editor_scene_prompt.dart';
import 'package:anime_ui/module/script/page/widgets/editor_character.dart';
import 'package:anime_ui/module/script/page/widgets/editor_audio.dart';
import 'package:anime_ui/module/script/page/widgets/editor_media.dart';

// ---------------------------------------------------------------------------
// 中栏：编辑器
// ---------------------------------------------------------------------------

class ReviewEditor extends ConsumerWidget {
  final ShotV4 shot;
  final List<ShotV4> allShots;

  const ReviewEditor({
    super.key,
    required this.shot,
    required this.allShots,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(reviewUiProvider);
    final uiNotifier = ref.read(reviewUiProvider.notifier);
    final idx = allShots.indexWhere((s) => s.shotNumber == shot.shotNumber);
    final editing = reviewIsEditMode(uiState, shot);
    final characters = ref.watch(assetCharactersProvider).value ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题 + 模式切换 + 导航
          buildEditorHeader(shot, allShots, idx, editing, uiNotifier),
          const SizedBox(height: 20),

          // 1. 基础信息
          reviewSection(
              '1. 基础信息', buildBasicInfo(shot, editing, uiNotifier)),
          const SizedBox(height: 12),

          // 2. 画面 & 提示词
          buildScenePromptCard(shot, editing, uiNotifier),
          const SizedBox(height: 12),

          // 3. 角色
          buildCharacterCard(shot, editing, characters, uiNotifier),
          const SizedBox(height: 12),

          // 4. 情绪
          buildEmotionCard(shot, editing, uiNotifier),
          const SizedBox(height: 12),

          // 5. 音频（可折叠，含台词 + 音频设计）
          buildCollapsibleCard(
            title: '5. 音频',
            icon: AppIcons.music,
            expanded: uiState.audioExpanded,
            onToggle: uiNotifier.toggleAudioExpanded,
            badge: audioBadge(shot),
            child: buildAudioContent(shot, editing, uiNotifier),
          ),
          const SizedBox(height: 12),

          // 6. 图像（可折叠）
          buildCollapsibleCard(
            title: '6. 图像',
            icon: AppIcons.image,
            expanded: uiState.imageExpanded,
            onToggle: uiNotifier.toggleImageExpanded,
            badge: shot.image?.enabled == true ? enabledDot() : null,
            child: buildImageFull(shot, editing),
          ),
          const SizedBox(height: 12),

          // 7. 视频（可折叠）
          buildCollapsibleCard(
            title: '7. 视频',
            icon: AppIcons.video,
            expanded: uiState.videoExpanded,
            onToggle: uiNotifier.toggleVideoExpanded,
            badge: shot.video?.enabled == true ? enabledDot() : null,
            child: buildVideoFull(shot, editing),
          ),

          // 8. 备注
          if (shot.notes.isNotEmpty || editing) ...[
            const SizedBox(height: 12),
            reviewSection(
              '8. 备注',
              editing
                  ? editField('', shot.notes,
                      fullWidth: true,
                      onChanged: (v) =>
                          uiNotifier.updateCurrentShot((s) => s.copyWith(notes: v)))
                  : readField('', shot.notes, fullWidth: true),
            ),
          ],
        ],
      ),
    );
  }
}
