import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/models/task.dart';
import 'package:anime_ui/module/task_center/providers/task_center.dart';

/// Header 全局任务角标 —— 显示活跃任务数，点击弹出轻量面板
class GlobalTaskIndicator extends ConsumerStatefulWidget {
  const GlobalTaskIndicator({super.key});

  @override
  ConsumerState<GlobalTaskIndicator> createState() =>
      _GlobalTaskIndicatorState();
}

class _GlobalTaskIndicatorState extends ConsumerState<GlobalTaskIndicator> {
  final _overlayController = OverlayPortalController();
  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskCenterProvider);
    final activeCount = taskState.runningCount + taskState.pendingCount;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (_) => _TaskOverlayPanel(
          link: _link,
          taskState: taskState,
          onClose: () => _overlayController.hide(),
          onViewAll: () {
            _overlayController.hide();
            context.go(Routes.tasks);
          },
        ),
        child: Badge(
          isLabelVisible: activeCount > 0,
          label: Text(
            activeCount > 99 ? '99+' : '$activeCount',
            style: AppTextStyles.tiny,
          ),
          backgroundColor: AppColors.primary,
          child: _IndicatorButton(
            activeCount: activeCount,
            onTap: () {
              if (_overlayController.isShowing) {
                _overlayController.hide();
              } else {
                _overlayController.show();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _IndicatorButton extends StatefulWidget {
  const _IndicatorButton({required this.activeCount, required this.onTap});

  final int activeCount;
  final VoidCallback onTap;

  @override
  State<_IndicatorButton> createState() => _IndicatorButtonState();
}

class _IndicatorButtonState extends State<_IndicatorButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.activeCount > 0
            ? '${widget.activeCount} 个任务进行中'
            : '任务中心',
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(Spacing.sm.r),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            ),
            child: Icon(
              AppIcons.rocket,
              size: 18.r,
              color: _hovered || widget.activeCount > 0
                  ? AppColors.primary
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

/// 点击角标后弹出的轻量面板，展示最近活跃任务
class _TaskOverlayPanel extends StatelessWidget {
  const _TaskOverlayPanel({
    required this.link,
    required this.taskState,
    required this.onClose,
    required this.onViewAll,
  });

  final LayerLink link;
  final TaskCenterState taskState;
  final VoidCallback onClose;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    // 取最近 5 条活跃任务（running + pending），按 running 优先
    final active = taskState.tasks
        .where((t) => t.isRunning || t.isPending)
        .toList()
      ..sort((a, b) {
        if (a.isRunning && !b.isRunning) return -1;
        if (!a.isRunning && b.isRunning) return 1;
        return 0;
      });
    final displayTasks = active.take(5).toList();

    return Stack(
      children: [
        // 点击外部关闭
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: Offset(0, Spacing.sm.h),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            color: AppColors.surface,
            child: Container(
              width: 320.w,
              constraints: BoxConstraints(maxHeight: 400.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  if (displayTasks.isEmpty)
                    _buildEmpty()
                  else
                    ...displayTasks.map(_buildTaskItem),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final running = taskState.runningCount;
    final pending = taskState.pendingCount;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.sm.h,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(AppIcons.rocket, size: 16.r, color: AppColors.primary),
          SizedBox(width: Spacing.xs.w),
          Text(
            '任务进度',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (running > 0 || pending > 0)
            Text(
              '$running 运行中 · $pending 等待',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xl.h),
      child: Column(
        children: [
          Icon(
            AppIcons.check,
            size: 28.r,
            color: AppColors.success.withValues(alpha: 0.6),
          ),
          SizedBox(height: Spacing.xs.h),
          Text(
            '暂无进行中的任务',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final progressValue = task.progress / 100.0;
    final isRunning = task.isRunning;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.sm.h,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: isRunning
                ? CircularProgressIndicator(
                    strokeWidth: 2.5,
                    value: task.progress > 0 ? progressValue : null,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  )
                : Icon(
                    AppIcons.clock,
                    size: 16.r,
                    color: AppColors.muted,
                  ),
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title.isNotEmpty ? task.title : _typeLabel(task.type),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: isRunning && task.progress > 0
                        ? progressValue
                        : null,
                    minHeight: 3.h,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            isRunning
                ? (task.progress > 0 ? '${task.progress}%' : '生成中')
                : '等待中',
            style: AppTextStyles.caption.copyWith(
              color: isRunning ? AppColors.primary : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onViewAll,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: Center(
            child: Text(
              '查看全部任务',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'image' => '图片生成',
      'video' => '视频生成',
      'tts' => '语音合成',
      'export' => '成片导出',
      'pipeline' => '流水线',
      _ => '任务',
    };
  }
}
