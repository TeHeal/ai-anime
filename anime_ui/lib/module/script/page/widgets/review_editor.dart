import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_network_image.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/script/providers/review_ui.dart';
import 'package:anime_ui/module/script/page/widgets/emotion_vector_widget.dart';

part 'review_editor_shared.dart';
part 'review_editor_sections.dart';
part 'review_editor_media.dart';

// ---------------------------------------------------------------------------
// 中栏：审核编辑器
// ---------------------------------------------------------------------------

class ReviewEditor extends ConsumerWidget {
  final ShotV4 shot;
  final List<ShotV4> allShots;

  const ReviewEditor({super.key, required this.shot, required this.allShots});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(reviewUiProvider);
    final uiNotifier = ref.read(reviewUiProvider.notifier);
    final idx = allShots.indexWhere((s) => s.shotNumber == shot.shotNumber);
    final editing = reviewIsEditMode(uiState, shot);
    final characters = ref.watch(assetCharactersProvider).value ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.xl.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditorHeader(shot, allShots, idx, editing, uiNotifier),
          SizedBox(height: Spacing.xl.h),

          _section('1. 基础信息', _buildBasicInfo(shot, editing, uiNotifier)),
          SizedBox(height: Spacing.md.h),

          _buildScenePromptCard(shot, editing, uiNotifier),
          SizedBox(height: Spacing.md.h),

          _buildCharacterCard(shot, editing, characters, uiNotifier),
          SizedBox(height: Spacing.md.h),

          _buildEmotionCard(shot, editing, uiNotifier),
          SizedBox(height: Spacing.md.h),

          _buildCollapsibleCard(
            title: '5. 音频',
            icon: AppIcons.music,
            expanded: uiState.audioExpanded,
            onToggle: uiNotifier.toggleAudioExpanded,
            badge: _audioBadge(shot),
            child: _buildAudioContent(shot, editing, uiNotifier),
          ),
          const SizedBox(height: Spacing.md),

          _buildCollapsibleCard(
            title: '6. 图像',
            icon: AppIcons.image,
            expanded: uiState.imageExpanded,
            onToggle: uiNotifier.toggleImageExpanded,
            badge: shot.image?.enabled == true ? _enabledDot() : null,
            child: _buildImageFull(shot, editing),
          ),
          const SizedBox(height: Spacing.md),

          _buildCollapsibleCard(
            title: '7. 视频',
            icon: AppIcons.video,
            expanded: uiState.videoExpanded,
            onToggle: uiNotifier.toggleVideoExpanded,
            badge: shot.video?.enabled == true ? _enabledDot() : null,
            child: _buildVideoFull(shot, editing),
          ),

          if (shot.notes.isNotEmpty || editing) ...[
            SizedBox(height: Spacing.md.h),
            _section(
              '8. 备注',
              editing
                  ? _editField(
                      '',
                      shot.notes,
                      fullWidth: true,
                      onChanged: (v) => uiNotifier.updateCurrentShot(
                        (s) => s.copyWith(notes: v),
                      ),
                    )
                  : _readField('', shot.notes, fullWidth: true),
            ),
          ],
        ],
      ),
    );
  }
}
