import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shot_images/providers/review_ui.dart';
import 'package:anime_ui/module/shot_images/page/widgets/review_script_ref.dart';
import 'package:anime_ui/module/shot_images/page/widgets/review_edit_toolbar.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/app_network_image.dart';

/// 镜图审核中心面板：图片预览 + 候选图 + 脚本对照
class ReviewCenterPanel extends ConsumerStatefulWidget {
  final StoryboardShot shot;
  final List<StoryboardShot> allShots;

  const ReviewCenterPanel({
    super.key,
    required this.shot,
    required this.allShots,
  });

  @override
  ConsumerState<ReviewCenterPanel> createState() => _ReviewCenterPanelState();
}

class _ReviewCenterPanelState extends ConsumerState<ReviewCenterPanel> {
  int _selectedCandidate = 0;
  bool _promptOverlay = false;
  bool _expanded = false;

  void _navigateShot(int delta) {
    if (widget.allShots.isEmpty) return;
    final idx = widget.allShots.indexWhere((s) => s.id == widget.shot.id);
    final newIdx = (idx + delta).clamp(0, widget.allShots.length - 1);
    ref
        .read(shotImageReviewUiProvider.notifier)
        .setSelectedShotId(widget.allShots[newIdx].id);
  }

  @override
  void didUpdateWidget(covariant ReviewCenterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shot.id != widget.shot.id) {
      _selectedCandidate = 0;
      _promptOverlay = false;
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(shotImageReviewUiProvider);
    final uiNotifier = ref.read(shotImageReviewUiProvider.notifier);

    final idx = widget.allShots.indexWhere((s) => s.id == widget.shot.id);
    final rawUrl = widget.shot.imageUrl;
    final imageUrl = rawUrl.isNotEmpty ? resolveFileUrl(rawUrl) : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '镜头 #${widget.shot.sortIndex + 1}',
                style: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(width: Spacing.sm.w),
              _modeToggle(uiState, uiNotifier),
              const Spacer(),
              _toolButton(
                icon: AppIcons.formatQuote,
                label: '提示词',
                active: _promptOverlay,
                onTap: () => setState(() => _promptOverlay = !_promptOverlay),
              ),
              SizedBox(width: Spacing.sm.w),
              _toolButton(
                icon: _expanded ? AppIcons.expandLess : AppIcons.expandMore,
                label: _expanded ? '收起' : '放大',
                active: _expanded,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
              SizedBox(width: Spacing.md.w),
              OutlinedButton.icon(
                onPressed: idx > 0 ? () => _navigateShot(-1) : null,
                icon: Icon(AppIcons.chevronLeft, size: 14.r),
                label: const Text('上一镜'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.chipPaddingH.w,
                    vertical: Spacing.iconGapSm.h,
                  ),
                  textStyle: AppTextStyles.caption,
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              OutlinedButton.icon(
                onPressed: idx < widget.allShots.length - 1
                    ? () => _navigateShot(1)
                    : null,
                icon: Icon(AppIcons.chevronRight, size: 14.r),
                label: const Text('下一镜'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.chipPaddingH.w,
                    vertical: Spacing.iconGapSm.h,
                  ),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.mid.h),
          _buildImagePreview(imageUrl),
          SizedBox(height: Spacing.md.h),
          _buildCandidateGallery(imageUrl),
          SizedBox(height: Spacing.lg.h),
          ReviewScriptRef(shot: widget.shot),
          if (uiState.editMode) ...[
            SizedBox(height: Spacing.lg.h),
            ReviewEditToolbar(
              shot: widget.shot,
              onToast: (msg) => showToast(context, msg),
            ),
          ],
        ],
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.surfaceContainer,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12.r,
                color: active ? AppColors.primary : AppColors.mutedDark,
              ),
              SizedBox(width: Spacing.xs.w),
              Text(
                label,
                style: AppTextStyles.tiny.copyWith(
                  color: active ? AppColors.primary : AppColors.mutedDark,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      constraints: BoxConstraints(maxHeight: _expanded ? 700.h : 500.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                    child: AppNetworkImage(url: imageUrl, fit: BoxFit.contain),
                  )
                : _imagePlaceholder(),
          ),
          if (_promptOverlay && widget.shot.prompt.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(RadiusTokens.xl.r),
                  bottomRight: Radius.circular(RadiusTokens.xl.r),
                ),
                child: Container(
                  padding: EdgeInsets.all(Spacing.lg.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.shadowOverlay.withValues(alpha: 0.85),
                        AppColors.shadowOverlay.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Text(
                    widget.shot.prompt,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          Positioned(
            left: Spacing.md.w,
            top: Spacing.md.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.shadowOverlay.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
                border: Border.all(
                  color: AppColors.onSurface.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Text(
                '候选 ${_selectedCandidate + 1}',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateGallery(String mainImageUrl) {
    final candidates = <String>[if (mainImageUrl.isNotEmpty) mainImageUrl];

    if (candidates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.gallery, size: 14.r, color: AppColors.muted),
            SizedBox(width: Spacing.sm.w),
            Text(
              '候选图 (${candidates.length})',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.mutedLight,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        SizedBox(
          height: 72.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: candidates.length,
            separatorBuilder: (context, index) => SizedBox(width: Spacing.sm.w),
            itemBuilder: (context, i) {
              final isActive = i == _selectedCandidate;
              return GestureDetector(
                onTap: () => setState(() => _selectedCandidate = i),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                      border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.border,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8.r,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        isActive ? RadiusTokens.sm.r : RadiusTokens.md.r,
                      ),
                      child: AppNetworkImage(
                        url: candidates[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.image, size: 48.r, color: AppColors.surfaceMuted),
            SizedBox(height: Spacing.md.h),
            Text(
              '镜图尚未生成',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDarker,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeToggle(
    ShotImageReviewUiState uiState,
    ShotImageReviewUiNotifier uiNotifier,
  ) {
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
            uiState.editMode,
            () => uiNotifier.setEditMode(true),
          ),
          _modeBtn(
            '预览',
            AppIcons.lockOutline,
            !uiState.editMode,
            () => uiNotifier.setEditMode(false),
          ),
        ],
      ),
    );
  }

  Widget _modeBtn(
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12.r,
              color: active ? AppColors.primary : AppColors.mutedDarker,
            ),
            SizedBox(width: Spacing.xs.w),
            Text(
              label,
              style: AppTextStyles.tiny.copyWith(
                color: active ? AppColors.primary : AppColors.mutedDarker,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
