part of 'review_editor.dart';

// ---------------------------------------------------------------------------
// 编辑器顶栏、基础信息
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
