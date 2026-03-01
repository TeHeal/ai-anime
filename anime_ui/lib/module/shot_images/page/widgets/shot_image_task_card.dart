import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shot_images/page/provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_network_image.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';
import 'package:anime_ui/pub/widgets/task_status/status_badge.dart';

/// 将 ShotImageStatus 映射到 StatusBadge 使用的 GenerationStatus
GenerationStatus toGenerationStatus(ShotImageStatus s) {
  return switch (s) {
    ShotImageStatus.notStarted => GenerationStatus.notStarted,
    ShotImageStatus.generating => GenerationStatus.generating,
    ShotImageStatus.completed => GenerationStatus.completed,
    ShotImageStatus.failed => GenerationStatus.failed,
    ShotImageStatus.rejected => GenerationStatus.rejected,
  };
}

/// 镜图任务卡片
class ShotImageTaskCard extends StatefulWidget {
  final int shotId;
  final int shotNumber;
  final String cameraScale;
  final String prompt;
  final String imageUrl;
  final ShotImageStatus status;
  final int progress;
  final int candidateCount;
  final bool isSelected;
  final ValueChanged<bool> onSelectChanged;
  final VoidCallback onGenerate;
  final VoidCallback onReview;

  const ShotImageTaskCard({
    super.key,
    required this.shotId,
    required this.shotNumber,
    this.cameraScale = '',
    this.prompt = '',
    this.imageUrl = '',
    required this.status,
    this.progress = 0,
    this.candidateCount = 0,
    required this.isSelected,
    required this.onSelectChanged,
    required this.onGenerate,
    required this.onReview,
  });

  @override
  State<ShotImageTaskCard> createState() => _ShotImageTaskCardState();
}

class _ShotImageTaskCardState extends State<ShotImageTaskCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.status == ShotImageStatus.generating) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShotImageTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == ShotImageStatus.generating) {
      if (!_shimmerController.isAnimating) _shimmerController.repeat();
    } else {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gStatus = toGenerationStatus(widget.status);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelectChanged(!widget.isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(Spacing.md.r),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
              width: (_hovered || widget.isSelected) ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 16.r,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(gStatus),
              SizedBox(height: Spacing.sm.h),
              _buildThumbnail(),
              SizedBox(height: Spacing.sm.h),
              _buildProgressBar(gStatus),
              SizedBox(height: Spacing.sm.h),
              _buildStatusRow(gStatus),
              if (widget.prompt.isNotEmpty) ...[
                SizedBox(height: Spacing.sm.h),
                _buildPromptExcerpt(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GenerationStatus gStatus) {
    final shotLabel = 'S${widget.shotNumber.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w, vertical: Spacing.xs.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gStatus.color.withValues(alpha: 0.2),
                gStatus.color.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            border: Border.all(
              color: gStatus.color.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Text(
            shotLabel,
            style: AppTextStyles.tiny.copyWith(
              color: gStatus.color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        Expanded(
          child: Text(
            widget.cameraScale.isNotEmpty
                ? '$shotLabel · ${widget.cameraScale}'
                : shotLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          widget.isSelected ? AppIcons.checkOutline : AppIcons.circleOutline,
          size: 15.r,
          color: widget.isSelected ? AppColors.primary : AppColors.mutedDarker,
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    final isGenerating = widget.status == ShotImageStatus.generating;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.shadowOverlay,
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(height: 4.h, color: AppColors.shadowOverlay),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surfaceContainerHigh,
                          AppColors.surfaceContainer,
                        ],
                      ),
                    ),
                    child: widget.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.zero,
                            child: AppNetworkImage(
                              url: resolveFileUrl(widget.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          )
                        : _placeholderIcon(),
                  ),
                ),
                Container(height: 4.h, color: AppColors.shadowOverlay),
              ],
            ),
          ),
          if (isGenerating)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    return Opacity(
                      opacity:
                          0.15 +
                          0.15 *
                              (0.5 +
                                  0.5 *
                                      (_shimmerController.value * 2 - 1).abs()),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                              -1.0 + 2.0 * _shimmerController.value,
                              0,
                            ),
                            end: Alignment(
                              0.0 + 2.0 * _shimmerController.value,
                              0,
                            ),
                            colors: [
                              Colors.transparent,
                              AppColors.primary.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (widget.candidateCount > 1)
            Positioned(
              right: 6.w,
              top: 10.h,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w, vertical: Spacing.xxs.h),
                decoration: BoxDecoration(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                  border: Border.all(
                    color: AppColors.onSurface.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'x${widget.candidateCount}',
                  style: AppTextStyles.labelTinySmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(GenerationStatus gStatus) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      child: LinearProgressIndicator(
        value: widget.progress / 100,
        backgroundColor: AppColors.surfaceMutedDark.withValues(alpha: 0.5),
        color: gStatus.color,
        minHeight: 4.h,
      ),
    );
  }

  Widget _buildStatusRow(GenerationStatus gStatus) {
    return Row(
      children: [
        StatusBadge(
          status: gStatus,
          suffix: widget.status == ShotImageStatus.generating
              ? '${widget.progress}%'
              : null,
        ),
        const Spacer(),
        _buildAction(),
      ],
    );
  }

  Widget _buildPromptExcerpt() {
    final text = widget.prompt.length > 30
        ? '${widget.prompt.substring(0, 30)}…'
        : widget.prompt;
    return Text(
      text,
      style: AppTextStyles.labelTinySmall.copyWith(
        color: AppColors.mutedDark,
        fontStyle: FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _placeholderIcon() {
    return Center(
      child: Icon(AppIcons.image, size: 24.r, color: AppColors.surfaceMuted),
    );
  }

  Widget _buildAction() {
    return switch (widget.status) {
      ShotImageStatus.completed => MiniActionButton(
        label: '审核',
        icon: AppIcons.arrowForward,
        color: AppColors.success,
        onTap: widget.onReview,
      ),
      ShotImageStatus.generating => SizedBox(
        width: 16.w,
        height: 16.h,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      ShotImageStatus.failed => MiniActionButton(
        label: '重试',
        icon: AppIcons.refresh,
        color: AppColors.warning,
        onTap: widget.onGenerate,
      ),
      ShotImageStatus.rejected => MiniActionButton(
        label: '重跑',
        icon: AppIcons.refresh,
        color: AppColors.warning,
        onTap: widget.onGenerate,
      ),
      ShotImageStatus.notStarted => MiniActionButton(
        label: '生成',
        icon: AppIcons.magicStick,
        color: AppColors.primary,
        onTap: widget.onGenerate,
      ),
    };
  }
}
