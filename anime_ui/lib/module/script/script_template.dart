import 'dart:convert';

/// 分镜脚本 JSON 模板，供用户下载参考格式
final String scriptTemplateJson = const JsonEncoder.withIndent('  ').convert({
  '版本': '4.0',
  '格式标识': 'storyboard_ai_v4',
  '项目': '示例项目',
  '集数': 1,
  '集标题': '第一集 示例',
  '镜头列表': [
    {
      '镜头号': 1,
      '时长': 3.0,
      '优先级': 'P1核心',
      '景别': '中景',
      '运镜': '固定',
      '角色位置': '画面中央',
      '场景描述': '黄昏的街道上，主角独自行走，路灯依次亮起。',
      '台词': '',
      '角色名': '主角',
      '情绪描述': '孤独，若有所思',
      '音频设计': '城市环境音，远处车流声',
      'AI提示词': 'A young man walking alone on a city street at dusk, streetlights turning on one by one, warm golden light, anime style',
      '负面词': '模糊，低质量，变形',
      '转场': '淡入淡出',
      '备注': '',
    },
    {
      '镜头号': 2,
      '时长': 2.5,
      '优先级': 'P1核心',
      '景别': '特写',
      '运镜': '推',
      '角色位置': '画面中央偏左',
      '场景描述': '主角停下脚步，抬头望向天空，表情从迷茫变为坚定。',
      '台词': '不管怎样，我不会放弃。',
      '角色名': '主角',
      '情绪描述': '坚定，充满希望',
      '音频设计': '轻柔的钢琴BGM渐入',
      'AI提示词': 'Close-up of a young man looking up at the sky, expression changing from confused to determined, sunset background, anime style',
      '负面词': '模糊，低质量，变形',
      '转场': '硬切',
      '备注': '',
    },
  ],
});

/// 模板下载文件名
const scriptTemplateFileName = '分镜脚本模板.json';
