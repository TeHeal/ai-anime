import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

class ObjectTab {
  final String label;
  final String routePath;
  final IconData? icon;

  const ObjectTab({required this.label, required this.routePath, this.icon});
}

class ObjectTabBar extends StatelessWidget {
  const ObjectTabBar({
    super.key,
    required this.tabs,
    required this.currentRoute,
    required this.onTabTap,
    this.title,
    this.trailing,
    this.disabledRoutes = const {},
    this.labelOverrides = const {},
  });

  final List<ObjectTab> tabs;
  final String currentRoute;
  final void Function(String routePath) onTabTap;
  final String? title;
  final Widget? trailing;

  /// Routes that should be shown as disabled (greyed out, not tappable).
  final Set<String> disabledRoutes;

  /// Override labels for specific routes (e.g. "编辑" → "查看" when locked).
  final Map<String, String> labelOverrides;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Spacing.barHeight.h,
      padding: EdgeInsets.symmetric(horizontal: Spacing.mid.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: AppColors.onSurface.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.bodyXLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(width: Spacing.xl.w),
          ],
          for (var i = 0; i < tabs.length; i++) ...[
            _buildTab(tabs[i]),
            if (i < tabs.length - 1) SizedBox(width: Spacing.xs.w),
          ],
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }

  Widget _buildTab(ObjectTab tab) {
    final isActive =
        currentRoute == tab.routePath ||
        currentRoute.startsWith('${tab.routePath}/');
    final isDisabled = disabledRoutes.contains(tab.routePath);
    final displayLabel = labelOverrides[tab.routePath] ?? tab.label;

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isDisabled ? null : () => onTabTap(tab.routePath),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.gridGap.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive && !isDisabled
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2.w,
              ),
            ),
          ),
          child: Opacity(
            opacity: isDisabled ? 0.35 : 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tab.icon != null) ...[
                  Icon(
                    tab.icon,
                    size: 16.r,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                  SizedBox(width: Spacing.iconGapSm.w),
                ],
                Text(
                  displayLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.onSurface
                        : AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
