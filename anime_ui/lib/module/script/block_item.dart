import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/ai_action.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/creation_assistant_pill_button.dart';
import 'package:anime_ui/module/script/widgets/block_item_theme.dart';
import 'package:anime_ui/module/script/widgets/block_item_widgets.dart';
import 'package:anime_ui/module/script/widgets/block_item_ai_suggestion.dart';

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
    widget.onChanged(
      widget.block.copyWith(
        content: _contentCtrl.text,
        character: _characterCtrl.text,
        emotion: _emotionCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = blockItemAccentColorFor(widget.block.type);
    final showExtra = blockItemShowCharacterFields(widget.block.type);
    final seqNum = (widget.index + 1).toString().padLeft(2, '0');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: Spacing.xs),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.surfaceContainerHigh
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
          border: Border.all(
            color: _hovered ? accent.withValues(alpha: 0.3) : AppColors.divider,
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
      padding: const EdgeInsets.fromLTRB(Spacing.xs, Spacing.sm, Spacing.sm, 0),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs,
                  vertical: Spacing.xs,
                ),
                child: Icon(
                  AppIcons.dragHandle,
                  size: 16.r,
                  color: AppColors.onSurface.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              seqNum,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w700,
                color: accent.withValues(alpha: 0.7),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          BlockItemTypeDropdown(
            value: widget.block.type,
            onChanged: (v) => widget.onChanged(widget.block.copyWith(type: v)),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _hovered ? 1.0 : 0.0,
            child: BlockItemToolIconButton(
              icon: AppIcons.close,
              tooltip: '删除',
              onPressed: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.blockIndent,
        Spacing.sm,
        Spacing.md,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: BlockItemCompactField(
              label: '角色',
              controller: _characterCtrl,
              onChanged: (_) => _notify(),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: BlockItemCompactField(
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
      padding: const EdgeInsets.fromLTRB(
        Spacing.blockIndent,
        Spacing.sm,
        Spacing.md,
        0,
      ),
      child: TextField(
        controller: _contentCtrl,
        onChanged: (v) {
          setState(() => _charCount = v.length);
          _notify();
        },
        maxLines: null,
        minLines: 2,
        maxLength: blockItemMaxChars,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        style: AppTextStyles.bodyMedium.copyWith(
          height: 1.6,
          color: AppColors.onSurface,
          fontStyle: widget.block.type == 'action'
              ? FontStyle.italic
              : FontStyle.normal,
        ),
        decoration: InputDecoration(
          hintText: blockItemHintFor(widget.block.type),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mutedDarkest,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(
              color: AppColors.inputBorder,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
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
      padding: const EdgeInsets.fromLTRB(
        Spacing.blockIndent,
        Spacing.xs,
        Spacing.md,
        Spacing.sm,
      ),
      child: Row(
        children: [
          Text(
            '$_charCount/$blockItemMaxChars',
            style: AppTextStyles.tiny.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: _charCount > blockItemMaxChars
                  ? AppColors.error
                  : AppColors.mutedDarkest,
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
                        .map(
                          (a) => PopupMenuItem<AiAction>(
                            value: a,
                            height: 36,
                            child: Row(
                              children: [
                                Icon(
                                  aiActionIcons[a],
                                  size: 15.r,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: Spacing.sm),
                                Text(
                                  aiActionLabels[a]!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onSelected: (a) => widget.onAiAction!(a, widget.index),
                  ),
                const SizedBox(width: Spacing.sm),
                BlockItemToolIconButton(
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
    return BlockItemAiSuggestion(
      accent: accent,
      suggestion: _aiSuggestion,
      isLoading: _aiLoading,
      originalContent: _aiOriginalContent,
      showOriginalDiff: _showOriginalDiff,
      controller: _aiSuggestionCtrl,
      onToggleDiff: () =>
          setState(() => _showOriginalDiff = !_showOriginalDiff),
      onDiscard: discardAiSuggestion,
      onAcceptReplace: _acceptAiReplace,
      onAcceptAppend: _acceptAiAppend,
    );
  }
}
