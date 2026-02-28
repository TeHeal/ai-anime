import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 文字创作助理操作：剧本、提示词等文本小场景通用。
enum AiAction { polish, expand, condense, continueWrite, rewrite }

const aiActionLabels = <AiAction, String>{
  AiAction.polish: '润色',
  AiAction.expand: '扩写',
  AiAction.condense: '缩写',
  AiAction.continueWrite: '续写',
  AiAction.rewrite: '改写',
};

const aiActionIcons = <AiAction, IconData>{
  AiAction.polish: AppIcons.autoFixHigh,
  AiAction.expand: AppIcons.unfoldMore,
  AiAction.condense: AppIcons.unfoldLess,
  AiAction.continueWrite: AppIcons.arrowForward,
  AiAction.rewrite: AppIcons.refresh,
};
