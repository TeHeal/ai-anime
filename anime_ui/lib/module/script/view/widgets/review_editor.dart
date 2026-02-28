import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/assets/characters/providers/characters_provider.dart';
import 'package:anime_ui/module/script/view/review_ui_provider.dart';
import 'package:anime_ui/module/script/view/widgets/emotion_vector_widget.dart';

// ---------------------------------------------------------------------------
// 中栏：编辑器
// ---------------------------------------------------------------------------

class ReviewEditor extends ConsumerWidget {
  final ShotV4 shot;
  final List<ShotV4> allShots;

  const ReviewEditor({
    super.key,
    required this.shot,
    required this.allShots,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(reviewUiProvider);
    final uiNotifier = ref.read(reviewUiProvider.notifier);
    final idx = allShots.indexWhere((s) => s.shotNumber == shot.shotNumber);
    final editing = reviewIsEditMode(uiState, shot);
    final characters = ref.watch(assetCharactersProvider).value ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题 + 模式切换 + 导航
          _buildEditorHeader(shot, allShots, idx, editing, uiNotifier),
          const SizedBox(height: 20),

          // 1. 基础信息
          _section('1. 基础信息', _buildBasicInfo(shot, editing, uiNotifier)),
          const SizedBox(height: 12),

          // 2. 画面 & 提示词
          _buildScenePromptCard(shot, editing, uiNotifier),
          const SizedBox(height: 12),

          // 3. 角色
          _buildCharacterCard(shot, editing, characters, uiNotifier),
          const SizedBox(height: 12),

          // 4. 情绪
          _buildEmotionCard(shot, editing, uiNotifier),
          const SizedBox(height: 12),

          // 5. 音频（可折叠，含台词 + 音频设计）
          _buildCollapsibleCard(
            title: '5. 音频',
            icon: AppIcons.music,
            expanded: uiState.audioExpanded,
            onToggle: uiNotifier.toggleAudioExpanded,
            badge: _audioBadge(shot),
            child: _buildAudioContent(shot, editing, uiNotifier),
          ),
          const SizedBox(height: 12),

          // 6. 图像（可折叠）
          _buildCollapsibleCard(
            title: '6. 图像',
            icon: AppIcons.image,
            expanded: uiState.imageExpanded,
            onToggle: uiNotifier.toggleImageExpanded,
            badge: shot.image?.enabled == true ? _enabledDot() : null,
            child: _buildImageFull(shot, editing),
          ),
          const SizedBox(height: 12),

          // 7. 视频（可折叠）
          _buildCollapsibleCard(
            title: '7. 视频',
            icon: AppIcons.video,
            expanded: uiState.videoExpanded,
            onToggle: uiNotifier.toggleVideoExpanded,
            badge: shot.video?.enabled == true ? _enabledDot() : null,
            child: _buildVideoFull(shot, editing),
          ),

          // 8. 备注
          if (shot.notes.isNotEmpty || editing) ...[
            const SizedBox(height: 12),
            _section(
              '8. 备注',
              editing
                  ? _editField('', shot.notes,
                      fullWidth: true,
                      onChanged: (v) =>
                          uiNotifier.updateCurrentShot((s) => s.copyWith(notes: v)))
                  : _readField('', shot.notes, fullWidth: true),
            ),
          ],
        ],
      ),
    );
  }
}

// =========================================================================
// 编辑器顶栏
// =========================================================================

Widget _buildEditorHeader(ShotV4 shot, List<ShotV4> allShots, int idx,
    bool editing, ReviewUiNotifier uiNotifier) {
  return Row(
    children: [
      Text('镜头 #${shot.shotNumber}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
      const SizedBox(width: 10),
      _priorityBadge(shot.priority),
      const SizedBox(width: 12),
      _modeToggle(editing, uiNotifier),
      const Spacer(),
      OutlinedButton.icon(
        onPressed: idx > 0 ? () => uiNotifier.navigateShot(-1) : null,
        icon: const Icon(AppIcons.chevronLeft, size: 14),
        label: const Text('上一镜'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed:
            idx < allShots.length - 1 ? () => uiNotifier.navigateShot(1) : null,
        icon: const Icon(AppIcons.chevronRight, size: 14),
        label: const Text('下一镜'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}

Widget _modeToggle(bool editing, ReviewUiNotifier notifier) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF252540),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _modeBtn('编辑', AppIcons.edit, editing,
            () => notifier.setEditMode(true)),
        _modeBtn('预览', AppIcons.lockOutline, !editing,
            () => notifier.setEditMode(false)),
      ],
    ),
  );
}

Widget _modeBtn(
    String label, IconData icon, bool active, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: active ? AppColors.primary : Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: active ? AppColors.primary : Colors.grey[600],
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    ),
  );
}

