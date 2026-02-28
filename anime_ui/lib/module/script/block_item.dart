import 'dart:async';

import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/ai_action.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/creation_assistant_pill_button.dart';

const _typeOptions = <String, String>{
  'action': '动作描写',
  'dialogue': '台词',
  'os': 'OS旁白',
  'direction': '场景指示',
  'closeup': '特写',
};

const _maxChars = 300;

Color _accentColorFor(String type) {
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

bool _showCharacterFields(String type) => type == 'dialogue' || type == 'os';

/// 场景内容块编辑项
class BlockItem extends StatefulWidget {
  const BlockItem({
    super.key,
    required this.block,
    required this.index,
    required this.onChanged,
    required this.onDelete,
    this.onAiAction,
  });

  final SceneBlock block;
  final int index;
  final ValueChanged<SceneBlock> onChanged;
  final VoidCallback onDelete;
  final void Function(AiAction action, int blockIndex)? onAiAction;

  @override
  BlockItemState createState() => BlockItemState();
}

class BlockItemState extends State<BlockItem> {
  late final TextEditingController _contentCtrl;
  late final TextEditingController _characterCtrl;
  late final TextEditingController _emotionCtrl;
  bool _hovered = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.block.content);
    _characterCtrl = TextEditingController(text: widget.block.character);
    _emotionCtrl = TextEditingController(text: widget.block.emotion);
    _charCount = _contentCtrl.text.length;
  }

  @override
  void didUpdateWidget(covariant BlockItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content &&
        widget.block.content != _contentCtrl.text) {
      _contentCtrl.text = widget.block.content;
      _charCount = _contentCtrl.text.length;
    }
    if (oldWidget.block.character != widget.block.character &&
        widget.block.character != _characterCtrl.text) {
      _characterCtrl.text = widget.block.character;
    }
    if (oldWidget.block.emotion != widget.block.emotion &&
        widget.block.emotion != _emotionCtrl.text) {
      _emotionCtrl.text = widget.block.emotion;
    }
  }

  @override
  void dispose() {
    _aiSub?.cancel();
    _aiSuggestionCtrl?.dispose();
    _contentCtrl.dispose();
    _characterCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(widget.block.copyWith(
      content: _contentCtrl.text,
      character: _characterCtrl.text,
      emotion: _emotionCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColorFor(widget.block.type);
    final showExtra = _showCharacterFields(widget.block.type);
    final seqNum = (widget.index + 1).toString().padLeft(2, '0');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFF1E1E2E)
              : const Color(0xFF181825),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? accent.withValues(alpha: 0.3)
                : const Color(0xFF2A2A3C),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(accent, seqNum),
            if (showExtra) _buildCharacterRow(),
            _buildContentArea(accent),
            _buildFooter(accent),
            if (_aiSuggestion != null) _buildAiSuggestion(accent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accent, String seqNum) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 0),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Icon(
                  AppIcons.dragHandle,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              seqNum,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: accent.withValues(alpha: 0.7),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 4),
          _TypeDropdown(
            value: widget.block.type,
            onChanged: (v) =>
                widget.onChanged(widget.block.copyWith(type: v)),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _hovered ? 1.0 : 0.0,
            child: IconButton(
              icon: const Icon(AppIcons.close, size: 14),
              color: const Color(0xFF6B7280),
              tooltip: '删除',
              onPressed: widget.onDelete,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 6, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _CompactField(
              label: '角色',
              controller: _characterCtrl,
              onChanged: (_) => _notify(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CompactField(
              label: '情绪',
              controller: _emotionCtrl,
              onChanged: (_) => _notify(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 8, 12, 0),
      child: TextField(
        controller: _contentCtrl,
        onChanged: (v) {
          setState(() => _charCount = v.length);
          _notify();
        },
        maxLines: null,
        minLines: 2,
        maxLength: _maxChars,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
            null,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: const Color(0xFFE4E4E7),
          fontStyle: widget.block.type == 'action'
              ? FontStyle.italic
              : FontStyle.normal,
        ),
        decoration: InputDecoration(
          hintText: _hintFor(widget.block.type),
          hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF0F0F17),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF232336), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: accent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 4, 12, 8),
      child: Row(
        children: [
          Text(
            '$_charCount/$_maxChars',
            style: TextStyle(
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: _charCount > _maxChars
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF4B5563),
            ),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _hovered ? 1.0 : 0.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onAiAction != null)
                  CreationAssistantPillButton<AiAction>(
                    itemBuilder: (_) => AiAction.values
                        .map((a) => PopupMenuItem<AiAction>(
                              value: a,
                              height: 36,
                              child: Row(
                                children: [
                                  Icon(
                                    aiActionIcons[a],
                                    size: 15,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    aiActionLabels[a]!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFE4E4E7),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onSelected: (a) => widget.onAiAction!(a, widget.index),
                  ),
                const SizedBox(width: 6),
                _ToolIconButton(
                  icon: AppIcons.delete,
                  tooltip: '删除段落',
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _aiSuggestion;
  String? _aiOriginalContent;
  bool _aiLoading = false;
  StreamSubscription<String>? _aiSub;
  TextEditingController? _aiSuggestionCtrl;
  bool _showOriginalDiff = false;

  void startAiStream(Stream<String> stream) {
    _aiOriginalContent = _contentCtrl.text;
    _aiSuggestionCtrl?.dispose();
    _aiSuggestionCtrl = TextEditingController();
    setState(() {
      _aiSuggestion = '';
      _aiLoading = true;
      _showOriginalDiff = false;
    });
    _aiSub?.cancel();
    _aiSub = stream.listen(
      (chunk) {
        if (!mounted) return;
        setState(() {
          _aiSuggestion = (_aiSuggestion ?? '') + chunk;
          _aiSuggestionCtrl?.text = _aiSuggestion!;
        });
      },
      onDone: () {
        if (mounted) setState(() => _aiLoading = false);
      },
      onError: (_) {
        if (mounted) setState(() => _aiLoading = false);
      },
    );
  }

  void _acceptAiReplace() {
    final text = _aiSuggestionCtrl?.text ?? _aiSuggestion;
    if (text == null || text.isEmpty) return;
    _contentCtrl.text = text;
    _charCount = _contentCtrl.text.length;
    _notify();
    _dismissAi();
  }

  void _acceptAiAppend() {
    final text = _aiSuggestionCtrl?.text ?? _aiSuggestion;
    if (text == null || text.isEmpty) return;
    final current = _contentCtrl.text;
    final separator = current.isNotEmpty && !current.endsWith('\n') ? '\n' : '';
    _contentCtrl.text = '$current$separator$text';
    _charCount = _contentCtrl.text.length;
    _notify();
    _dismissAi();
  }

  void discardAiSuggestion() {
    _aiSub?.cancel();
    _dismissAi();
  }

  void _dismissAi() {
    _aiSub?.cancel();
    _aiSuggestionCtrl?.dispose();
    _aiSuggestionCtrl = null;
    setState(() {
      _aiSuggestion = null;
      _aiOriginalContent = null;
      _aiLoading = false;
      _showOriginalDiff = false;
    });
  }

  Widget _buildAiSuggestion(Color accent) {
    return Container(
      margin: const EdgeInsets.fromLTRB(44, 4, 12, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.autoAwesome, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                _aiLoading ? 'AI 生成中…' : 'AI 建议（可直接编辑）',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              if (_aiLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: accent,
                  ),
                ),
              ],
              const Spacer(),
              if (_aiOriginalContent != null && _aiOriginalContent!.isNotEmpty)
                GestureDetector(
                  onTap: () =>
                      setState(() => _showOriginalDiff = !_showOriginalDiff),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showOriginalDiff
                            ? Icons.unfold_less
                            : Icons.compare_arrows,
                        size: 14,
                        color: accent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showOriginalDiff ? '收起原文' : '对比原文',
                        style: TextStyle(
                          fontSize: 11,
                          color: accent.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_showOriginalDiff && _aiOriginalContent != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F17),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF2A2A3C).withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '原文',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _aiOriginalContent!.isEmpty ? '（空）' : _aiOriginalContent!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (_aiLoading)
            SelectableText(
              _aiSuggestion ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFFE4E4E7),
              ),
            )
          else
            TextField(
              controller: _aiSuggestionCtrl,
              maxLines: null,
              minLines: 2,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFFE4E4E7),
              ),
              decoration: InputDecoration(
                hintText: '编辑 AI 建议内容…',
                hintStyle: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFF0F0F17),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: discardAiSuggestion,
                icon: const Icon(AppIcons.close, size: 14),
                label: const Text('放弃'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9CA3AF),
                  textStyle: const TextStyle(fontSize: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
              ),
              if (!_aiLoading &&
                  (_aiSuggestionCtrl?.text.isNotEmpty ?? false)) ...[
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: _acceptAiAppend,
                  icon: const Icon(AppIcons.add, size: 14),
                  label: const Text('追加到末尾'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent.withValues(alpha: 0.8),
                    side: BorderSide(color: accent.withValues(alpha: 0.3)),
                    textStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
                const SizedBox(width: 6),
                FilledButton.icon(
                  onPressed: _acceptAiReplace,
                  icon: const Icon(AppIcons.check, size: 14),
                  label: const Text('替换原文'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _hintFor(String type) {
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
}

// ---------------------------------------------------------------------------
// 类型下拉
// ---------------------------------------------------------------------------

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColorFor(value);
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
          value: _typeOptions.containsKey(value) ? value : 'action',
          isDense: true,
          dropdownColor: const Color(0xFF1E1E2E),
          style: const TextStyle(fontSize: 12, color: Color(0xFFE4E4E7)),
          icon: Icon(
            AppIcons.expandMore,
            size: 14,
            color: accent.withValues(alpha: 0.7),
          ),
          items: _typeOptions.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _accentColorFor(e.key),
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

// ---------------------------------------------------------------------------
// 工具图标按钮
// ---------------------------------------------------------------------------

class _ToolIconButton extends StatelessWidget {
  const _ToolIconButton({
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

// ---------------------------------------------------------------------------
// 紧凑输入框
// ---------------------------------------------------------------------------

class _CompactField extends StatelessWidget {
  const _CompactField({
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
