/// 统一间距常量
///
/// 用于 padding、margin、SizedBox、Gap 等，保持视觉一致性
abstract final class Spacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double mid = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// 卡片/面板内边距（与 StyledCard 默认一致）
  static const double cardPadding = 22;

  /// 网格/列表项间距
  static const double gridGap = 14;

  /// 表单/输入框间距
  static const double formGap = 12;

  /// Chip 水平内边距（筛选芯片、分组芯片等）
  static const double chipPaddingH = 10;

  /// Chip 垂直内边距（紧凑型）
  static const double chipPaddingV = 5;

  /// Chip 垂直内边距（更紧凑，如全选芯片）
  static const double chipPaddingVSmall = 6;

  /// 按钮垂直内边距（FilledButton、侧边栏项等）
  static const double buttonPaddingV = 10;

  /// 图标与文字紧凑间距（芯片、全选等）
  static const double iconGapSm = 6;

  /// 图标与文字常规间距（侧边栏、菜单项等）
  static const double iconGapMd = 10;

  /// 头像/圆形图标尺寸（用户菜单等）
  static const double avatarSize = 28;

  /// 菜单项图标尺寸
  static const double menuIconSize = 18;

  /// 配置项标签与内容间距
  static const double contentGap = 14;

  /// 进度条/分割线高度
  static const double progressBarHeight = 3;

  /// 极小水平间距（如树形导航缩进）
  static const double tinyGap = 3;

  /// 紧凑输入/徽章内间距
  static const double inputGapSm = 5;

  /// 徽章内紧凑间距（状态徽章、模式徽章等）
  static const double badgeGap = 7;

  /// 登录卡片尺寸（小屏适配用 clamp 边界）
  static const double loginCardMinWidth = 280;
  static const double loginCardMaxWidth = 420;
  static const double loginCardMinHeight = 360;
  static const double loginCardMaxHeight = 420;

  /// 资产列表面板宽度（min/max）
  static const double listPanelMinWidth = 260;
  static const double listPanelMaxWidth = 400;

  /// 审核布局左右面板宽度
  static const double reviewLeftWidth = 240;
  static const double reviewRightWidth = 260;

  /// 侧边导航栏宽度（折叠/展开）
  static const double sideNavCollapsedWidth = 64;
  static const double sideNavExpandedWidth = 180;

  /// 列表缩略图尺寸（资产列表、镜头列表等）
  static const double thumbnailSize = 44;

  /// 标准栏高度（TabBar、输入框等）
  static const double barHeight = 48;

  /// 弹窗顶部内边距（与侧边/底部区分）
  static const double dialogPaddingTop = 28;

  /// 块项左侧缩进（脚本块编辑）
  static const double blockIndent = 44;

  /// 表单标签列宽度（详情面板等）
  static const double formLabelWidth = 72;

  /// 空状态占位高度（任务区空等）
  static const double emptyStatePadding = 60;

  /// 分割线/细线高度
  static const double dividerHeight = 1;
}
