import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/view/review_ui_provider.dart';
import 'package:anime_ui/module/script/view/widgets/editor_common.dart';

// ---------------------------------------------------------------------------
// 5. 音频（台词 + 音频设计 + 各音频通道）
// ---------------------------------------------------------------------------

Widget? audioBadge(ShotV4 shot) {
  final count = shot.audio?.enabledCount ?? 0;
  if (count == 0) return null;
  return countBadge(count);
}

Widget buildAudioContent(
    ShotV4 shot, bool editing, ReviewUiNotifier notifier) {
  final audio = shot.audio;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 台词
      if (shot.dialogue.isNotEmpty || editing) ...[
        editing
            ? editField('台词', shot.dialogue,
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
            ? editField('音频设计', shot.audioDesignText,
                fullWidth: true,
                onChanged: (v) {
                  notifier.updateCurrentShot((s) {
                    s.audioDesignText = v;
                    return s;
                  });
                })
            : readField('音频设计', shot.audioDesignText, fullWidth: true),
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
                  child: miniField(f.$1, f.$2),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    ),
  );
}
