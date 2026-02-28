import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/prop.dart';

/// 道具编辑对话框
class PropEditDialog extends StatefulWidget {
  const PropEditDialog({
    super.key,
    required this.title,
    this.initial,
    required this.onSave,
  });

  final String title;
  final Prop? initial;
  final void Function(Prop) onSave;

  @override
  State<PropEditDialog> createState() => _PropEditDialogState();
}

class _PropEditDialogState extends State<PropEditDialog> {
  late final TextEditingController _name;
  late final TextEditingController _appearance;
  late bool _isKeyProp;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _appearance = TextEditingController(text: widget.initial?.appearance ?? '');
    _isKeyProp = widget.initial?.isKeyProp ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _appearance.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) return;
    final prop = (widget.initial ?? const Prop()).copyWith(
      name: _name.text.trim(),
      appearance: _appearance.text.trim(),
      isKeyProp: _isKeyProp,
    );
    widget.onSave(prop);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('道具名称', _name, required: true),
            _field('外观描述', _appearance, maxLines: 3),
            const SizedBox(height: 4),
            SwitchListTile(
              title: Text('关键道具',
                  style: TextStyle(color: Colors.grey[300], fontSize: 13)),
              subtitle: Text('标记为关键道具会在总览中优先提示',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              value: _isKeyProp,
              onChanged: (v) => setState(() => _isKeyProp = v),
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消', style: TextStyle(color: Colors.grey[400])),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(widget.initial != null ? '保存' : '创建'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller,
      {String? hint, int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700], fontSize: 13),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
