import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 场景块类型选项
const blockItemTypeOptions = <String, String>{
  'action': '动作描写',
  'dialogue': '台词',
  'os': 'OS旁白',
  'direction': '场景指示',
  'closeup': '特写',
};

/// 内容最大字符数
const blockItemMaxChars = 300;

/// 按类型返回强调色
Color blockItemAccentColorFor(String type) {
  switch (type) {
    case 'dialogue':
      return AppColors.categoryCharacter;
    case 'os':
      return AppColors.info;
    case 'direction':
      return AppColors.tagAmber;
    case 'closeup':
      return AppColors.error;
    case 'action':
    default:
      return AppColors.success;
  }
}

/// 是否显示角色/情绪字段
bool blockItemShowCharacterFields(String type) =>
    type == 'dialogue' || type == 'os';

/// 按类型返回输入提示
String blockItemHintFor(String type) {
  switch (type) {
    case 'dialogue':
      return '输入台词内容…';
    case 'os':
      return '输入旁白内容…';
    case 'direction':
      return '输入场景指示…';
    case 'closeup':
      return '输入特写描述…';
    case 'action':
    default:
      return '输入动作描写…';
  }
}
