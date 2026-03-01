import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

class SideNavItem {
  final String key;
  final String label;
  final IconData icon;
  final String? section;

  const SideNavItem({
    required this.key,
    required this.label,
    required this.icon,
    this.section,
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
    SideNavItem(key: '/story', label: '剧本', icon: AppIcons.book, section: '创作'),
    SideNavItem(key: '/assets', label: '资产', icon: AppIcons.people, section: '创作'),
    SideNavItem(key: '/script', label: '脚本', icon: AppIcons.storyboard),
    SideNavItem(key: '/shot-images', label: '镜图', icon: AppIcons.gallery, section: '生产'),
    SideNavItem(key: '/shots', label: '镜头', icon: AppIcons.generate),
    SideNavItem(key: '/episode', label: '成片', icon: AppIcons.clipEdit),
    SideNavItem(key: '/tasks', label: '任务', icon: AppIcons.bolt, section: '管理'),
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceContainer,
            AppColors.background,
          ],
          stops: [0.0, 1.0],
        ),
        border: Border(
          right: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: Spacing.sm.h),
          for (int i = 0; i < SideNav.items.length; i++) ...[
            if (!_collapsed && _shouldShowSection(i))
              _buildSectionLabel(SideNav.items[i].section!),
            _buildNavItem(SideNav.items[i]),
          ],
          const Spacer(),
          _buildCollapseButton(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg.w,
              vertical: Spacing.sm.h,
            ),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          _buildAiButton(),
          SizedBox(height: Spacing.md.h),
        ],
      ),
    );
  }

  bool _shouldShowSection(int index) {
    final item = SideNav.items[index];
    if (item.section == null) return false;
    if (index == 0) return true;
    return SideNav.items[index - 1].section != item.section;
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        (Spacing.sm + Spacing.md).w,
        Spacing.md.h,
        Spacing.sm.w,
        Spacing.xs.h,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: AppTextStyles.labelTinySmall.copyWith(
            color: AppColors.mutedDarker,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
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
          hoverColor: AppColors.primary.withValues(alpha: 0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _collapsed ? 0 : Spacing.md.w,
              vertical: Spacing.buttonPaddingV.h,
            ),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.primary.withValues(alpha: 0.06),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              border: isActive
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
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
                                              ? FontWeight.w700
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
    if (isActive) {
      return Container(
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: Icon(
          item.icon,
          size: 20.r,
          color: AppColors.primary,
        ),
      );
    }

    return Icon(
      item.icon,
      size: 20.r,
      color: AppColors.onSurface.withValues(alpha: 0.5),
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
              gradient: widget.aiActive
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.info.withValues(alpha: 0.1),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              border: widget.aiActive
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: _collapsed
                ? Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.primary, AppColors.info],
                      ).createShader(bounds),
                      child: Icon(
                        AppIcons.autoAwesome,
                        size: Spacing.xl.r,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.info],
                        ).createShader(bounds),
                        child: Icon(
                          AppIcons.autoAwesome,
                          size: Spacing.xl.r,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: Spacing.iconGapMd.w),
                      Text(
                        'AI 助手',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: widget.aiActive
                              ? AppColors.primary
                              : AppColors.onSurface.withValues(alpha: 0.6),
                          fontWeight: widget.aiActive
                              ? FontWeight.w700
                              : FontWeight.w500,
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
