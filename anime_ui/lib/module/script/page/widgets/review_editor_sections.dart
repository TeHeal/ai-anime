part of 'review_editor.dart';

// ---------------------------------------------------------------------------
// 编辑器顶栏、基础信息、画面提示词、角色、情绪
// ---------------------------------------------------------------------------

Widget _buildEditorHeader(
  ShotV4 shot,
  List<ShotV4> allShots,
  int idx,
  bool editing,
  ReviewUiNotifier uiNotifier,
) {
  return Row(
    children: [
      Text(
        '镜头 #${shot.shotNumber}',
        style: AppTextStyles.h3.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      SizedBox(width: Spacing.md.w),
      _priorityBadge(shot.priority),
      SizedBox(width: Spacing.md.w),
      _modeToggle(editing, uiNotifier),
      const Spacer(),
      OutlinedButton.icon(
        onPressed: idx > 0 ? () => uiNotifier.navigateShot(-1) : null,
        icon: Icon(AppIcons.chevronLeft, size: 14.r),
        label: const Text('上一镜'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          textStyle: AppTextStyles.labelMedium,
        ),
      ),
      SizedBox(width: Spacing.sm.w),
      OutlinedButton.icon(
        onPressed: idx < allShots.length - 1
            ? () => uiNotifier.navigateShot(1)
            : null,
        icon: Icon(AppIcons.chevronRight, size: 14.r),
        label: const Text('下一镜'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          textStyle: AppTextStyles.labelMedium,
        ),
      ),
    ],
  );
}

Widget _modeToggle(bool editing, ReviewUiNotifier notifier) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _modeBtn(
          '编辑',
          AppIcons.edit,
          editing,
          () => notifier.setEditMode(true),
        ),
        _modeBtn(
          '预览',
          AppIcons.lockOutline,
          !editing,
          () => notifier.setEditMode(false),
        ),
      ],
    ),
  );
}

Widget _modeBtn(String label, IconData icon, bool active, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.r,
            color: active
                ? AppColors.primary
                : AppColors.onSurface.withValues(alpha: 0.5),
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              color: active
                  ? AppColors.primary
                  : AppColors.onSurface.withValues(alpha: 0.5),
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBasicInfo(ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cols = Breakpoints.isMdOrUp(constraints.maxWidth) ? 4 : 3;
      final w = (constraints.maxWidth - Spacing.formGap * (cols - 1)) / cols;

      final fields = <Widget>[
        SizedBox(width: w, child: _readChip('镜号', '${shot.shotNumber}')),
        SizedBox(
          width: w,
          child: editing
              ? _durationStepper(shot, notifier)
              : _readChip('时长', '${shot.duration}s'),
        ),
        SizedBox(
          width: w,
          child: editing
              ? _dropdown(
                  '景别',
                  shot.cameraScale,
                  const ControlledVocabulary().cameraScales,
                  onChanged: (v) => notifier.updateCurrentShot(
                    (s) => s.copyWith(cameraScale: v),
                  ),
                )
              : _readChip('景别', shot.cameraScale),
        ),
        SizedBox(
          width: w,
          child: editing
              ? _editField(
                  '运镜',
                  shot.cameraMovement,
                  onChanged: (v) => notifier.updateCurrentShot(
                    (s) => s.copyWith(cameraMovement: v),
                  ),
                )
              : _readChip('运镜', shot.cameraMovement),
        ),
        SizedBox(
          width: w,
          child: editing
              ? _dropdown(
                  '转场',
                  shot.transition,
                  const ControlledVocabulary().transitions,
                  onChanged: (v) => notifier.updateCurrentShot(
                    (s) => s.copyWith(transition: v),
                  ),
                )
              : _readChip('转场', shot.transition),
        ),
        SizedBox(
          width: w,
          child: editing
              ? _dropdown(
                  '优先级',
                  shot.priority,
                  const ControlledVocabulary().priorities,
                  onChanged: (v) => notifier.updateCurrentShot(
                    (s) => s.copyWith(priority: v),
                  ),
                )
              : _readChip('优先级', shot.priority),
        ),
        if (shot.timeline != null) ...[
          SizedBox(
            width: w,
            child: _readChip('开始', '${shot.timeline!.start}s'),
          ),
          SizedBox(width: w, child: _readChip('结束', '${shot.timeline!.end}s')),
        ],
      ];

      return Wrap(
        spacing: Spacing.md.w,
        runSpacing: Spacing.md.h,
        children: fields,
      );
    },
  );
}