// =========================================================================
// 1. 基础信息
// =========================================================================

Widget _buildBasicInfo(
    ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  return LayoutBuilder(builder: (context, constraints) {
    final cols = constraints.maxWidth > 600 ? 4 : 3;
    final w = (constraints.maxWidth - 12 * (cols - 1)) / cols;

    final fields = <Widget>[
      SizedBox(width: w, child: _readChip('镜号', '${shot.shotNumber}')),
      SizedBox(
        width: w,
        child: editing
            ? _durationStepper(shot, notifier)
            : _readChip('时长', '${shot.duration}s'),
      ),
      SizedBox(
        width: w,
        child: editing
            ? _dropdown('景别', shot.cameraScale,
                ControlledVocabulary().cameraScales,
                onChanged: (v) => notifier
                    .updateCurrentShot((s) => s.copyWith(cameraScale: v)))
            : _readChip('景别', shot.cameraScale),
      ),
      SizedBox(
        width: w,
        child: editing
            ? _editField('运镜', shot.cameraMovement,
                onChanged: (v) => notifier.updateCurrentShot(
                    (s) => s.copyWith(cameraMovement: v)))
            : _readChip('运镜', shot.cameraMovement),
      ),
      SizedBox(
        width: w,
        child: editing
            ? _dropdown('转场', shot.transition,
                ControlledVocabulary().transitions,
                onChanged: (v) =>
                    notifier.updateCurrentShot((s) => s.copyWith(transition: v)))
            : _readChip('转场', shot.transition),
      ),
      SizedBox(
        width: w,
        child: editing
            ? _dropdown('优先级', shot.priority,
                ControlledVocabulary().priorities,
                onChanged: (v) =>
                    notifier.updateCurrentShot((s) => s.copyWith(priority: v)))
            : _readChip('优先级', shot.priority),
      ),
      if (shot.timeline != null) ...[
        SizedBox(
            width: w,
            child: _readChip('开始', '${shot.timeline!.start}s')),
        SizedBox(
            width: w,
            child: _readChip('结束', '${shot.timeline!.end}s')),
      ],
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: fields);
  });
}

Widget _durationStepper(ShotV4 shot, ReviewUiNotifier notifier) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('时长', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF252535),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                if (shot.duration > 0.5) {
                  notifier.updateCurrentShot(
                      (s) => s.copyWith(duration: s.duration - 0.5));
                }
              },
              child: Icon(AppIcons.chevronLeft,
                  size: 14, color: Colors.grey[400]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${shot.duration}s',
                  style: const TextStyle(fontSize: 13, color: Colors.white)),
            ),
            InkWell(
              onTap: () => notifier.updateCurrentShot(
                  (s) => s.copyWith(duration: s.duration + 0.5)),
              child: Icon(AppIcons.chevronRight,
                  size: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    ],
  );
}

// =========================================================================
// 2. 画面 & 提示词
// =========================================================================

