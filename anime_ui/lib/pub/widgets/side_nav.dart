import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

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
  });

  final String currentObject;
  final void Function(String objectPath) onObjectTap;
  final Set<String> disabledObjects;
  final Map<String, String> disabledHints;
  final VoidCallback? onAiTap;
  final bool aiActive;

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
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: _collapsed ? 64 : 180,
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (final item in SideNav.items) _buildNavItem(item),
          const Spacer(),
          _buildCollapseButton(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06)),
          ),
          _buildAiButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavItem(SideNavItem item) {
    final isActive = widget.currentObject == item.key;
    final isDisabled = widget.disabledObjects.contains(item.key);
    final hint = widget.disabledHints[item.key];

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => widget.onObjectTap(item.key),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.primary
                                      : const Color(0xFF9CA3AF),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isDisabled) ...[
                              const SizedBox(width: 6),
                              Icon(AppIcons.lock,
                                  size: 12, color: Colors.grey[600]),
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
      size: 20,
      color: isActive ? AppColors.primary : const Color(0xFF6B7280),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => setState(() => _collapsed = !_collapsed),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            _collapsed ? AppIcons.chevronRight : AppIcons.chevronLeft,
            size: 16,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildAiButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: widget.onAiTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: widget.aiActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: widget.aiActive
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: _collapsed
                ? Center(
                    child: Icon(Icons.auto_awesome,
                        size: 20, color: AppColors.primary),
                  )
                : Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        'AI 助手',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: widget.aiActive
                              ? AppColors.primary
                              : const Color(0xFF9CA3AF),
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
