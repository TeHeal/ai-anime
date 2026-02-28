import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/shot_images/page/review_ui_provider.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/services/api.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/theme/text.dart';
import 'review_edit_toolbar.dart';
import 'review_script_reference.dart';

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

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '镜头 #${widget.shot.sortIndex + 1}',
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 10),
              _modeToggle(uiState, uiNotifier),
              const Spacer(),
              _toolButton(
                icon: AppIcons.formatQuote,
                label: '提示词',
                active: _promptOverlay,
                onTap: () => setState(() => _promptOverlay = !_promptOverlay),
              ),
              const SizedBox(width: 6),
              _toolButton(
                icon: _expanded ? AppIcons.expandLess : AppIcons.expandMore,
                label: _expanded ? '收起' : '放大',
                active: _expanded,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: idx > 0 ? () => _navigateShot(-1) : null,
                icon: const Icon(AppIcons.chevronLeft, size: 14),
                label: const Text('上一镜'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  textStyle: AppTextStyles.caption,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: idx < widget.allShots.length - 1
                    ? () => _navigateShot(1)
                    : null,
                icon: const Icon(AppIcons.chevronRight, size: 14),
                label: const Text('下一镜'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildImagePreview(imageUrl),
          const SizedBox(height: 12),
          _buildCandidateGallery(imageUrl),
          const SizedBox(height: 16),
          ReviewScriptReference(shot: widget.shot),
          if (uiState.editMode) ...[
            const SizedBox(height: 16),
            ReviewEditToolbar(
              initialPrompt: widget.shot.prompt,
              onGenerate: () => _toast('重新生成功能开发中'),
              onRestore: () => _toast('已恢复'),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.grey[800]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: active ? AppColors.primary : Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.tiny.copyWith(
                  color: active ? AppColors.primary : Colors.grey[500],
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
      constraints: BoxConstraints(maxHeight: _expanded ? 700 : 500),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, e, s) => _imagePlaceholder(),
                    ),
                  )
                : _imagePlaceholder(),
          ),
          if (_promptOverlay && widget.shot.prompt.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Text(
                    widget.shot.prompt,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Text(
                '候选 ${_selectedCandidate + 1}',
                style: AppTextStyles.tiny.copyWith(
                  color: Colors.white,
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
    final candidates = <String>[
      if (mainImageUrl.isNotEmpty) mainImageUrl,
    ];

    if (candidates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.gallery, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              '候选图 (${candidates.length})',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: candidates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isActive = i == _selectedCandidate;
              return GestureDetector(
                onTap: () => setState(() => _selectedCandidate = i),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.border,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isActive ? 6 : 7),
                      child: Image.network(
                        candidates[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, s) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: Icon(
                            AppIcons.image,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
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
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.image, size: 48, color: Colors.grey[700]),
            const SizedBox(height: 12),
            Text(
              '镜图尚未生成',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
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
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[800]!),
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
            Icon(
              icon,
              size: 12,
              color: active ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.tiny.copyWith(
                color: active ? AppColors.primary : Colors.grey[600],
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
