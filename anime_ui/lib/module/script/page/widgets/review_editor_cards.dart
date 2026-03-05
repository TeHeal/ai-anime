part of 'review_editor.dart';

// ---------------------------------------------------------------------------
// 各内容分区
// ---------------------------------------------------------------------------

/// 画面描述（核心区域） + 角色站位 & 音频设计
Widget _buildSceneSection(
  ShotV4 shot,
  bool editing,
  ReviewUiNotifier notifier,
) {
  return Padding(
    padding: EdgeInsets.fromLTRB(
      Spacing.xl.w, Spacing.lg.h, Spacing.xl.w, Spacing.md.h,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledBlock(
          icon: AppIcons.image,
          label: '画面描述',
          value: shot.sceneDescription,
          editing: editing,
          accentColor: AppColors.primary,
          hint: '描述场景、道具、氛围、光影…',
          maxLines: 4,
          onChanged: (v) => notifier.updateCurrentShot(
            (s) => s.copyWith(sceneDescription: v),
          ),
        ),
        SizedBox(height: Spacing.md.h),

        // 角色站位 & 音频设计并排
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = Breakpoints.isMdOrUp(constraints.maxWidth);
            final items = [
              _labeledBlock(
                icon: AppIcons.person,
                label: '角色站位',
                value: shot.characterPosition,
                editing: editing,
                accentColor: AppColors.categoryCharacter,
                hint: '角色位置、动作…',
                onChanged: (v) => notifier.updateCurrentShot(
                  (s) => s.copyWith(characterPosition: v),
                ),
              ),
              _labeledBlock(
                icon: AppIcons.sound,
                label: '音频设计',
                value: shot.audioDesignText,
                editing: editing,
                accentColor: AppColors.categoryVoice,
                hint: '音效与氛围描述…',
                onChanged: (v) {
                  notifier.updateCurrentShot((s) {
                    s.audioDesignText = v;
                    return s;
                  });
                },
              ),
            ];
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: items[0]),
                  SizedBox(width: Spacing.md.w),
                  Expanded(child: items[1]),
                ],
              );
            }
            return Column(
              children: [
                items[0],
                SizedBox(height: Spacing.md.h),
                items[1],
              ],
            );
          },
        ),
      ],
    ),
  );
}

/// 台词与角色
Widget _buildDialogueCharacterSection(
  ShotV4 shot,
  bool editing,
  List<Character> characters,
  ReviewUiNotifier notifier,
) {
  // 优先按 characterId 精确匹配，再按 characterName 匹配（避免同名角色匹配错人）
  Character? matchedChar;
  if (shot.characterId.isNotEmpty) {
    matchedChar = characters
        .where((c) => c.id?.toString() == shot.characterId)
        .firstOrNull;
  }
  matchedChar ??= characters
      .where((c) => c.name == shot.characterName)
      .firstOrNull;
  final hasWarning =
      shot.characterName.isNotEmpty &&
      matchedChar == null &&
      characters.isNotEmpty;

  return Padding(
    padding: EdgeInsets.fromLTRB(
      Spacing.xl.w, Spacing.md.h, Spacing.xl.w, Spacing.md.h,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧：角色头像
        _characterAvatar(matchedChar),
        SizedBox(width: Spacing.md.w),
        // 右侧：角色信息 + 台词
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 角色行
              editing
                  ? _buildCharacterEdit(shot, characters, notifier)
                  : _buildCharacterPreview(shot, matchedChar, hasWarning),
              // 台词
              if (shot.dialogue.isNotEmpty || editing) ...[
                SizedBox(height: Spacing.sm.h),
                editing
                    ? _accentTextBlock(
                        value: shot.dialogue,
                        editing: true,
                        accentColor: AppColors.info,
                        hint: '「角色对白或旁白…」',
                        maxLines: 2,
                        onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(dialogue: v),
                        ),
                      )
                    : _dialogueBubble(shot.dialogue),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _characterAvatar(Character? matchedChar) {
  return Container(
    width: 36.w,
    height: 36.h,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.2),
          AppColors.info.withValues(alpha: 0.15),
        ],
      ),
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      border: Border.all(
        color: AppColors.primary.withValues(alpha: 0.25),
      ),
    ),
    child: matchedChar != null && matchedChar.imageUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            child: AppNetworkImage(
              url: resolveFileUrl(matchedChar.imageUrl),
              fit: BoxFit.cover,
            ),
          )
        : Icon(
            AppIcons.person,
            size: 16.r,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
  );
}

Widget _dialogueBubble(String text) {
  if (text.isEmpty) return const SizedBox.shrink();
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.md.w,
      vertical: Spacing.sm.h,
    ),
    decoration: BoxDecoration(
      color: AppColors.info.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      border: const Border(
        left: BorderSide(color: AppColors.info, width: 3),
      ),
    ),
    child: Text(
      '「$text」',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.onSurface.withValues(alpha: 0.9),
        height: 1.5,
      ),
    ),
  );
}