Widget _buildScenePromptCard(
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
        _sectionHeader('2. 画面 & 提示词'),
        Divider(height: 1, color: Colors.grey[800]),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              editing
                  ? _editField('画面描述', shot.sceneDescription,
                      fullWidth: true,
                      maxLines: 3,
                      onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(sceneDescription: v)))
                  : _readField('画面描述', shot.sceneDescription,
                      fullWidth: true),
              const SizedBox(height: 10),
              editing
                  ? _editField('角色站位', shot.characterPosition,
                      fullWidth: true,
                      onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(characterPosition: v)))
                  : _readField('角色站位', shot.characterPosition,
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
                    ? _editField('提示词', shot.aiPrompt,
                        fullWidth: true,
                        maxLines: 4,
                        onChanged: (v) => notifier.updateCurrentShot(
                            (s) => s.copyWith(aiPrompt: v)))
                    : _promptBlock(shot.aiPrompt),
                const SizedBox(height: 10),
                editing
                    ? _editField('反向提示词', shot.negativePrompt,
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

// =========================================================================
// 3. 角色卡片
// =========================================================================

Widget _buildCharacterCard(ShotV4 shot, bool editing,
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
        _sectionHeader('3. 角色',
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
        _editField('角色', shot.characterName,
            onChanged: (v) =>
                notifier.updateCurrentShot((s) => s.copyWith(characterName: v))),
      const SizedBox(height: 8),
      _editField('角色ID', shot.characterId,
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

// =========================================================================
// 4. 情绪卡片
// =========================================================================

Widget _buildEmotionCard(
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
        _sectionHeader('4. 情绪'),
        Divider(height: 1, color: Colors.grey[800]),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              editing
                  ? _editField('情绪描述', shot.emotionDescription,
                      fullWidth: true,
                      onChanged: (v) => notifier.updateCurrentShot(
                          (s) => s.copyWith(emotionDescription: v)))
                  : _readField('情绪描述', shot.emotionDescription,
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

// =========================================================================
// 5-7. 可折叠卡片
// =========================================================================

Widget _buildCollapsibleCard({
  required String title,
  required IconData icon,
  required bool expanded,
  required VoidCallback onToggle,
  Widget? badge,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius:
              BorderRadius.vertical(top: const Radius.circular(10)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  badge,
                ],
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(AppIcons.expandMore,
                      size: 16, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(
            children: [
              Divider(height: 1, color: Colors.grey[800]),
              Padding(padding: const EdgeInsets.all(16), child: child),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    ),
  );
}

Widget? _audioBadge(ShotV4 shot) {
  final count = shot.audio?.enabledCount ?? 0;
  if (count == 0) return null;
  return _countBadge(count);
}

// ── 音频内容（含台词 + 音频设计） ──

Widget _buildAudioContent(
    ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  final audio = shot.audio;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 台词
      if (shot.dialogue.isNotEmpty || editing) ...[
        editing
            ? _editField('台词', shot.dialogue,
                fullWidth: true,
                maxLines: 2,
                onChanged: (v) =>
                    notifier.updateCurrentShot((s) => s.copyWith(dialogue: v)))
            : _dialogueBubble(shot.dialogue),
        const SizedBox(height: 10),
      ],
      // 音频设计
      if (shot.audioDesignText.isNotEmpty || editing) ...[
        editing
            ? _editField('音频设计', shot.audioDesignText,
                fullWidth: true,
                onChanged: (v) {
                  notifier.updateCurrentShot((s) {
                    s.audioDesignText = v;
                    return s;
                  });
                })
            : _readField('音频设计', shot.audioDesignText, fullWidth: true),
        const SizedBox(height: 10),
      ],
      if (audio == null)
        Text('无音频配置',
            style: TextStyle(color: Colors.grey[600], fontSize: 13))
      else ...[
        _audioCard('VO (对白)', audio.vo?.enabled ?? false, [
          ('类型', audio.vo?.type ?? '—'),
          ('台词', audio.vo?.text ?? '—'),
          ('角色ID', audio.vo?.characterId ?? '—'),
          ('情绪', audio.vo?.emotion ?? '—'),
          ('音量', '${audio.vo?.volume ?? 0.8}'),
          ('优先级', audio.vo?.priority ?? '—'),
        ]),
        const SizedBox(height: 8),
        _audioCard('BGM', audio.bgm?.enabled ?? false, [
          ('类型', audio.bgm?.type ?? '—'),
          ('提示词', audio.bgm?.prompt ?? '—'),
          ('风格', audio.bgm?.style ?? '—'),
          ('情绪', audio.bgm?.emotion ?? '—'),
          ('强度', '${audio.bgm?.intensity ?? 0.6}'),
          ('淡入', '${audio.bgm?.fadeIn ?? 0.5}s'),
          ('淡出', '${audio.bgm?.fadeOut ?? 0.5}s'),
        ]),
        const SizedBox(height: 8),
        _audioCard('拟声', audio.foley?.enabled ?? false, [
          ('类型', audio.foley?.type ?? '—'),
          ('提示词', audio.foley?.prompt ?? '—'),
          ('描述', audio.foley?.description ?? '—'),
          ('触发时间', '${audio.foley?.triggerTime ?? 0}s'),
          ('音量', '${audio.foley?.volume ?? 0.7}'),
          ('优先级', audio.foley?.priority ?? '—'),
        ]),
        const SizedBox(height: 8),
        _audioCard('动态音效', audio.dynamic_?.enabled ?? false, [
          ('类型', audio.dynamic_?.type ?? '—'),
          ('提示词', audio.dynamic_?.prompt ?? '—'),
          ('描述', audio.dynamic_?.description ?? '—'),
          ('触发时间', '${audio.dynamic_?.triggerTime ?? 0}s'),
          ('音量', '${audio.dynamic_?.volume ?? 0.6}'),
        ]),
        const SizedBox(height: 8),
        _audioCard('氛围音效', audio.ambient?.enabled ?? false, [
          ('类型', audio.ambient?.type ?? '—'),
          ('提示词', audio.ambient?.prompt ?? '—'),
          ('描述', audio.ambient?.description ?? '—'),
          ('强度', '${audio.ambient?.intensity ?? 0.4}'),
          ('循环', audio.ambient?.loop == true ? '是' : '否'),
        ]),
      ],
    ],
  );
}

Widget _dialogueBubble(String text) {
  if (text.isEmpty) return const SizedBox.shrink();
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border:
          Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.formatQuote,
            size: 14, color: AppColors.primary.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13, color: Colors.white, height: 1.4)),
        ),
      ],
    ),
  );
}

Widget _audioCard(
    String title, bool enabled, List<(String, String)> fields) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF252540),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
          color: enabled
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(enabled ? AppIcons.check : AppIcons.circleOutline,
                  size: 14,
                  color: enabled ? Colors.green : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.white : Colors.grey[500])),
            ],
          ),
        ),
        if (enabled) ...[
          Divider(height: 1, color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: fields.map((f) {
                final isLong = f.$2.length > 30;
                return SizedBox(
                  width: isLong ? double.infinity : 120,
                  child: _miniField(f.$1, f.$2),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    ),
  );
}

// ── 图像完整展示 ──

Widget _buildImageFull(ShotV4 shot, bool editing) {
  final img = shot.image;
  if (img == null || !img.enabled) {
    return Text('未启用',
        style: TextStyle(color: Colors.grey[600], fontSize: 13));
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(spacing: 12, runSpacing: 10, children: [
        _readField('类型', img.type),
        _readField('风格', img.style),
        _readField('分辨率', img.resolution),
        _readField('宽高比', img.aspectRatio),
        _readField('优先级', img.priority),
      ]),
      const SizedBox(height: 10),
      _readField('提示词', img.prompt, fullWidth: true),
      const SizedBox(height: 10),
      _readField('反向提示词', img.negativePrompt, fullWidth: true),
      if (img.overlay != null) ...[
        const SizedBox(height: 12),
        _overlayCard('叠加特效', img.overlay!),
      ],
    ],
  );
}

// ── 视频完整展示 ──

Widget _buildVideoFull(ShotV4 shot, bool editing) {
  final vid = shot.video;
  if (vid == null || !vid.enabled) {
    return Text('未启用',
        style: TextStyle(color: Colors.grey[600], fontSize: 13));
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(spacing: 12, runSpacing: 10, children: [
        _readField('类型', vid.type),
        _readField('帧率', '${vid.frameRate}fps'),
        _readField('运镜', vid.cameraMovement),
        _readField('转场', vid.transition),
        _readField('优先级', vid.priority),
      ]),
      const SizedBox(height: 10),
      _readField('提示词', vid.prompt, fullWidth: true),
      const SizedBox(height: 10),
      _readField('反向提示词', vid.negativePrompt, fullWidth: true),
      if (vid.dependsOn.isNotEmpty) ...[
        const SizedBox(height: 10),
        _readField('依赖', vid.dependsOn.join(', '), fullWidth: true),
      ],
      if (vid.overlay != null) ...[
        const SizedBox(height: 12),
        _overlayCard('叠加特效', vid.overlay!),
      ],
      if (vid.lipSync != null) ...[
        const SizedBox(height: 12),
        _lipSyncCard(vid.lipSync!),
      ],
    ],
  );
}

