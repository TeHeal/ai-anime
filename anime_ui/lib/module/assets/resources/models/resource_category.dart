import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 素材库模态分类
enum ResourceModality {
  visual('视觉类', Color(0xFF8B5CF6)),
  audio('声音类', Color(0xFF3B82F6)),
  text('文本类', Color(0xFF22C55E));

  const ResourceModality(this.label, this.color);
  final String label;
  final Color color;
}

/// 子库类型
enum ResourceLibraryType {
  style('风格库', AppIcons.brush, ResourceModality.visual),
  character('角色库', AppIcons.person, ResourceModality.visual),
  scene('场景库', AppIcons.landscape, ResourceModality.visual),
  prop('道具库', AppIcons.tag, ResourceModality.visual),
  expression('表情库', AppIcons.person, ResourceModality.visual),
  pose('姿势库', AppIcons.run, ResourceModality.visual),
  effect('特效库', AppIcons.magicStick, ResourceModality.visual),
  voice('音色库', AppIcons.mic, ResourceModality.audio),
  voiceover('配音库', AppIcons.play, ResourceModality.audio),
  sfx('音效库', AppIcons.bolt, ResourceModality.audio),
  music('音乐库', AppIcons.music, ResourceModality.audio),
  prompt('提示词库', AppIcons.document, ResourceModality.text),
  styleGuide('风格指令库', AppIcons.brush, ResourceModality.text),
  dialogueTemplate('台词模板库', AppIcons.person, ResourceModality.text),
  scriptSnippet('剧本片段库', AppIcons.play, ResourceModality.text);

  const ResourceLibraryType(this.label, this.icon, this.modality);
  final String label;
  final IconData icon;
  final ResourceModality modality;

  static List<ResourceLibraryType> forModality(ResourceModality m) =>
      values.where((v) => v.modality == m).toList();
}
