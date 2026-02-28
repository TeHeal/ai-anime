import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// 角色变体编辑对话框
class VariantEditorDialog extends StatefulWidget {
  const VariantEditorDialog({
    super.key,
    this.initialLabel,
    this.initialAppearance,
    this.initialEpisodeId,
    this.initialSceneId,
    required this.onSave,
    this.title = '新增变体',
  });

  final String? initialLabel;
  final String? initialAppearance;
  final int? initialEpisodeId;
  final String? initialSceneId;
  final String title;
  final void Function({
    required String label,
    String? appearance,
    int? episodeId,
    String? sceneId,
  }) onSave;

  @override
  State<VariantEditorDialog> createState() => _VariantEditorDialogState();
}

class _VariantEditorDialogState extends State<VariantEditorDialog> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _appearanceCtrl;
  late final TextEditingController _episodeCtrl;
  late final TextEditingController _sceneCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.initialLabel ?? '');
    _appearanceCtrl = TextEditingController(text: widget.initialAppearance ?? '');
    _episodeCtrl = TextEditingController(
        text: widget.initialEpisodeId != null ? '${widget.initialEpisodeId}' : '');
    _sceneCtrl = TextEditingController(text: widget.initialSceneId ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _appearanceCtrl.dispose();
    _episodeCtrl.dispose();
    _sceneCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor('变体名称，如"白袍形态"'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _appearanceCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecor('变体外貌描述'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _episodeCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecor('首次出现集数'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _sceneCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecor('场景编号，如 5-3'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消', style: TextStyle(color: Colors.grey[400])),
        ),
        FilledButton.icon(
          onPressed: _labelCtrl.text.trim().isEmpty
              ? null
              : () {
                  widget.onSave(
                    label: _labelCtrl.text.trim(),
                    appearance: _appearanceCtrl.text.trim().isNotEmpty
                        ? _appearanceCtrl.text.trim()
                        : null,
                    episodeId: int.tryParse(_episodeCtrl.text.trim()),
                    sceneId: _sceneCtrl.text.trim().isNotEmpty
                        ? _sceneCtrl.text.trim()
                        : null,
                  );
                  Navigator.pop(context);
                },
          icon: const Icon(AppIcons.check, size: 16),
          label: const Text('保存'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
        ),
      ],
    );
  }
}
