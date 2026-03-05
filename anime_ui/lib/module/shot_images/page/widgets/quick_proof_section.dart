import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shot_images/providers/center_ui.dart';
import 'package:anime_ui/module/shot_images/page/provider.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/app_network_image.dart';

/// 快速验证面板 — 缩略图网格 + 标记通过/需调整
class QuickProofSection extends ConsumerStatefulWidget {
  final List<StoryboardShot> shots;
  final VoidCallback? onAllApproved;

  const QuickProofSection({
    super.key,
    required this.shots,
    this.onAllApproved,
  });

  @override
  ConsumerState<QuickProofSection> createState() => _QuickProofSectionState();
}

class _QuickProofSectionState extends ConsumerState<QuickProofSection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(shotImageCenterUiProvider);
    final imgStates = ref.watch(shotImageStatesProvider);
    final validShots = widget.shots
        .where((s) => s.id != null && s.id!.isNotEmpty)
        .toList();

    final verified =
        uiState.proofApproved.length + uiState.proofNeedsRevision.length;
    final total = validShots.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.2),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(total, verified, uiState),
          AnimatedSize(
            duration: MotionTokens.durationMedium,
            curve: MotionTokens.curveStandard,
            alignment: Alignment.topCenter,
            child: _collapsed
                ? const SizedBox.shrink()
                : _buildBody(validShots, imgStates, uiState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    int total,
    int verified,
    ShotImageCenterUiState uiState,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _collapsed = !_collapsed),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.cardPadding.w,
            vertical: Spacing.lg.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withValues(alpha: _collapsed ? 0.08 : 0.04),
                Colors.transparent,
              ],
            ),
            border: _collapsed
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
            borderRadius: _collapsed
                ? BorderRadius.circular(RadiusTokens.card.r)
                : BorderRadius.only(
                    topLeft: Radius.circular(RadiusTokens.card.r),
                    topRight: Radius.circular(RadiusTokens.card.r),
                  ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withValues(alpha: 0.25),
                      AppColors.warning.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Icon(AppIcons.bolt, size: 18.r, color: AppColors.warning),
              ),
              SizedBox(width: Spacing.md.w),
              Text(
                '快速验证',
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(width: Spacing.md.w),
              _statChip(
                '已验证 $verified/$total',
                verified == total && total > 0
                    ? AppColors.success
                    : AppColors.warning,
              ),
              _statChip(
                '通过 ${uiState.proofApproved.length}',
                AppColors.success,
              ),
              if (uiState.proofNeedsRevision.isNotEmpty)
                _statChip(
                  '需调整 ${uiState.proofNeedsRevision.length}',
                  AppColors.error,
                ),
              const Spacer(),
              if (!_collapsed) ...[
                _actionBtn('生成全部预览', AppIcons.bolt, AppColors.warning, () {
                  final ids = widget.shots
                      .where((s) => s.id != null && s.id!.isNotEmpty)
                      .map((s) => s.id!)
                      .toList();
                  if (ids.isEmpty) return;
                  showToast(context, '开始快速验证 ${ids.length} 个镜头');
                  ref
                      .read(shotImageStatesProvider.notifier)
                      .proofGenerate(ids);
                }),
                SizedBox(width: Spacing.sm.w),
                if (uiState.proofApproved.isNotEmpty)
                  _actionBtn(
                    '通过→正式出图',
                    AppIcons.arrowForward,
                    AppColors.success,
                    widget.onAllApproved,
                  ),
                SizedBox(width: Spacing.md.w),
              ],
              AnimatedRotation(
                turns: _collapsed ? -0.25 : 0.0,
                duration: MotionTokens.durationFast,
                child: Icon(
                  AppIcons.expandMore,
                  size: 18.r,
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    List<StoryboardShot> shots,
    Map<String, ShotImageState> imgStates,
    ShotImageCenterUiState uiState,
  ) {
    if (shots.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(Spacing.xxl.r),
        child: Center(
          child: Text(
            '暂无镜头可验证',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(Spacing.cardPadding.r),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbMinW = 140.0.w;
          final cols = (constraints.maxWidth / thumbMinW).floor().clamp(3, 8);
          final thumbW =
              (constraints.maxWidth - (cols - 1) * Spacing.sm.w) / cols;

          return Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: shots.map((shot) {
              final sid = shot.id!;
              final imgState = imgStates[sid];
              final isApproved = uiState.proofApproved.contains(sid);
              final isRevision = uiState.proofNeedsRevision.contains(sid);

              return SizedBox(
                width: thumbW,
                child: _ProofThumbnail(
                  shotNumber: shot.sortIndex + 1,
                  imageUrl: imgState?.imageUrl ?? shot.imageUrl,
                  status: imgState?.status ?? ShotImageStatus.notStarted,
                  isApproved: isApproved,
                  isRevision: isRevision,
                  onApprove: () => ref
                      .read(shotImageCenterUiProvider.notifier)
                      .markProofApproved(sid),
                  onRevision: () => ref
                      .read(shotImageCenterUiProvider.notifier)
                      .markProofNeedsRevision(sid),
                  onGenerate: () => ref
                      .read(shotImageStatesProvider.notifier)
                      .proofGenerate([sid]),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: Spacing.sm.w),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xxs.h,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return MouseRegion(
      cursor:
          onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: onTap != null ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.r, color: color),
              SizedBox(width: Spacing.xs.w),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单个快速验证缩略图
class _ProofThumbnail extends StatefulWidget {
  final int shotNumber;
  final String imageUrl;
  final ShotImageStatus status;
  final bool isApproved;
  final bool isRevision;
  final VoidCallback onApprove;
  final VoidCallback onRevision;
  final VoidCallback onGenerate;

  const _ProofThumbnail({
    required this.shotNumber,
    required this.imageUrl,
    required this.status,
    required this.isApproved,
    required this.isRevision,
    required this.onApprove,
    required this.onRevision,
    required this.onGenerate,
  });

  @override
  State<_ProofThumbnail> createState() => _ProofThumbnailState();
}

class _ProofThumbnailState extends State<_ProofThumbnail> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl.isNotEmpty &&
        widget.status == ShotImageStatus.completed;
    final isGenerating = widget.status == ShotImageStatus.generating;

    Color borderColor = AppColors.border;
    if (widget.isApproved) {
      borderColor = AppColors.success.withValues(alpha: 0.6);
    } else if (widget.isRevision) {
      borderColor = AppColors.error.withValues(alpha: 0.6);
    } else if (_hovered) {
      borderColor = AppColors.warning.withValues(alpha: 0.5);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: MotionTokens.durationFast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r - 1),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 底层图片或占位
                if (hasImage)
                  AppNetworkImage(
                    url: resolveFileUrl(widget.imageUrl),
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: AppColors.surfaceContainerHigh,
                    child: Center(
                      child: isGenerating
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.warning.withValues(alpha: 0.6),
                              ),
                            )
                          : Icon(
                              AppIcons.image,
                              size: 20.r,
                              color: AppColors.mutedDarker,
                            ),
                    ),
                  ),

                // 镜头编号
                Positioned(
                  left: 4.w,
                  top: 4.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                    ),
                    child: Text(
                      '#${widget.shotNumber}',
                      style: AppTextStyles.labelTiny.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // 验证状态角标
                if (widget.isApproved)
                  _statusCorner(AppIcons.check, AppColors.success),
                if (widget.isRevision)
                  _statusCorner(AppIcons.warning, AppColors.error),

                // hover 操作遮罩（已有图：通过 / 需调整 / 重新生成）
                if (_hovered && hasImage)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.55),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _hoverBtn(
                            AppIcons.check,
                            AppColors.success,
                            widget.onApprove,
                          ),
                          SizedBox(width: Spacing.sm.w),
                          _hoverBtn(
                            AppIcons.warning,
                            AppColors.error,
                            widget.onRevision,
                          ),
                          SizedBox(width: Spacing.sm.w),
                          _hoverBtn(
                            AppIcons.refresh,
                            AppColors.warning,
                            widget.onGenerate,
                          ),
                        ],
                      ),
                    ),
                  ),

                // 未生成时的快速生成按钮
                if (_hovered &&
                    !hasImage &&
                    !isGenerating)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.45),
                      child: Center(
                        child: _hoverBtn(
                          AppIcons.bolt,
                          AppColors.warning,
                          widget.onGenerate,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCorner(IconData icon, Color color) {
    return Positioned(
      right: 4.w,
      top: 4.h,
      child: Container(
        padding: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 10.r, color: Colors.white),
      ),
    );
  }

  Widget _hoverBtn(IconData icon, Color color, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 16.r, color: color),
        ),
      ),
    );
  }
}