Widget _durationStepper(ShotV4 shot, ReviewUiNotifier notifier) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '时长',
        style: AppTextStyles.tiny.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      SizedBox(height: Spacing.xs.h),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                if (shot.duration > 0.5) {
                  notifier.updateCurrentShot(
                    (s) => s.copyWith(duration: s.duration - 0.5),
                  );
                }
              },
              child: Icon(
                AppIcons.chevronLeft,
                size: 14.r,
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
              child: Text(
                '${shot.duration}s',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            InkWell(
              onTap: () => notifier.updateCurrentShot(
                (s) => s.copyWith(duration: s.duration + 0.5),
              ),
              child: Icon(
                AppIcons.chevronRight,
                size: 14.r,
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildScenePromptCard(
  ShotV4 shot,
  bool editing,
  ReviewUiNotifier notifier,
) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('2. 画面 & 提示词'),
        const Divider(height: 1, color: AppColors.divider),
        Padding(
          padding: EdgeInsets.all(Spacing.lg.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              editing
                  ? _editField(
                      '画面描述',
                      shot.sceneDescription,
                      fullWidth: true,
                      maxLines: 3,
                      onChanged: (v) => notifier.updateCurrentShot(
                        (s) => s.copyWith(sceneDescription: v),
                      ),
                    )
                  : _readField('画面描述', shot.sceneDescription, fullWidth: true),
              SizedBox(height: Spacing.md.h),
              editing
                  ? _editField(
                      '角色站位',
                      shot.characterPosition,
                      fullWidth: true,
                      onChanged: (v) => notifier.updateCurrentShot(
                        (s) => s.copyWith(characterPosition: v),
                      ),
                    )
                  : _readField('角色站位', shot.characterPosition, fullWidth: true),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 提示词',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: Spacing.sm.h),
                editing
                    ? _editField(
                        '提示词',
                        shot.aiPrompt,
                        fullWidth: true,
                        maxLines: 4,
                        onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(aiPrompt: v),
                        ),
                      )
                    : _promptBlock(shot.aiPrompt),
                SizedBox(height: Spacing.md.h),
                editing
                    ? _editField(
                        '反向提示词',
                        shot.negativePrompt,
                        fullWidth: true,
                        labelColor: AppColors.error.withValues(alpha: 0.8),
                        onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(negativePrompt: v),
                        ),
                      )
                    : _negativeBlock(shot.negativePrompt),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _promptBlock(String text) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(Spacing.md.r),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: SelectableText(
      text.isNotEmpty ? text : '—',
      style: AppTextStyles.bodySmall.copyWith(
        color: text.isNotEmpty
            ? AppColors.onSurface.withValues(alpha: 0.75)
            : AppColors.onSurface.withValues(alpha: 0.5),
        fontFamily: 'monospace',
        height: 1.5,
      ),
    ),
  );
}

Widget _negativeBlock(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: EdgeInsets.only(top: Spacing.xs.h),
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
        ),
        child: Text(
          '反向提示词',
          style: AppTextStyles.tiny.copyWith(
            color: AppColors.error.withValues(alpha: 0.8),
          ),
        ),
      ),
      SizedBox(width: Spacing.sm.w),
      Expanded(
        child: Text(
          text.isNotEmpty ? text : '—',
          style: AppTextStyles.labelMedium.copyWith(
            color: text.isNotEmpty
                ? AppColors.onSurface.withValues(alpha: 0.6)
                : AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    ],
  );
}

Widget _buildCharacterCard(
  ShotV4 shot,
  bool editing,
  List<Character> characters,
  ReviewUiNotifier notifier,
) {
  final matchedChar = characters
      .where(
        (c) =>
            c.name == shot.characterName ||
            (shot.characterId.isNotEmpty &&
                c.id?.toString() == shot.characterId),
      )
      .firstOrNull;
  final hasWarning =
      shot.characterName.isNotEmpty &&
      matchedChar == null &&
      characters.isNotEmpty;

  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      border: Border.all(
        color: hasWarning
            ? AppColors.warning.withValues(alpha: 0.5)
            : AppColors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          '3. 角色',
          trailing: hasWarning
              ? Tooltip(
                  message: '角色未在资产栏中找到',
                  child: Icon(
                    AppIcons.warning,
                    size: 14.r,
                    color: AppColors.warning,
                  ),
                )
              : null,
        ),
        const Divider(height: 1, color: AppColors.divider),
        Padding(
          padding: EdgeInsets.all(Spacing.lg.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Spacing.barHeight.w,
                height: Spacing.barHeight.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  border: Border.all(color: AppColors.border),
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
                        size: 20.r,
                        color: AppColors.onSurface.withValues(alpha: 0.5),
                      ),
              ),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: editing
                    ? _buildCharacterEdit(shot, characters, notifier)
                    : _buildCharacterPreview(shot, matchedChar),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCharacterEdit(
  ShotV4 shot,
  List<Character> characters,
  ReviewUiNotifier notifier,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (characters.isNotEmpty)
        DropdownButtonFormField<String>(
          initialValue: characters.any((c) => c.name == shot.characterName)
              ? shot.characterName
              : null,
          decoration: InputDecoration(
            isDense: true,
            labelText: '角色',
            labelStyle: AppTextStyles.labelMedium,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
            border: const OutlineInputBorder(),
          ),
          dropdownColor: AppColors.surfaceContainer,
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
        )
      else
        _editField(
          '角色',
          shot.characterName,
          onChanged: (v) =>
              notifier.updateCurrentShot((s) => s.copyWith(characterName: v)),
        ),
      SizedBox(height: Spacing.sm.h),
      _editField(
        '角色ID',
        shot.characterId,
        onChanged: (v) =>
            notifier.updateCurrentShot((s) => s.copyWith(characterId: v)),
      ),
    ],
  );
}

