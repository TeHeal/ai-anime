import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// AI 建议面板：显示 AI 生成结果，支持编辑、替换、追加
class BlockAiSuggestionPanel extends StatelessWidget {
  const BlockAiSuggestionPanel({
    super.key,
    required this.accent,
    required this.aiSuggestion,
    required this.aiOriginalContent,
    required this.aiLoading,
    required this.aiSuggestionCtrl,
    required this.showOriginalDiff,
    required this.onToggleDiff,
    required this.onDiscard,
    required this.onAcceptReplace,
    required this.onAcceptAppend,
  });

  final Color accent;
  final String? aiSuggestion;
  final String? aiOriginalContent;
  final bool aiLoading;
  final TextEditingController? aiSuggestionCtrl;
  final bool showOriginalDiff;
  final VoidCallback onToggleDiff;
  final VoidCallback onDiscard;
  final VoidCallback onAcceptReplace;
  final VoidCallback onAcceptAppend;

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          if (showOriginalDiff && aiOriginalContent != null)
            _buildOriginalDiff(),
          const SizedBox(height: 8),
          _buildContent(),
          const SizedBox(height: 10),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(AppIcons.autoAwesome, size: 14, color: accent),
        const SizedBox(width: 6),
        Text(
          aiLoading ? 'AI 生成中…' : 'AI 建议（可直接编辑）',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
        if (aiLoading) ...[
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
        if (aiOriginalContent != null && aiOriginalContent!.isNotEmpty)
          GestureDetector(
            onTap: onToggleDiff,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  showOriginalDiff
                      ? Icons.unfold_less
                      : Icons.compare_arrows,
                  size: 14,
                  color: accent.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  showOriginalDiff ? '收起原文' : '对比原文',
                  style: TextStyle(
                    fontSize: 11,
                    color: accent.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOriginalDiff() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
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
              aiOriginalContent!.isEmpty ? '（空）' : aiOriginalContent!,
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
    );
  }

  Widget _buildContent() {
    if (aiLoading) {
      return SelectableText(
        aiSuggestion ?? '',
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFFE4E4E7),
        ),
      );
    }
    return TextField(
      controller: aiSuggestionCtrl,
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
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onDiscard,
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
        if (!aiLoading &&
            (aiSuggestionCtrl?.text.isNotEmpty ?? false)) ...[
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: onAcceptAppend,
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
            onPressed: onAcceptReplace,
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
    );
  }
}
