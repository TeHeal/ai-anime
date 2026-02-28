import 'dart:async';

import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/ai_action.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/creation_assistant_pill_button.dart';
import 'package:anime_ui/module/script/block_ai_suggestion.dart';
import 'package:anime_ui/module/script/block_type_config.dart';

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

  // ── AI 建议状态 ──

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

  // ── build ──

  @override
  Widget build(BuildContext context) {
    final accent = accentColorFor(widget.block.type);
    final showExtra = showCharacterFields(widget.block.type);
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
            if (_aiSuggestion != null)
              BlockAiSuggestionPanel(
                accent: accent,
                aiSuggestion: _aiSuggestion,
                aiOriginalContent: _aiOriginalContent,
                aiLoading: _aiLoading,
                aiSuggestionCtrl: _aiSuggestionCtrl,
                showOriginalDiff: _showOriginalDiff,
                onToggleDiff: () =>
                    setState(() => _showOriginalDiff = !_showOriginalDiff),
                onDiscard: discardAiSuggestion,
                onAcceptReplace: _acceptAiReplace,
                onAcceptAppend: _acceptAiAppend,
              ),
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
          TypeDropdown(
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
            child: CompactField(
              label: '角色',
              controller: _characterCtrl,
              onChanged: (_) => _notify(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CompactField(
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
        maxLength: maxBlockChars,
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
          hintText: hintForBlockType(widget.block.type),
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
            '$_charCount/$maxBlockChars',
            style: TextStyle(
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: _charCount > maxBlockChars
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
                ToolIconButton(
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
}
