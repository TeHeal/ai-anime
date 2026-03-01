import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/models/scene.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 场景编辑器导航栏：上一场/下一场
class SceneEditorNavBar extends StatelessWidget {
  const SceneEditorNavBar({
    super.key,
    required this.episode,
    required this.scene,
    required this.hasPrev,
    required this.hasNext,
    required this.onNavigatePrev,
    required this.onNavigateNext,
  });

  final Episode? episode;
  final Scene? scene;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onNavigatePrev;
  final VoidCallback onNavigateNext;

  @override
  Widget build(BuildContext context) {
    final epTitle = episode?.title ?? '—';
    final scLabel = scene != null
        ? '${scene!.sceneId} ${scene!.location.isNotEmpty ? '· ${scene!.location}' : ''}'
        : '—';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _navArrowButton(
            icon: AppIcons.chevronLeft,
            enabled: hasPrev,
            tooltip: '上一场',
            onPressed: onNavigatePrev,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              '$epTitle  ›  $scLabel',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          _navArrowButton(
            icon: AppIcons.chevronRight,
            enabled: hasNext,
            tooltip: '下一场',
            onPressed: onNavigateNext,
          ),
        ],
      ),
    );
  }

  Widget _navArrowButton({
    required IconData icon,
    required bool enabled,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18.r),
      color: AppColors.primary,
      disabledColor: AppColors.divider,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: Spacing.xxl,
        minHeight: Spacing.xxl,
      ),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        ),
      ),
    );
  }
}
