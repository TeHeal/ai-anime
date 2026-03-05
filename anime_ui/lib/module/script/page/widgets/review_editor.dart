import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/app_network_image.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/script/providers/review_ui.dart';

part 'review_editor_shared.dart';
part 'review_editor_sections.dart';
part 'review_editor_cards.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditorHeader(shot, allShots, idx, editing, uiNotifier),
          SizedBox(height: Spacing.md.h),

          // ── 主卡片 ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(RadiusTokens.card.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部渐变条
                Container(
                  height: 2.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(RadiusTokens.card.r),
                    ),
                    gradient: LinearGradient(
                      colors: _headerGradient(shot.priority),
                    ),
                  ),
                ),

                // 属性 Chip 行
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Spacing.xl.w, Spacing.md.h, Spacing.xl.w, Spacing.sm.h,
                  ),
                  child: _buildAttributeChips(shot, editing, uiNotifier),
                ),

                _thinDivider(),

                // 画面描述 + 站位 + 音频设计
                _buildSceneSection(shot, editing, uiNotifier),

                // 台词与角色
                if (shot.dialogue.isNotEmpty ||
                    shot.characterName.isNotEmpty ||
                    editing) ...[
                  _thinDivider(),
                  _buildDialogueCharacterSection(
                    shot, editing, characters, uiNotifier,
                  ),
                ],

                // 情绪 + 备注（合并）
                if (shot.emotionDescription.isNotEmpty ||
                    shot.notes.isNotEmpty ||
                    editing) ...[
                  _thinDivider(),
                  _buildFooterFields(shot, editing, uiNotifier),
                ],

                SizedBox(height: Spacing.sm.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Color> _headerGradient(String priority) {
  if (priority.contains('P0')) {
    return [AppColors.error, AppColors.warning];
  } else if (priority.contains('P1')) {
    return [AppColors.warning, AppColors.tagAmber];
  }
  return AppColors.accentGradient;
}

Widget _thinDivider() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: Spacing.xl.w),
    child: Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.divider.withValues(alpha: 0),
            AppColors.divider,
            AppColors.divider.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}
