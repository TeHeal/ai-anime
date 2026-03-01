part of 'review_editor.dart';

// ---------------------------------------------------------------------------
// 可折叠卡片、音频、图像、视频
// ---------------------------------------------------------------------------

Widget _buildCollapsibleCard({
  required String title,
  required IconData icon,
  required bool expanded,
  required VoidCallback onToggle,
  Widget? badge,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.lg.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg.w,
              vertical: Spacing.md.h,
            ),
            child: Row(
              children: [
                Icon(icon, size: 16.r, color: AppColors.muted),
                SizedBox(width: Spacing.sm.w),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                if (badge != null) ...[SizedBox(width: Spacing.sm.w), badge],
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    AppIcons.expandMore,
                    size: 16.r,
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(
            children: [
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: EdgeInsets.all(Spacing.lg.r),
                child: child,
              ),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    ),
  );
}

Widget? _audioBadge(ShotV4 shot) {
  final count = shot.audio?.enabledCount ?? 0;
  if (count == 0) return null;
  return _countBadge(count);
}

Widget _buildAudioContent(
  ShotV4 shot,
  bool editing,
  ReviewUiNotifier notifier,
) {
  final audio = shot.audio;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (shot.dialogue.isNotEmpty || editing) ...[
        editing
            ? _editField(
                '台词',
                shot.dialogue,
                fullWidth: true,
                maxLines: 2,
                onChanged: (v) =>
                    notifier.updateCurrentShot((s) => s.copyWith(dialogue: v)),
              )
            : _dialogueBubble(shot.dialogue),
        SizedBox(height: Spacing.md.h),
      ],
      if (shot.audioDesignText.isNotEmpty || editing) ...[
        editing
            ? _editField(
                '音频设计',
                shot.audioDesignText,
                fullWidth: true,
                onChanged: (v) {
                  notifier.updateCurrentShot((s) {
                    s.audioDesignText = v;
                    return s;
                  });
                },
              )
            : _readField('音频设计', shot.audioDesignText, fullWidth: true),
        SizedBox(height: Spacing.md.h),
      ],
      if (audio == null)
        Text(
          '无音频配置',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mutedDarker,
          ),
        )
      else ...[
        _audioCard('VO (对白)', audio.vo?.enabled ?? false, [
          ('类型', audio.vo?.type ?? '—'),
          ('台词', audio.vo?.text ?? '—'),
          ('角色ID', audio.vo?.characterId ?? '—'),
          ('情绪', audio.vo?.emotion ?? '—'),
          ('音量', '${audio.vo?.volume ?? 0.8}'),
          ('优先级', audio.vo?.priority ?? '—'),
        ]),
        SizedBox(height: Spacing.sm.h),
        _audioCard('BGM', audio.bgm?.enabled ?? false, [
          ('类型', audio.bgm?.type ?? '—'),
          ('提示词', audio.bgm?.prompt ?? '—'),
          ('风格', audio.bgm?.style ?? '—'),
          ('情绪', audio.bgm?.emotion ?? '—'),
          ('强度', '${audio.bgm?.intensity ?? 0.6}'),
          ('淡入', '${audio.bgm?.fadeIn ?? 0.5}s'),
          ('淡出', '${audio.bgm?.fadeOut ?? 0.5}s'),
        ]),
        SizedBox(height: Spacing.sm.h),
        _audioCard('拟声', audio.foley?.enabled ?? false, [
          ('类型', audio.foley?.type ?? '—'),
          ('提示词', audio.foley?.prompt ?? '—'),
          ('描述', audio.foley?.description ?? '—'),
          ('触发时间', '${audio.foley?.triggerTime ?? 0}s'),
          ('音量', '${audio.foley?.volume ?? 0.7}'),
          ('优先级', audio.foley?.priority ?? '—'),
        ]),
        SizedBox(height: Spacing.sm.h),
        _audioCard('动态音效', audio.dynamic_?.enabled ?? false, [
          ('类型', audio.dynamic_?.type ?? '—'),
          ('提示词', audio.dynamic_?.prompt ?? '—'),
          ('描述', audio.dynamic_?.description ?? '—'),
          ('触发时间', '${audio.dynamic_?.triggerTime ?? 0}s'),
          ('音量', '${audio.dynamic_?.volume ?? 0.6}'),
        ]),
        SizedBox(height: Spacing.sm.h),
        _audioCard('氛围音效', audio.ambient?.enabled ?? false, [
          ('类型', audio.ambient?.type ?? '—'),
          ('提示词', audio.ambient?.prompt ?? '—'),
          ('描述', audio.ambient?.description ?? '—'),
          ('强度', '${audio.ambient?.intensity ?? 0.4}'),
          ('循环', audio.ambient?.loop == true ? '是' : '否'),
        ]),
      ],
    ],
  );
}

