import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/module/assets/shared/asset_detail_shell.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_basic_info_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_image_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_style_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_voice_card.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_bottom_bar.dart';

/// 角色详情面板：组合基础信息、形象、风格、音色卡片 + 底部操作栏
class CharacterDetailPanel extends ConsumerWidget {
  const CharacterDetailPanel({
    super.key,
    required this.character,
    this.onConfirm,
    required this.onDelete,
    this.onGenerateImage,
    required this.onEdit,
  });

  final Character character;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback? onGenerateImage;
  final VoidCallback onEdit;

  Character get c => character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AssetDetailShell(
      bottomBar: CharacterBottomBar(
        character: c,
        onConfirm: c.isConfirmed ? null : onConfirm,
        onDelete: onDelete,
        onGenerateImage: onGenerateImage,
        onEdit: onEdit,
      ),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CharacterImageCard(character: c),
                  SizedBox(height: Spacing.lg.h),
                  CharacterBasicInfoCard(character: c, onEdit: onEdit),
                  SizedBox(height: Spacing.lg.h),
                  CharacterStyleCard(character: c),
                  SizedBox(height: Spacing.lg.h),
                  CharacterVoiceCard(character: c),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      CharacterImageCard(character: c),
                    ],
                  ),
                ),
                SizedBox(width: Spacing.lg.w),
                Expanded(
                  flex: 4,
                  child: CharacterBasicInfoCard(character: c, onEdit: onEdit),
                ),
              ],
            );
          },
        ),
        SizedBox(height: Spacing.lg.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CharacterStyleCard(character: c),
                  SizedBox(height: Spacing.lg.h),
                  CharacterVoiceCard(character: c),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CharacterStyleCard(character: c)),
                SizedBox(width: Spacing.lg.w),
                Expanded(child: CharacterVoiceCard(character: c)),
              ],
            );
          },
        ),
      ],
    );
  }
}
