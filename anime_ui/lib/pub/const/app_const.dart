/// 应用常量
const String appName = 'AI 漫剧，一眼入戏';
/// 项目页/主入口的品牌标语（原 AI 漫剧）
const String projectsBrand = '新视觉，用 AI 讲好每一段故事';
/// 侧边栏/导航品牌（原 AI 漫剧工厂）
const String headerBrand = 'AI 漫剧';
const int storyMaxLength = 6000;
const int segmentMaxLength = 300;
const int titleMaxLength = 30;
const int promptMaxLength = 1500;
const int imageMaxSizeMb = 10;
const int imageMaxCount = 20;

/// 分镜景别选项
const List<String> shotCameraTypes = ['特写', '中景', '远景', '全景', '近景'];

/// 分镜机位角度选项
const List<String> shotCameraAngles = ['平视', '俯视', '仰视', '平铺'];

/// 角色语音风格选项（与 Elser AI 参考一致）
const List<String> characterVoiceOptions = [
  '平静的美式',
  '充满活力的美式',
  '温柔的英式',
  '粗哑的美式',
  '磁性的美式',
  '节奏缓慢的英式',
  '感伤的美式',
  '稳重的美式',
];
