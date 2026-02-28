import 'package:flutter/material.dart';

import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

// Block type colors
const blockColors = {
  'action': Color(0xFF22C55E),
  'dialogue': Color(0xFF3B82F6),
  'os': Color(0xFF8B5CF6),
  'closeup': Color(0xFFF97316),
  'direction': Color(0xFFEAB308),
  'unknown': Color(0xFF6B7280),
};

const blockLabels = {
  'action': '动作',
  'dialogue': '对白',
  'os': '旁白',
  'closeup': '特写',
  'direction': '导演',
  'unknown': '未知',
};

class PreviewBlockItem extends StatefulWidget {
  final ParsedBlock block;
  final VoidCallback? onChanged;

  const PreviewBlockItem({
    super.key,
    required this.block,
    this.onChanged,
  });

  @override
  State<PreviewBlockItem> createState() => _PreviewBlockItemState();
}

class _PreviewBlockItemState extends State<PreviewBlockItem> {
  bool _editing = false;
  late TextEditingController _contentCtrl;
  late TextEditingController _charCtrl;
  late TextEditingController _emotionCtrl;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.block.content);
    _charCtrl = TextEditingController(text: widget.block.character);
    _emotionCtrl = TextEditingController(text: widget.block.emotion);
  }

  @override
  void didUpdateWidget(covariant PreviewBlockItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block != widget.block) {
      _contentCtrl.text = widget.block.content;
      _charCtrl.text = widget.block.character;
      _emotionCtrl.text = widget.block.emotion;
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _charCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.block.content = _contentCtrl.text;
    widget.block.character = _charCtrl.text;
    widget.block.emotion = _emotionCtrl.text;
    widget.block.confidence = 1.0;
    setState(() => _editing = false);
    widget.onChanged?.call();
  }

  void _cancel() {
    _contentCtrl.text = widget.block.content;
    _charCtrl.text = widget.block.character;
    _emotionCtrl.text = widget.block.emotion;
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final color = blockColors[block.type] ?? Colors.grey;
    final isLow = block.isLowConfidence;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLow
              ? Colors.orange.withValues(alpha: 0.6)
              : Colors.grey[800]!,
          width: isLow ? 2 : 1,
        ),
        color: isLow
            ? Colors.orange.withValues(alpha: 0.05)
            : AppColors.surface.withValues(alpha: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            constraints: const BoxConstraints(minHeight: 40),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: type dropdown + character + emotion + actions
                  Row(
                    children: [
                      PreviewTypeDropdown(
                        value: block.type,
                        onChanged: (v) {
                          setState(() {
                            block.type = v;
                            if (v != 'unknown') block.confidence = 1.0;
                          });
                          widget.onChanged?.call();
                        },
                      ),
                      if (_editing) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _charCtrl,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '角色',
                              hintStyle:
                                  TextStyle(fontSize: 11, color: Colors.grey[600]),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: _emotionCtrl,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '情绪',
                              hintStyle:
                                  TextStyle(fontSize: 11, color: Colors.grey[600]),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                      ] else ...[
                        if (block.character.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            block.character,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                        if (block.emotion.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '（${block.emotion}）',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ],
                      const Spacer(),
                      if (isLow && !_editing)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(AppIcons.warning,
                              size: 14, color: Colors.orange),
                        ),
                      if (_editing) ...[
                        PreviewActionBtn(
                          icon: AppIcons.check,
                          color: Colors.green,
                          tooltip: '保存',
                          onTap: _save,
                        ),
                        const SizedBox(width: 4),
                        PreviewActionBtn(
                          icon: AppIcons.close,
                          color: Colors.grey,
                          tooltip: '取消',
                          onTap: _cancel,
                        ),
                      ] else
                        PreviewActionBtn(
                          icon: AppIcons.editOutline,
                          color: Colors.grey[500]!,
                          tooltip: '编辑',
                          onTap: () => setState(() => _editing = true),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_editing)
                    TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    )
                  else
                    Text(
                      block.content,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const PreviewTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = blockColors[value] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: blockLabels.containsKey(value) ? value : 'unknown',
        items: blockLabels.entries.map((e) {
          final c = blockColors[e.key] ?? Colors.grey;
          return DropdownMenuItem(
            value: e.key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(e.value, style: TextStyle(fontSize: 11, color: c)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        isDense: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}

class PreviewActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const PreviewActionBtn({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
