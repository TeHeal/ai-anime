import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'app_search_field.dart';

/// 通用提示词库选择对话框。
///
/// [prompts] 列表中的每个元素需要有 `name` 和 `description` 属性（dynamic）。
/// 选中后通过 [onSelected] 回调返回 description 文本。
class PromptLibraryDialog extends StatefulWidget {
  const PromptLibraryDialog({
    super.key,
    required this.prompts,
    required this.accent,
    required this.onSelected,
  });

  final List prompts;
  final Color accent;
  final ValueChanged<String> onSelected;

  @override
  State<PromptLibraryDialog> createState() => _PromptLibraryDialogState();
}

class _PromptLibraryDialogState extends State<PromptLibraryDialog> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List get _filtered {
    if (_search.isEmpty) return widget.prompts;
    final q = _search.toLowerCase();
    return widget.prompts
        .where((r) =>
            (r.name as String).toLowerCase().contains(q) ||
            (r.description as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Icon(AppIcons.document, size: 18, color: widget.accent),
                  const SizedBox(width: 8),
                  const Text(
                    '选择提示词模板',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:
                        Icon(AppIcons.close, size: 16, color: Colors.grey[500]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchField(
                controller: _searchCtrl,
                hintText: '搜索提示词…',
                width: double.infinity,
                accentColor: widget.accent,
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final r = items[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          widget.onSelected(r.description as String),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              r.description as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
