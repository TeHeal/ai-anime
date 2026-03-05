import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_basic_info_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_bottom_bar.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_image_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_status_banner.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_style_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_variants_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_voice_card.dart';

/// 角色详情面板：状态横幅 + 形象+信息(含小传) / 风格+音色+变体 + 底部操作栏
class CharacterDetailPanel extends ConsumerStatefulWidget {
  const CharacterDetailPanel({
    super.key,
    required this.character,
    this.onConfirm,
    required this.onDelete,
    required this.onEdit,
    this.onAIComplete,
  });

  final Character character;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onAIComplete;

  @override
  ConsumerState<CharacterDetailPanel> createState() =>
      _CharacterDetailPanelState();
}

class _CharacterDetailPanelState extends ConsumerState<CharacterDetailPanel> {
  // 骨架步骤跳转用的 GlobalKey：基础信息、风格、形象、声音
  final _infoKey = GlobalKey();
  final _styleKey = GlobalKey();
  final _imageKey = GlobalKey();
  final _voiceKey = GlobalKey();

  Character get c => widget.character;

  void _scrollToStep(int stepIndex) {
    if (stepIndex >= 4) return;
    final keys = [_infoKey, _styleKey, _imageKey, _voiceKey];
    Future.delayed(MotionTokens.durationFast, () {
      final target = keys[stepIndex].currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: MotionTokens.durationMedium,
          curve: MotionTokens.curveStandard,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Spacing.xl.w,
              Spacing.mid.h,
              Spacing.xl.w,
              Spacing.xxl.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CharacterStatusBanner(character: c),
                // 第一行：形象(6) + 基础信息含小传(4)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        key: _imageKey,
                        child: CharacterImageCard(character: c),
                      ),
                    ),
                    SizedBox(width: Spacing.lg.w),
                    Expanded(
                      flex: 4,
                      child: Container(
                        key: _infoKey,
                        child: CharacterBasicInfoCard(
                          character: c,
                          onEdit: widget.onEdit,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Spacing.xl.h),
                // 第二行：风格 + 音色 + 变体，三列等宽等高
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          key: _styleKey,
                          child: CharacterStyleCard(character: c),
                        ),
                      ),
                      SizedBox(width: Spacing.lg.w),
                      Expanded(
                        child: Container(
                          key: _voiceKey,
                          child: CharacterVoiceCard(character: c),
                        ),
                      ),
                      SizedBox(width: Spacing.lg.w),
                      Expanded(
                        child: CharacterVariantsCard(character: c),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        CharacterBottomBar(
          character: c,
          onConfirm: c.isConfirmed ? null : widget.onConfirm,
          onDelete: widget.onDelete,
          onAIComplete: c.isSkeleton ? widget.onAIComplete : null,
          onSave: c.isConfirmed
              ? () => ref.read(assetCharactersProvider.notifier).update(c)
              : null,
          onScrollToStep: _scrollToStep,
        ),
      ],
    );
  }
}
