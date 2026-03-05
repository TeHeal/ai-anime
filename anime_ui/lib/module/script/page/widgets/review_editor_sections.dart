part of 'review_editor.dart';

// ---------------------------------------------------------------------------
// 编辑器顶栏、属性 Chip 行
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
      // 镜头号 + 电影胶片图标
      Icon(AppIcons.film, size: 18.r, color: AppColors.primary),
      SizedBox(width: Spacing.sm.w),
      Text(
        '镜头 #${shot.shotNumber}',
        style: AppTextStyles.h3.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      SizedBox(width: Spacing.md.w),
      _priorityBadge(shot.priority),
      SizedBox(width: Spacing.lg.w),
      _modeToggle(editing, uiNotifier),
      const Spacer(),
      _navButton(
        icon: AppIcons.chevronLeft,
        label: '上一镜',
        onPressed: idx > 0 ? () => uiNotifier.navigateShot(-1) : null,
      ),
      SizedBox(width: Spacing.sm.w),
      _navButton(
        icon: AppIcons.chevronRight,
        label: '下一镜',
        onPressed: idx < allShots.length - 1
            ? () => uiNotifier.navigateShot(1)
            : null,
        iconFirst: false,
      ),
    ],
  );
}

Widget _navButton({
  required IconData icon,
  required String label,
  VoidCallback? onPressed,
  bool iconFirst = true,
}) {
  final iconWidget = Icon(icon, size: 12.r);
  final labelWidget = Text(label);
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: iconFirst ? iconWidget : labelWidget,
    label: iconFirst ? labelWidget : iconWidget,
    style: OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      textStyle: AppTextStyles.labelMedium,
      side: BorderSide(
        color: onPressed != null
            ? AppColors.border
            : AppColors.border.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      ),
    ),
  );
}

Widget _modeToggle(bool editing, ReviewUiNotifier notifier) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _modeBtn('编辑', AppIcons.edit, editing, () => notifier.setEditMode(true)),
        _modeBtn('预览', AppIcons.lockOutline, !editing, () => notifier.setEditMode(false)),
      ],
    ),
  );
}

Widget _modeBtn(String label, IconData icon, bool active, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.r,
            color: active
                ? AppColors.primary
                : AppColors.mutedDark,
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: active ? AppColors.primary : AppColors.mutedDark,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

/// 属性标签行：紧凑的胶囊 Chip
Widget _buildAttributeChips(
  ShotV4 shot,
  bool editing,
  ReviewUiNotifier notifier,
) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (editing) {
        return _buildAttributeChipsEditing(shot, notifier, constraints);
      }
      return _buildAttributeChipsPreview(shot);
    },
  );
}

Widget _buildAttributeChipsPreview(ShotV4 shot) {
  return Wrap(
    spacing: Spacing.sm.w,
    runSpacing: Spacing.sm.h,
    children: [
      _iconChip(AppIcons.clock, '${shot.duration}s'),
      _iconChip(AppIcons.camera, shot.cameraScale),
      _iconChip(AppIcons.film, shot.cameraMovement),
      _iconChip(AppIcons.layers, shot.transition),
      if (shot.timeline != null)
        _iconChip(
          AppIcons.play,
          '${shot.timeline!.start}s → ${shot.timeline!.end}s',
        ),
    ],
  );
}

Widget _buildAttributeChipsEditing(
  ShotV4 shot,
  ReviewUiNotifier notifier,
  BoxConstraints constraints,
) {
  final cols = Breakpoints.isMdOrUp(constraints.maxWidth) ? 4 : 3;
  final w = (constraints.maxWidth - Spacing.formGap * (cols - 1)) / cols;

  return Wrap(
    spacing: Spacing.formGap.w,
    runSpacing: Spacing.md.h,
    children: [
      SizedBox(width: w, child: _durationStepper(shot, notifier)),
      SizedBox(
        width: w,
        child: _compactDropdown(
          '景别', shot.cameraScale,
          const ControlledVocabulary().cameraScales,
          onChanged: (v) => notifier.updateCurrentShot(
            (s) => s.copyWith(cameraScale: v),
          ),
        ),
      ),
      SizedBox(
        width: w,
        child: _compactField(
          '运镜', shot.cameraMovement,
          onChanged: (v) => notifier.updateCurrentShot(
            (s) => s.copyWith(cameraMovement: v),
          ),
        ),
      ),
      SizedBox(
        width: w,
        child: _compactDropdown(
          '转场', shot.transition,
          const ControlledVocabulary().transitions,
          onChanged: (v) => notifier.updateCurrentShot(
            (s) => s.copyWith(transition: v),
          ),
        ),
      ),
      SizedBox(
        width: w,
        child: _compactDropdown(
          '优先级', shot.priority,
          const ControlledVocabulary().priorities,
          onChanged: (v) => notifier.updateCurrentShot(
            (s) => s.copyWith(priority: v),
          ),
        ),
      ),
      if (shot.timeline != null) ...[
        SizedBox(
          width: w,
          child: _readOnlyChip('开始', '${shot.timeline!.start}s'),
        ),
        SizedBox(
          width: w,
          child: _readOnlyChip('结束', '${shot.timeline!.end}s'),
        ),
      ],
    ],
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
          color: AppColors.muted,
        ),
      ),
      SizedBox(height: Spacing.xs.h),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepperBtn(
              AppIcons.chevronLeft,
              shot.duration > 0.5
                  ? () => notifier.updateCurrentShot(
                        (s) => s.copyWith(duration: s.duration - 0.5),
                      )
                  : null,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Text(
                '${shot.duration}s',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _stepperBtn(
              AppIcons.chevronRight,
              () => notifier.updateCurrentShot(
                (s) => s.copyWith(duration: s.duration + 0.5),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _stepperBtn(IconData icon, VoidCallback? onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
    child: Padding(
      padding: EdgeInsets.all(Spacing.xs.r),
      child: Icon(
        icon,
        size: 12.r,
        color: onTap != null
            ? AppColors.mutedLight
            : AppColors.mutedDarker,
      ),
    ),
  );
}
