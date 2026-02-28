import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 内容块类型选项
const typeOptions = <String, String>{
  'action': '动作描写',
  'dialogue': '台词',
  'os': 'OS旁白',
  'direction': '场景指示',
  'closeup': '特写',
};

/// 内容块最大字符数
const maxBlockChars = 300;

/// 根据块类型返回对应的主题色
Color accentColorFor(String type) {
  switch (type) {
    case 'dialogue':
      return const Color(0xFF8B5CF6);
    case 'os':
      return const Color(0xFF3B82F6);
    case 'direction':
      return const Color(0xFFF59E0B);
    case 'closeup':
      return const Color(0xFFEF4444);
    case 'action':
    default:
      return const Color(0xFF22C55E);
  }
}

/// 是否显示角色/情绪字段
bool showCharacterFields(String type) => type == 'dialogue' || type == 'os';

/// 根据块类型返回占位提示文本
String hintForBlockType(String type) {
  switch (type) {
    case 'dialogue':
      return '输入台词内容…';
    case 'os':
      return '输入旁白内容…';
    case 'direction':
      return '输入场景指示…';
    case 'closeup':
      return '输入特写描述…';
    case 'action':
    default:
      return '输入动作描写…';
  }
}

/// 块类型下拉选择器
class TypeDropdown extends StatelessWidget {
  const TypeDropdown({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = accentColorFor(value);
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: typeOptions.containsKey(value) ? value : 'action',
          isDense: true,
          dropdownColor: const Color(0xFF1E1E2E),
          style: const TextStyle(fontSize: 12, color: Color(0xFFE4E4E7)),
          icon: Icon(
            AppIcons.expandMore,
            size: 14,
            color: accent.withValues(alpha: 0.7),
          ),
          items: typeOptions.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: accentColorFor(e.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(e.value, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// 工具栏图标按钮
class ToolIconButton extends StatelessWidget {
  const ToolIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 15),
      color: const Color(0xFF6B7280),
      hoverColor: const Color(0xFF2A2A3C),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

/// 紧凑文本输入框
class CompactField extends StatelessWidget {
  const CompactField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: Color(0xFFE4E4E7)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFF0F0F17),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF232336), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF232336), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1),
        ),
      ),
    );
  }
}
