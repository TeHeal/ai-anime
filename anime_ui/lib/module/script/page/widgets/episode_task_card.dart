import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/const/actions.dart' show AppActions;
import 'package:anime_ui/pub/widgets/permission_gate.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';

/// 单集脚本生成任务卡片
/// 支持左侧状态色带、hover 浮动效果、选中态增强
class EpisodeTaskCard extends StatefulWidget {
  const EpisodeTaskCard({
    super.key,
    required this.episodeId,
    required this.title,
    required this.sortIndex,
    this.state,
    required this.isSelected,
    required this.onSelectChanged,
    required this.onGenerate,
    required this.onReview,
  });

  final String episodeId;
  final String title;
  final int sortIndex;
  final EpisodeGenerateState? state;
  final bool isSelected;
  final ValueChanged<bool> onSelectChanged;
  final VoidCallback onGenerate;
  final VoidCallback onReview;

  @override
  State<EpisodeTaskCard> createState() => _EpisodeTaskCardState();
}

class _EpisodeTaskCardState extends State<EpisodeTaskCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.state?.status ?? EpisodeScriptStatus.notStarted;
    final progress = widget.state?.progress ?? 0;
    final shotCount = widget.state?.shotCount ?? 0;

    final (accentColor, statusIcon, statusText) = _statusStyle(status);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelectChanged(!widget.isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _isHovered
              ? (Matrix4.identity()..storage[13] = -1.0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.22),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.h),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // 左侧状态色带
                  Container(width: 3.w, color: accentColor),
                  // 卡片内容
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(Spacing.lg.r),
                      child: _buildContent(
                        status, accentColor, statusIcon, statusText,
                        progress, shotCount,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 卡片主内容区
  Widget _buildContent(
    EpisodeScriptStatus status,
    Color accentColor,
    IconData statusIcon,
    String statusText,
    int progress,
    int shotCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行：序号 + 标题 + 复选框
        Row(
          children: [
            Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Center(
                child: Text(
                  '${widget.sortIndex + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Expanded(
              child: Text(
                widget.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildCheckbox(),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        // 进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor:
                AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
            color: accentColor,
            minHeight: 3.h,
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        // 状态行：图标 + 文字 + 操作按钮
        Row(
          children: [
            Icon(statusIcon, size: 13.r, color: accentColor),
            SizedBox(width: Spacing.xs.w),
            Text(
              statusText,
              style: AppTextStyles.tiny.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (status == EpisodeScriptStatus.completed) ...[
              SizedBox(width: Spacing.sm.w),
              Text(
                '$shotCount 镜头',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
            if (status == EpisodeScriptStatus.generating) ...[
              SizedBox(width: Spacing.sm.w),
              Text(
                '$progress%',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
            const Spacer(),
            _buildAction(status),
          ],
        ),
      ],
    );
  }

  /// 填充式复选框：选中为主色填充 + 白色勾号，未选中为空心方形
  Widget _buildCheckbox() {
    return Container(
      width: 18.r,
      height: 18.r,
      decoration: BoxDecoration(
        color: widget.isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary
              : AppColors.onSurface.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: widget.isSelected
          ? Icon(AppIcons.check, size: 12.r, color: AppColors.onPrimary)
          : null,
    );
  }

  Widget _buildAction(EpisodeScriptStatus status) {
    switch (status) {
      case EpisodeScriptStatus.completed:
        return PermissionGate(
          action: AppActions.scriptReview,
          child: MiniActionButton(
            label: '审核',
            icon: AppIcons.arrowForward,
            color: AppColors.success,
            onTap: widget.onReview,
          ),
        );
      case EpisodeScriptStatus.generating:
        return SizedBox(
          width: 16.r,
          height: 16.r,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      case EpisodeScriptStatus.failed:
        return PermissionGate(
          action: AppActions.aiGenerate,
          child: MiniActionButton(
            label: '重试',
            icon: AppIcons.refresh,
            color: AppColors.warning,
            onTap: widget.onGenerate,
          ),
        );
      case EpisodeScriptStatus.notStarted:
        return PermissionGate(
          action: AppActions.aiGenerate,
          child: MiniActionButton(
            label: '生成',
            icon: AppIcons.magicStick,
            color: AppColors.primary,
            onTap: widget.onGenerate,
          ),
        );
    }
  }

  /// 根据状态返回 (强调色, 状态图标, 状态文字)
  static (Color, IconData, String) _statusStyle(EpisodeScriptStatus status) {
    return switch (status) {
      EpisodeScriptStatus.completed => (
        AppColors.success,
        AppIcons.check,
        '已完成',
      ),
      EpisodeScriptStatus.generating => (
        AppColors.primary,
        AppIcons.sync,
        '生成中',
      ),
      EpisodeScriptStatus.failed => (
        AppColors.error,
        AppIcons.error,
        '失败',
      ),
      EpisodeScriptStatus.notStarted => (
        AppColors.muted,
        AppIcons.circleOutline,
        '待生成',
      ),
    };
  }
}
