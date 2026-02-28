import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/view/review_ui_provider.dart';
import 'package:anime_ui/module/script/view/widgets/editor_common.dart';

// ---------------------------------------------------------------------------
// 2. 画面 & 提示词
// ---------------------------------------------------------------------------

Widget buildScenePromptCard(
    ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reviewSectionHeader('2. 画面 & 提示词'),
        Divider(height: 1, color: Colors.grey[800]),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              editing
                  ? editField('画面描述', shot.sceneDescription,
                      fullWidth: true,
                      maxLines: 3,
                      onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(sceneDescription: v)))
                  : readField('画面描述', shot.sceneDescription,
                      fullWidth: true),
              const SizedBox(height: 10),
              editing
                  ? editField('角色站位', shot.characterPosition,
                      fullWidth: true,
                      onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(characterPosition: v)))
                  : readField('角色站位', shot.characterPosition,
                      fullWidth: true),
            ],
          ),
        ),
        // AI 提示词区域（紫色强调条）
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
              top: BorderSide(color: Colors.grey[800]!),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI 提示词',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                editing
                    ? editField('提示词', shot.aiPrompt,
                        fullWidth: true,
                        maxLines: 4,
                        onChanged: (v) => notifier.updateCurrentShot(
                            (s) => s.copyWith(aiPrompt: v)))
                    : _promptBlock(shot.aiPrompt),
                const SizedBox(height: 10),
                editing
                    ? editField('反向提示词', shot.negativePrompt,
                        fullWidth: true,
                        labelColor: Colors.red[300],
                        onChanged: (v) => notifier.updateCurrentShot(
                            (s) => s.copyWith(negativePrompt: v)))
                    : _negativeBlock(shot.negativePrompt),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _promptBlock(String text) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(6),
      border:
          Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: SelectableText(
      text.isNotEmpty ? text : '—',
      style: TextStyle(
        fontSize: 13,
        color: text.isNotEmpty ? Colors.grey[300] : Colors.grey[600],
        fontFamily: 'monospace',
        height: 1.5,
      ),
    ),
  );
}

Widget _negativeBlock(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('反向提示词',
            style: TextStyle(fontSize: 10, color: Colors.red[300])),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text.isNotEmpty ? text : '—',
          style: TextStyle(
            fontSize: 12,
            color: text.isNotEmpty ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    ],
  );
}
