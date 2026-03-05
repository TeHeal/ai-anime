import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 素材库模态分类
enum ResourceModality {
  visual('视觉类', AppColors.primary),
  audio('声音类', AppColors.info),
  text('文本类', AppColors.success);

  const ResourceModality(this.label, this.color);
  final String label;
  final Color color;
}

/// 素材添加方式
enum AddMode { upload, batchUpload, aiGenerate, manual }

/// 资源生成任务状态（用于卡片实时反馈覆盖层）
enum ResourceTaskStatus { generating, completed, failed }

/// 子库类型（风格已为独立顶级 Tab，不在此枚举）
enum ResourceLibraryType {
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

  /// 素材页展示用：按模态返回子库列表
  static List<ResourceLibraryType> forModalityInResources(ResourceModality m) =>
      values.where((v) => v.modality == m).toList();

  /// 各子库支持的添加方式
  List<AddMode> get availableAddModes => switch (this) {
        // 视觉类：上传 + 批量上传 + AI 生成
        ResourceLibraryType.character ||
        ResourceLibraryType.scene ||
        ResourceLibraryType.prop ||
        ResourceLibraryType.expression ||
        ResourceLibraryType.pose ||
        ResourceLibraryType.effect =>
          [AddMode.upload, AddMode.batchUpload, AddMode.aiGenerate],
        // 音色库：上传 + 批量上传 + AI 生成
        ResourceLibraryType.voice =>
          [AddMode.upload, AddMode.batchUpload, AddMode.aiGenerate],
        // 配音/音效/音乐：上传 + 批量上传
        ResourceLibraryType.voiceover ||
        ResourceLibraryType.sfx ||
        ResourceLibraryType.music =>
          [AddMode.upload, AddMode.batchUpload],
        // 文本类：上传 + 批量上传 + AI 生成
        ResourceLibraryType.prompt ||
        ResourceLibraryType.styleGuide ||
        ResourceLibraryType.dialogueTemplate ||
        ResourceLibraryType.scriptSnippet =>
          [AddMode.upload, AddMode.batchUpload, AddMode.aiGenerate],
      };
}
