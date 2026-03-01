import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

class SideNavItem {
  final String key;
  final String label;
  final IconData icon;

  const SideNavItem({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class SideNav extends StatefulWidget {
  const SideNav({
    super.key,
    required this.currentObject,
    required this.onObjectTap,
    this.disabledObjects = const {},
    this.disabledHints = const {},
    this.onAiTap,
    this.aiActive = false,
    this.initialCollapsed = false,
    this.onCollapsedChanged,
  });

  final String currentObject;
  final void Function(String objectPath) onObjectTap;
  final Set<String> disabledObjects;
  final Map<String, String> disabledHints;
  final VoidCallback? onAiTap;
  final bool aiActive;

  /// 窄屏时初始折叠（由 MainLayout 根据 Breakpoints 传入）
  final bool initialCollapsed;

  /// 折叠状态变化时回调（用于 MainLayout 调整 AI 面板位置等）
  final ValueChanged<bool>? onCollapsedChanged;

  static const items = [
    SideNavItem(key: '/story', label: '剧本', icon: AppIcons.book),
    SideNavItem(key: '/assets', label: '资产', icon: AppIcons.people),
    SideNavItem(key: '/script', label: '脚本', icon: AppIcons.storyboard),
    SideNavItem(key: '/shot-images', label: '镜图', icon: AppIcons.gallery),
    SideNavItem(key: '/shots', label: '镜头', icon: AppIcons.generate),
    SideNavItem(key: '/episode', label: '成片', icon: AppIcons.clipEdit),
    SideNavItem(key: '/tasks', label: '任务', icon: AppIcons.bolt),
  ];

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initialCollapsed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCollapsedChanged?.call(_collapsed);
    });
  }

  @override
  void didUpdateWidget(SideNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCollapsed != widget.initialCollapsed) {
      setState(() => _collapsed = widget.initialCollapsed);
      widget.onCollapsedChanged?.call(_collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: _collapsed ? 64.w : 180.w,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(right: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          SizedBox(height: Spacing.sm.h),
          for (final item in SideNav.items) _buildNavItem(item),
          const Spacer(),
          _buildCollapseButton(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg.w,
              vertical: Spacing.sm.h,
            ),
            child: const Divider(height: 1, color: AppColors.divider),
          ),
          _buildAiButton(),
          SizedBox(height: Spacing.md.h),
        ],
      ),
    );
  }

  Widget _buildNavItem(SideNavItem item) {
    final isActive = widget.currentObject == item.key;
    final isDisabled = widget.disabledObjects.contains(item.key);
    final hint = widget.disabledHints[item.key];

    Widget content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: (Spacing.xs / 2).h,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        child: InkWell(
          onTap: () => widget.onObjectTap(item.key),
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _collapsed ? 0 : Spacing.md.w,
              vertical: Spacing.buttonPaddingV.h,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              border: isActive
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: _collapsed
                ? Center(child: _buildIcon(item, isActive))
                : Row(
                    children: [
                      _buildIcon(item, isActive),
                      SizedBox(width: Spacing.iconGapMd.w),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                style:
                                    (isActive
                                            ? AppTextStyles.labelLarge
                                            : AppTextStyles.labelLarge)
                                        .copyWith(
                                          fontWeight: isActive
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isActive
                                              ? AppColors.primary
                                              : AppColors.onSurface.withValues(
                                                  alpha: 0.6,
                                                ),
                                        ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isDisabled) ...[
                              SizedBox(width: Spacing.iconGapSm.w),
                              Icon(
                                AppIcons.lock,
                                size: 12.r,
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (isDisabled && hint != null && !_collapsed) {
      content = Tooltip(message: hint, child: content);
    } else if (_collapsed) {
      content = Tooltip(message: item.label, child: content);
    }
    return Opacity(opacity: isDisabled ? 0.55 : 1.0, child: content);
  }

  Widget _buildIcon(SideNavItem item, bool isActive) {
    return Icon(
      item.icon,
      size: 20.r,
      color: isActive
          ? AppColors.primary
          : AppColors.onSurface.withValues(alpha: 0.5),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
      child: InkWell(
        onTap: () {
          setState(() => _collapsed = !_collapsed);
          widget.onCollapsedChanged?.call(_collapsed);
        },
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        child: Padding(
          padding: EdgeInsets.all(Spacing.sm.r),
          child: Icon(
            _collapsed ? AppIcons.chevronRight : AppIcons.chevronLeft,
            size: 16.r,
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAiButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        child: InkWell(
          onTap: widget.onAiTap,
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _collapsed ? 0 : Spacing.md.w,
              vertical: Spacing.buttonPaddingV.h,
            ),
            decoration: BoxDecoration(
              color: widget.aiActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              border: widget.aiActive
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: _collapsed
                ? Center(
                    child: Icon(
                      AppIcons.autoAwesome,
                      size: Spacing.xl.r,
                      color: AppColors.primary,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        AppIcons.autoAwesome,
                        size: Spacing.xl.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: Spacing.iconGapMd.w),
                      Text(
                        'AI 助手',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: widget.aiActive
                              ? AppColors.primary
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
