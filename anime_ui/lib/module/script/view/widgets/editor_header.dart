import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/view/review_ui_provider.dart';
import 'package:anime_ui/module/script/view/widgets/editor_common.dart';

// ---------------------------------------------------------------------------
// 编辑器顶栏 & 基础信息
// ---------------------------------------------------------------------------

Widget buildEditorHeader(ShotV4 shot, List<ShotV4> allShots, int idx,
    bool editing, ReviewUiNotifier uiNotifier) {
  return Row(
    children: [
      Text('镜头 #${shot.shotNumber}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
      const SizedBox(width: 10),
      priorityBadge(shot.priority),
      const SizedBox(width: 12),
      _modeToggle(editing, uiNotifier),
      const Spacer(),
      OutlinedButton.icon(
        onPressed: idx > 0 ? () => uiNotifier.navigateShot(-1) : null,
        icon: const Icon(AppIcons.chevronLeft, size: 14),
        label: const Text('上一镜'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed:
            idx < allShots.length - 1 ? () => uiNotifier.navigateShot(1) : null,
        icon: const Icon(AppIcons.chevronRight, size: 14),
        label: const Text('下一镜'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}

Widget _modeToggle(bool editing, ReviewUiNotifier notifier) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF252540),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _modeBtn('编辑', AppIcons.edit, editing,
            () => notifier.setEditMode(true)),
        _modeBtn('预览', AppIcons.lockOutline, !editing,
            () => notifier.setEditMode(false)),
      ],
    ),
  );
}

Widget _modeBtn(
    String label, IconData icon, bool active, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: active ? AppColors.primary : Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: active ? AppColors.primary : Colors.grey[600],
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    ),
  );
}

// ── 基础信息 ──

Widget buildBasicInfo(
    ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  return LayoutBuilder(builder: (context, constraints) {
    final cols = constraints.maxWidth > 600 ? 4 : 3;
    final w = (constraints.maxWidth - 12 * (cols - 1)) / cols;

    final fields = <Widget>[
      SizedBox(width: w, child: readChip('镜号', '${shot.shotNumber}')),
      SizedBox(
        width: w,
        child: editing
            ? _durationStepper(shot, notifier)
            : readChip('时长', '${shot.duration}s'),
      ),
      SizedBox(
        width: w,
        child: editing
            ? editorDropdown('景别', shot.cameraScale,
                ControlledVocabulary().cameraScales,
                onChanged: (v) => notifier
                    .updateCurrentShot((s) => s.copyWith(cameraScale: v)))
            : readChip('景别', shot.cameraScale),
      ),
      SizedBox(
        width: w,
        child: editing
            ? editField('运镜', shot.cameraMovement,
                onChanged: (v) => notifier.updateCurrentShot(
                    (s) => s.copyWith(cameraMovement: v)))
            : readChip('运镜', shot.cameraMovement),
      ),
      SizedBox(
        width: w,
        child: editing
            ? editorDropdown('转场', shot.transition,
                ControlledVocabulary().transitions,
                onChanged: (v) =>
                    notifier.updateCurrentShot((s) => s.copyWith(transition: v)))
            : readChip('转场', shot.transition),
      ),
      SizedBox(
        width: w,
        child: editing
            ? editorDropdown('优先级', shot.priority,
                ControlledVocabulary().priorities,
                onChanged: (v) =>
                    notifier.updateCurrentShot((s) => s.copyWith(priority: v)))
            : readChip('优先级', shot.priority),
      ),
      if (shot.timeline != null) ...[
        SizedBox(
            width: w,
            child: readChip('开始', '${shot.timeline!.start}s')),
        SizedBox(
            width: w,
            child: readChip('结束', '${shot.timeline!.end}s')),
      ],
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: fields);
  });
}

Widget _durationStepper(ShotV4 shot, ReviewUiNotifier notifier) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('时长', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF252535),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                if (shot.duration > 0.5) {
                  notifier.updateCurrentShot(
                      (s) => s.copyWith(duration: s.duration - 0.5));
                }
              },
              child: Icon(AppIcons.chevronLeft,
                  size: 14, color: Colors.grey[400]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${shot.duration}s',
                  style: const TextStyle(fontSize: 13, color: Colors.white)),
            ),
            InkWell(
              onTap: () => notifier.updateCurrentShot(
                  (s) => s.copyWith(duration: s.duration + 0.5)),
              child: Icon(AppIcons.chevronRight,
                  size: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    ],
  );
}
