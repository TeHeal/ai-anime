import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/ai_action.dart';
import 'creation_assistant_pill_button.dart';
import 'tiny_btn.dart';

/// 反向提示词输入区块，含创作助理 + 提示词库按钮。
class NegPromptField extends StatelessWidget {
  const NegPromptField({
    super.key,
    required this.controller,
    required this.hint,
    required this.accent,
    this.label,
    this.onLibraryTap,
    this.onAssistantAction,
    this.onSaveToLibrary,
  });

  final TextEditingController controller;
  final String hint;
  final Color accent;
  final String? label;
  final VoidCallback? onLibraryTap;
  final void Function(AiAction)? onAssistantAction;
  final VoidCallback? onSaveToLibrary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label ?? '反向提示词（选填）',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            if (onAssistantAction != null || onLibraryTap != null || onSaveToLibrary != null) ...[
              const Spacer(),
              if (onAssistantAction != null)
                CreationAssistantPillButton<AiAction>(
                  itemBuilder: (_) => AiAction.values
                      .map((a) => PopupMenuItem<AiAction>(
                            value: a,
                            height: 36,
                            child: Row(
                              children: [
                                Icon(aiActionIcons[a],
                                    size: 15, color: accent),
                                const SizedBox(width: 8),
                                Text(aiActionLabels[a]!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFE4E4E7))),
                              ],
                            ),
                          ))
                      .toList(),
                  onSelected: onAssistantAction!,
                ),
              if (onLibraryTap != null) ...[
                const SizedBox(width: 6),
                TinyBtn(
                  icon: AppIcons.document,
                  label: '提示词库',
                  accent: accent,
                  onTap: onLibraryTap!,
                ),
              ],
            ],
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          clipBehavior: Clip.none,
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13, color: Colors.white),
              maxLines: 2,
              decoration: onSaveToLibrary != null
                  ? _defaultDeco(hint).copyWith(
                      contentPadding: const EdgeInsets.only(
                        left: 12,
                        top: 10,
                        right: 70,
                        bottom: 36,
                      ),
                    )
                  : _defaultDeco(hint),
            ),
            if (onSaveToLibrary != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: TinyBtn(
                  icon: AppIcons.save,
                  label: '入库',
                  accent: accent,
                  onTap: onSaveToLibrary!,
                ),
              ),
          ],
        ),
      ],
    );
  }

  InputDecoration _defaultDeco(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent),
      ),
    );
  }
}
