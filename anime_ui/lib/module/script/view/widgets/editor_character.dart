import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/view/review_ui_provider.dart';
import 'package:anime_ui/module/script/view/widgets/editor_common.dart';
import 'package:anime_ui/module/script/view/widgets/emotion_vector_widget.dart';

// ---------------------------------------------------------------------------
// 3. 角色卡片 & 4. 情绪卡片
// ---------------------------------------------------------------------------

Widget buildCharacterCard(ShotV4 shot, bool editing,
    List<Character> characters, ReviewUiNotifier notifier) {
  final matchedChar = characters
      .where((c) =>
          c.name == shot.characterName ||
          (shot.characterId.isNotEmpty &&
              c.id?.toString() == shot.characterId))
      .firstOrNull;
  final hasWarning = shot.characterName.isNotEmpty &&
      matchedChar == null &&
      characters.isNotEmpty;

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: hasWarning ? Colors.orange.withValues(alpha: 0.5) : Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reviewSectionHeader('3. 角色',
            trailing: hasWarning
                ? Tooltip(
                    message: '角色未在资产栏中找到',
                    child: Icon(AppIcons.warning,
                        size: 14, color: Colors.orange))
                : null),
        Divider(height: 1, color: Colors.grey[800]),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 角色头像
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF252540),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: matchedChar != null && matchedChar.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(matchedChar.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                AppIcons.person,
                                size: 20,
                                color: Colors.grey[600])),
                      )
                    : Icon(AppIcons.person,
                        size: 20, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: editing
                    ? _buildCharacterEdit(shot, characters, notifier)
                    : _buildCharacterPreview(shot, matchedChar),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCharacterEdit(
    ShotV4 shot, List<Character> characters, ReviewUiNotifier notifier) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (characters.isNotEmpty)
        DropdownButtonFormField<String>(
          initialValue: characters.any((c) => c.name == shot.characterName)
              ? shot.characterName
              : null,
          decoration: const InputDecoration(
            isDense: true,
            labelText: '角色',
            labelStyle: TextStyle(fontSize: 12),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(),
          ),
          dropdownColor: Colors.grey[900],
          items: [
            const DropdownMenuItem(
                value: '', child: Text('无', style: TextStyle(fontSize: 12))),
            ...characters.map((c) => DropdownMenuItem(
                  value: c.name,
                  child: Text(c.name, style: const TextStyle(fontSize: 12)),
                )),
          ],
          onChanged: (v) {
            final char =
                characters.where((c) => c.name == v).firstOrNull;
            notifier.updateCurrentShot((s) => s.copyWith(
                  characterName: v ?? '',
                  characterId: char?.id?.toString() ?? '',
                ));
          },
        )
      else
        editField('角色', shot.characterName,
            onChanged: (v) =>
                notifier.updateCurrentShot((s) => s.copyWith(characterName: v))),
      const SizedBox(height: 8),
      editField('角色ID', shot.characterId,
          onChanged: (v) =>
              notifier.updateCurrentShot((s) => s.copyWith(characterId: v))),
    ],
  );
}

Widget _buildCharacterPreview(ShotV4 shot, Character? matchedChar) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        shot.characterName.isNotEmpty ? shot.characterName : '未指定角色',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: shot.characterName.isNotEmpty
              ? Colors.white
              : Colors.grey[600],
        ),
      ),
      if (shot.characterId.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text('ID: ${shot.characterId}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
      if (matchedChar != null) ...[
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: [
            if (matchedChar.roleType.isNotEmpty)
              _tinyTag(matchedChar.roleType, Colors.blue),
            if (matchedChar.importance.isNotEmpty)
              _tinyTag(matchedChar.importance, Colors.amber),
          ],
        ),
      ],
    ],
  );
}

Widget _tinyTag(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w500)),
  );
}

// ---------------------------------------------------------------------------
// 4. 情绪卡片
// ---------------------------------------------------------------------------

Widget buildEmotionCard(
    ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  final hasVector = shot.emotionVector.isNotEmpty;
  final hasDesc = shot.emotionDescription.isNotEmpty;
  if (!hasVector && !hasDesc && !editing) return const SizedBox.shrink();

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reviewSectionHeader('4. 情绪'),
        Divider(height: 1, color: Colors.grey[800]),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              editing
                  ? editField('情绪描述', shot.emotionDescription,
                      fullWidth: true,
                      onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(emotionDescription: v)))
                  : readField('情绪描述', shot.emotionDescription,
                      fullWidth: true),
              if (hasVector || editing) ...[
                const SizedBox(height: 12),
                Text('情绪向量 (IndexTTS2)',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 8),
                EmotionVectorWidget(
                  vector: shot.emotionVector,
                  editing: editing,
                  onChanged: (newVec) {
                    notifier.updateCurrentShot((s) {
                      s.emotionVector = newVec;
                      return s;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