Widget _buildCharacterPreview(ShotV4 shot, Character? matchedChar) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        shot.characterName.isNotEmpty ? shot.characterName : '未指定角色',
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: shot.characterName.isNotEmpty
              ? AppColors.onSurface
              : AppColors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      if (shot.characterId.isNotEmpty) ...[
        SizedBox(height: Spacing.xs.h),
        Text(
          'ID: ${shot.characterId}',
          style: AppTextStyles.tiny.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
      if (matchedChar != null) ...[
        SizedBox(height: Spacing.xs.h),
        Wrap(
          spacing: Spacing.sm.w,
          children: [
            if (matchedChar.roleType.isNotEmpty)
              _tinyTag(matchedChar.roleType, AppColors.info),
            if (matchedChar.importance.isNotEmpty)
              _tinyTag(matchedChar.importance, AppColors.tagAmber),
          ],
        ),
      ],
    ],
  );
}

Widget _tinyTag(String label, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.sm.w,
      vertical: Spacing.dividerHeight.h,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
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

Widget _buildEmotionCard(ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  final hasVector = shot.emotionVector.isNotEmpty;
  final hasDesc = shot.emotionDescription.isNotEmpty;
  if (!hasVector && !hasDesc && !editing) return const SizedBox.shrink();

  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('4. 情绪'),
        const Divider(height: 1, color: AppColors.divider),
        Padding(
          padding: EdgeInsets.all(Spacing.lg.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              editing
                  ? _editField(
                      '情绪描述',
                      shot.emotionDescription,
                      fullWidth: true,
                      onChanged: (v) => notifier.updateCurrentShot(
                        (s) => s.copyWith(emotionDescription: v),
                      ),
                    )
                  : _readField(
                      '情绪描述',
                      shot.emotionDescription,
                      fullWidth: true,
                    ),
              if (hasVector || editing) ...[
                SizedBox(height: Spacing.md.h),
                Text(
                  '情绪向量 (IndexTTS2)',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                SizedBox(height: Spacing.sm.h),
                EmotionVectorWidget(
                  vector: shot.emotionVector,
                  editing: editing,
                  onChanged: (newVec) {
                    notifier.updateCurrentShot((s) {
                      s.emotionVector = newVec;
                      return s;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
