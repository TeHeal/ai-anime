import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 场景元信息编辑区域：场景编号、地点、时间、内/外、角色列表
class SceneMetadataSection extends StatelessWidget {
  const SceneMetadataSection({
    super.key,
    required this.sceneIdCtrl,
    required this.locationCtrl,
    required this.characterCtrl,
    required this.time,
    required this.ie,
    required this.characters,
    required this.timeOptions,
    required this.ieOptions,
    required this.onTimeChanged,
    required this.onIeChanged,
    required this.onAddCharacter,
    required this.onRemoveCharacter,
    required this.onFieldChanged,
  });

  final TextEditingController sceneIdCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController characterCtrl;
  final String time;
  final String ie;
  final List<String> characters;
  final List<String> timeOptions;
  final List<String> ieOptions;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onIeChanged;
  final VoidCallback onAddCharacter;
  final ValueChanged<String> onRemoveCharacter;
  final VoidCallback onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '场景信息',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE4E4E7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(width: 100, child: _buildField('场景编号', sceneIdCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildField('地点', locationCtrl)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDropdown('时间', time, timeOptions, onTimeChanged),
            const SizedBox(width: 12),
            _buildDropdown('内/外', ie, ieOptions, onIeChanged),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '角色',
          style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in characters)
              Chip(
                label: Text(
                  c,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFE4E4E7)),
                ),
                backgroundColor: const Color(0xFF2A2A3C),
                deleteIconColor: const Color(0xFF6B7280),
                onDeleted: () => onRemoveCharacter(c),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            SizedBox(
              width: 120,
              height: 32,
              child: TextField(
                controller: characterCtrl,
                onSubmitted: (_) => onAddCharacter(),
                style: const TextStyle(fontSize: 13, color: Color(0xFFE4E4E7)),
                decoration: InputDecoration(
                  hintText: '添加角色…',
                  hintStyle:
                      const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  filled: true,
                  fillColor: const Color(0xFF0F0F17),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(AppIcons.add, size: 16),
                    color: const Color(0xFF8B5CF6),
                    onPressed: onAddCharacter,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => onFieldChanged(),
      style: const TextStyle(fontSize: 14, color: Color(0xFFE4E4E7)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFF0F0F17),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F17),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF232336)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              hint: Text(
                '选择$label',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              isDense: true,
              dropdownColor: const Color(0xFF1E1E2E),
              style: const TextStyle(fontSize: 13, color: Color(0xFFE4E4E7)),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