Widget _buildCharacterEdit(
  ShotV4 shot,
  List<Character> characters,
  ReviewUiNotifier notifier,
) {
  if (characters.isNotEmpty) {
    // 当前 shot 的显示值：必须在 items 中存在，否则用「无」避免非法 value
    final valueInList = characters.any((c) => c.name == shot.characterName)
        ? shot.characterName
        : '';
    return DropdownButtonFormField<String>(
      key: ValueKey('character-${shot.shotNumber}'),
      initialValue: valueInList,
      decoration: InputDecoration(
        isDense: true,
        labelText: '角色',
        labelStyle: AppTextStyles.tiny.copyWith(color: AppColors.muted),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
      ),
      dropdownColor: AppColors.surfaceContainerHighest,
      items: [
        DropdownMenuItem(
          value: '',
          child: Text('无', style: AppTextStyles.labelMedium),
        ),
        ...characters.map(
          (c) => DropdownMenuItem(
            value: c.name,
            child: Text(c.name, style: AppTextStyles.labelMedium),
          ),
        ),
      ],
      onChanged: (v) {
        final char = characters.where((c) => c.name == v).firstOrNull;
        notifier.updateCurrentShot(
          (s) => s.copyWith(
            characterName: v ?? '',
            characterId: char?.id?.toString() ?? '',
          ),
        );
      },
    );
  }
  return _compactField(
    '角色',
    shot.characterName,
    onChanged: (v) =>
        notifier.updateCurrentShot((s) => s.copyWith(
          characterName: v,
          characterId: '',
        )),
  );
}

Widget _buildCharacterPreview(
  ShotV4 shot,
  Character? matchedChar,
  bool hasWarning,
) {
  return Row(
    children: [
      Text(
        shot.characterName.isNotEmpty ? shot.characterName : '未指定角色',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: shot.characterName.isNotEmpty
              ? AppColors.onSurface
              : AppColors.mutedDark,
        ),
      ),
      if (matchedChar != null) ...[
        SizedBox(width: Spacing.sm.w),
        if (matchedChar.roleType.isNotEmpty)
          _tinyTag(matchedChar.roleType, AppColors.info),
        if (matchedChar.importance.isNotEmpty) ...[
          SizedBox(width: Spacing.xs.w),
          _tinyTag(matchedChar.importance, AppColors.tagAmber),
        ],
      ],
      if (hasWarning) ...[
        SizedBox(width: Spacing.sm.w),
        Tooltip(
          message: '角色未在资产栏中找到',
          child: Icon(
            AppIcons.warning,
            size: 12.r,
            color: AppColors.warning,
          ),
        ),
      ],
    ],
  );
}

Widget _tinyTag(String label, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.sm.w,
      vertical: Spacing.xxs.h,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
    ),
    child: Text(
      label,
      style: AppTextStyles.tiny.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

/// 情绪 + 备注合并为一行（宽屏并排，窄屏纵排）
Widget _buildFooterFields(
  ShotV4 shot,
  bool editing,
  ReviewUiNotifier notifier,
) {
  final hasEmotion = shot.emotionDescription.isNotEmpty || editing;
  final hasNotes = shot.notes.isNotEmpty || editing;
  if (!hasEmotion && !hasNotes) return const SizedBox.shrink();

  final emotionWidget = hasEmotion
      ? _labeledBlock(
          icon: AppIcons.magicStick,
          label: '情绪',
          value: shot.emotionDescription,
          editing: editing,
          accentColor: AppColors.categoryStyle,
          hint: '情绪与氛围描述…',
          onChanged: (v) => notifier.updateCurrentShot(
            (s) => s.copyWith(emotionDescription: v),
          ),
        )
      : null;

  final notesWidget = hasNotes
      ? _labeledBlock(
          icon: AppIcons.document,
          label: '备注',
          value: shot.notes,
          editing: editing,
          accentColor: AppColors.mutedDark,
          hint: '补充说明…',
          onChanged: (v) => notifier.updateCurrentShot(
            (s) => s.copyWith(notes: v),
          ),
        )
      : null;

  return Padding(
    padding: EdgeInsets.fromLTRB(
      Spacing.xl.w, Spacing.md.h, Spacing.xl.w, Spacing.md.h,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = Breakpoints.isMdOrUp(constraints.maxWidth);
        if (wide && emotionWidget != null && notesWidget != null) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: emotionWidget),
              SizedBox(width: Spacing.md.w),
              Expanded(child: notesWidget),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?emotionWidget,
            if (emotionWidget != null && notesWidget != null)
              SizedBox(height: Spacing.md.h),
            ?notesWidget,
          ],
        );
      },
    ),
  );
}