Widget _overlayCard(String title, OverlayEffect overlay) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF252540),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                  overlay.enabled ? AppIcons.check : AppIcons.circleOutline,
                  size: 14,
                  color:
                      overlay.enabled ? Colors.green : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: overlay.enabled
                          ? Colors.white
                          : Colors.grey[500])),
            ],
          ),
        ),
        if (overlay.enabled) ...[
          Divider(height: 1, color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 12, runSpacing: 8, children: [
              _miniField('类型', overlay.type),
              SizedBox(
                  width: double.infinity,
                  child: _miniField('提示词', overlay.prompt)),
              SizedBox(
                  width: double.infinity,
                  child: _miniField('反向提示词', overlay.negativePrompt)),
              _miniField('优先级', overlay.priority),
            ]),
          ),
        ],
      ],
    ),
  );
}

Widget _lipSyncCard(LipSyncConfig lipSync) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF252540),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                  lipSync.enabled
                      ? AppIcons.check
                      : AppIcons.circleOutline,
                  size: 14,
                  color:
                      lipSync.enabled ? Colors.green : Colors.grey[600]),
              const SizedBox(width: 8),
              Text('口型同步',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: lipSync.enabled
                          ? Colors.white
                          : Colors.grey[500])),
            ],
          ),
        ),
        if (lipSync.enabled) ...[
          Divider(height: 1, color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 12, runSpacing: 8, children: [
              _miniField('类型', lipSync.type),
              _miniField('依赖', lipSync.dependsOn.join(', ')),
              _miniField('优先级', lipSync.priority),
            ]),
          ),
        ],
      ],
    ),
  );
}

