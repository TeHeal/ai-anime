import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 创作助理药丸按钮：紫色渐变样式，点击展开下拉菜单。
///
/// 用于剧本块、表单等场景，需由调用方提供 [itemBuilder] 和 [onSelected]。
/// 菜单内容（润色/扩写/续写等）由业务方决定。
class CreationAssistantPillButton<T> extends StatelessWidget {
  const CreationAssistantPillButton({
    super.key,
    required this.itemBuilder,
    required this.onSelected,
    this.tooltip = '创作助理',
    this.offset = const Offset(0, 36),
    this.menuColor = const Color(0xFF1A1A2E),
  });

  /// 构建弹出菜单项
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;

  /// 选中某项时的回调
  final ValueChanged<T> onSelected;

  /// 悬停提示
  final String tooltip;

  /// 弹出菜单位置偏移
  final Offset offset;

  /// 菜单背景色
  final Color menuColor;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      tooltip: tooltip,
      offset: offset,
      color: menuColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: itemBuilder,
      child: _PillChild(),
    );
  }
}

/// 药丸外观（渐变 + 图标 + 文案）
class _PillChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.autoAwesome, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '创作助理',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