Widget _dialogueBubble(String text) {
  if (text.isEmpty) return const SizedBox.shrink();
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.gridGap.w,
      vertical: Spacing.md.h,
    ),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.formatQuote,
          size: 14.r,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
        SizedBox(width: Spacing.sm.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _audioCard(String title, bool enabled, List<(String, String)> fields) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      border: Border.all(
        color: enabled
            ? AppColors.success.withValues(alpha: 0.3)
            : AppColors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          child: Row(
            children: [
              Icon(
                enabled ? AppIcons.check : AppIcons.circleOutline,
                size: 14.r,
                color: enabled ? AppColors.success : AppColors.mutedDarker,
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: enabled ? AppColors.onSurface : AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
        if (enabled) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(Spacing.md.r),
            child: Wrap(
              spacing: Spacing.md.w,
              runSpacing: Spacing.sm.h,
              children: fields.map((f) {
                final isLong = f.$2.length > 30;
                return SizedBox(
                  width: isLong ? double.infinity : 120.w,
                  child: _miniField(f.$1, f.$2),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildImageFull(ShotV4 shot, bool editing) {
  final img = shot.image;
  if (img == null || !img.enabled) {
    return Text(
      '未启用',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.mutedDarker,
      ),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: Spacing.md.w,
        runSpacing: Spacing.md.h,
        children: [
          _readField('类型', img.type),
          _readField('风格', img.style),
          _readField('分辨率', img.resolution),
          _readField('宽高比', img.aspectRatio),
          _readField('优先级', img.priority),
        ],
      ),
      SizedBox(height: Spacing.md.h),
      _readField('提示词', img.prompt, fullWidth: true),
      SizedBox(height: Spacing.md.h),
      _readField('反向提示词', img.negativePrompt, fullWidth: true),
      if (img.overlay != null) ...[
        SizedBox(height: Spacing.md.h),
        _overlayCard('叠加特效', img.overlay!),
      ],
    ],
  );
}

Widget _buildVideoFull(ShotV4 shot, bool editing) {
  final vid = shot.video;
  if (vid == null || !vid.enabled) {
    return Text(
      '未启用',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.mutedDarker,
      ),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: Spacing.md.w,
        runSpacing: Spacing.md.h,
        children: [
          _readField('类型', vid.type),
          _readField('帧率', '${vid.frameRate}fps'),
          _readField('运镜', vid.cameraMovement),
          _readField('转场', vid.transition),
          _readField('优先级', vid.priority),
        ],
      ),
      SizedBox(height: Spacing.md.h),
      _readField('提示词', vid.prompt, fullWidth: true),
      SizedBox(height: Spacing.md.h),
      _readField('反向提示词', vid.negativePrompt, fullWidth: true),
      if (vid.dependsOn.isNotEmpty) ...[
        SizedBox(height: Spacing.md.h),
        _readField('依赖', vid.dependsOn.join(', '), fullWidth: true),
      ],
      if (vid.overlay != null) ...[
        SizedBox(height: Spacing.md.h),
        _overlayCard('叠加特效', vid.overlay!),
      ],
      if (vid.lipSync != null) ...[
        SizedBox(height: Spacing.md.h),
        _lipSyncCard(vid.lipSync!),
      ],
    ],
  );
}

Widget _overlayCard(String title, OverlayEffect overlay) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          child: Row(
            children: [
              Icon(
                overlay.enabled ? AppIcons.check : AppIcons.circleOutline,
                size: 14.r,
                color: overlay.enabled
                    ? AppColors.success
                    : AppColors.mutedDarker,
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: overlay.enabled
                      ? AppColors.onSurface
                      : AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
        if (overlay.enabled) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(Spacing.md.r),
            child: Wrap(
              spacing: Spacing.md.w,
              runSpacing: Spacing.sm.h,
              children: [
                _miniField('类型', overlay.type),
                SizedBox(
                  width: double.infinity,
                  child: _miniField('提示词', overlay.prompt),
                ),
                SizedBox(
                  width: double.infinity,
                  child: _miniField('反向提示词', overlay.negativePrompt),
                ),
                _miniField('优先级', overlay.priority),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _lipSyncCard(LipSyncConfig lipSync) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          child: Row(
            children: [
              Icon(
                lipSync.enabled ? AppIcons.check : AppIcons.circleOutline,
                size: 14.r,
                color: lipSync.enabled
                    ? AppColors.success
                    : AppColors.mutedDarker,
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                '口型同步',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: lipSync.enabled
                      ? AppColors.onSurface
                      : AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
        if (lipSync.enabled) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(Spacing.md.r),
            child: Wrap(
              spacing: Spacing.md.w,
              runSpacing: Spacing.sm.h,
              children: [
                _miniField('类型', lipSync.type),
                _miniField('依赖', lipSync.dependsOn.join(', ')),
                _miniField('优先级', lipSync.priority),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}