// =========================================================================
// 通用组件
// =========================================================================

Widget _section(String title, Widget child) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        Divider(height: 1, color: Colors.grey[800]),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ],
    ),
  );
}

Widget _sectionHeader(String title, {Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    ),
  );
}

Widget _readField(String label, String value, {bool fullWidth = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label.isNotEmpty)
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      if (label.isNotEmpty) const SizedBox(height: 3),
      Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF252535),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
              fontSize: 13,
              color: value.isNotEmpty ? Colors.white : Colors.grey[600]),
        ),
      ),
    ],
  );
}

Widget _readChip(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF252535),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontSize: 13,
            color: value.isNotEmpty ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget _editField(
  String label,
  String value, {
  bool fullWidth = false,
  int maxLines = 1,
  Color? labelColor,
  ValueChanged<String>? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label.isNotEmpty)
        Text(label,
            style: TextStyle(
                fontSize: 11, color: labelColor ?? Colors.grey[600])),
      if (label.isNotEmpty) const SizedBox(height: 3),
      SizedBox(
        width: fullWidth ? double.infinity : null,
        child: TextFormField(
          initialValue: value,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
            ),
            filled: true,
            fillColor: const Color(0xFF252535),
          ),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

Widget _dropdown(
    String label, String value, List<String> options,
    {ValueChanged<String>? onChanged}) {
  final effectiveValue = options.contains(value) ? value : null;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 3),
      DropdownButtonFormField<String>(
        initialValue: effectiveValue,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          filled: true,
          fillColor: const Color(0xFF252535),
        ),
        dropdownColor: Colors.grey[900],
        items: options
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged?.call(v);
        },
      ),
    ],
  );
}

Widget _miniField(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      const SizedBox(height: 2),
      Text(
        value.isNotEmpty ? value : '—',
        style: TextStyle(
            fontSize: 12,
            color: value.isNotEmpty ? Colors.grey[300] : Colors.grey[700]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget _priorityBadge(String priority) {
  Color color;
  if (priority.contains('P0')) {
    color = Colors.red;
  } else if (priority.contains('P1')) {
    color = Colors.orange;
  } else {
    color = Colors.grey;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(priority,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}

Widget _countBadge(int count) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('$count',
        style: TextStyle(
            fontSize: 10,
            color: AppColors.primary,
            fontWeight: FontWeight.w600)),
  );
}

Widget _enabledDot() {
  return Container(
    width: 6,
    height: 6,
    decoration:
        const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
  );
}
