class PresetStyle {
  final String name;
  final String assetPath;
  final String description;
  final String category;

  const PresetStyle({
    required this.name,
    required this.assetPath,
    required this.description,
    required this.category,
  });

  /// 缩略图路径，用于列表/预览展示。添加为参考时使用 assetPath 原图。
  String get thumbnailPath {
    final base = assetPath.split('/').last.split('.').first;
    return 'assets/styles/thumb/${base}_thumb.jpg';
  }
}

const kPresetStyles = <PresetStyle>[
  // ── 3D 风格 ──
  PresetStyle(
    name: '3D玄幻',
    assetPath: 'assets/styles/3D玄幻_1771789333565.png',
    description: '3D渲染玄幻仙侠风格，光影华丽，场景宏大',
    category: '3D',
  ),
  PresetStyle(
    name: '3D美式',
    assetPath: 'assets/styles/3D美式_1771789337214.png',
    description: '3D美式卡通风格，色彩饱满，角色夸张可爱',
    category: '3D',
  ),
  PresetStyle(
    name: '3DQ版',
    assetPath: 'assets/styles/3DQ版_1771789340531.png',
    description: '3D Q版卡通风格，头大身小，活泼童趣',
    category: '3D',
  ),
  PresetStyle(
    name: '3D渲染2D',
    assetPath: 'assets/styles/3D渲染2D_1771789439828.png',
    description: '3D渲染2D效果，赛博朋克都市，霓虹光影',
    category: '3D',
  ),
  PresetStyle(
    name: '日式3D渲染2D',
    assetPath: 'assets/styles/日式3D渲染2D_1771789447693.png',
    description: '日式3D渲染2D效果，动漫质感，细腻光影',
    category: '3D',
  ),
  PresetStyle(
    name: '3D写实',
    assetPath: 'assets/styles/3D写实_1771789424198.png',
    description: '3D写实渲染风格，高精度模型，电影级质感',
    category: '3D',
  ),
  PresetStyle(
    name: '3D块面',
    assetPath: 'assets/styles/3D块面_1771789427385.png',
    description: '3D块面风格，几何造型，游戏角色感',
    category: '3D',
  ),
  PresetStyle(
    name: '3D方块世界',
    assetPath: 'assets/styles/3D方块世界_1771789433521.png',
    description: '方块体素风格，自然景观，类似我的世界',
    category: '3D',
  ),
  PresetStyle(
    name: '3D手游',
    assetPath: 'assets/styles/3D手游_1771789435863.png',
    description: '3D手游风格，写实废土，末日都市',
    category: '3D',
  ),

  // ── 定格动画 ──
  PresetStyle(
    name: '定格动画',
    assetPath: 'assets/styles/定格动画_1771789224936.png',
    description: '定格动画风格，粘土质感，手工艺术感',
    category: '定格',
  ),
  PresetStyle(
    name: '手办定格动画',
    assetPath: 'assets/styles/手办定格动画_1771789262586.png',
    description: '手办定格动画风格，精致模型，微缩场景',
    category: '定格',
  ),
  PresetStyle(
    name: '粘土定格动画',
    assetPath: 'assets/styles/粘土定格动画_1771789266886.png',
    description: '粘土定格动画风格，柔软质感，温馨治愈',
    category: '定格',
  ),
  PresetStyle(
    name: '积木定格动画',
    assetPath: 'assets/styles/积木定格动画_1771789270534.png',
    description: '积木定格动画风格，乐高场景，趣味搭建',
    category: '定格',
  ),
  PresetStyle(
    name: '毛绒定格动画',
    assetPath: 'assets/styles/毛绒定格动画_1771789274834.png',
    description: '毛绒定格动画风格，柔软玩偶，温馨可爱',
    category: '定格',
  ),

  // ── 2D 日系 ──
  PresetStyle(
    name: '2D动画',
    assetPath: 'assets/styles/2D动画_1771789343648.png',
    description: '经典2D日式动画风格，线条清晰，色彩明亮',
    category: '2D日系',
  ),
  PresetStyle(
    name: '2D电影',
    assetPath: 'assets/styles/2D电影_1771789346582.png',
    description: '2D日系电影风格，细腻光影，新海诚氛围',
    category: '2D日系',
  ),
  PresetStyle(
    name: '2D奇幻动画',
    assetPath: 'assets/styles/2D奇幻动画_1771789356932.png',
    description: '2D吉卜力式奇幻动画，手绘质感，自然清新',
    category: '2D日系',
  ),
  PresetStyle(
    name: '2D吉卜力动画',
    assetPath: 'assets/styles/2D吉卜力动画_1771789366500.png',
    description: '经典吉卜力画风，温暖色调，充满童话感',
    category: '2D日系',
  ),
  PresetStyle(
    name: '2D复古少女',
    assetPath: 'assets/styles/2D复古少女_1771789372830.png',
    description: '复古日系少女风，机甲赛博元素，80年代怀旧',
    category: '2D日系',
  ),
  PresetStyle(
    name: '2D韩式动画',
    assetPath: 'assets/styles/2D韩式动画_1771789375930.png',
    description: '韩式动画风格，清新唯美，雨夜氛围',
    category: '2D日系',
  ),
  PresetStyle(
    name: '2D热血动画',
    assetPath: 'assets/styles/2D热血动画_1771789381763.png',
    description: '热血动画风格，爆炸光效，力量感十足',
    category: '2D日系',
  ),

  // ── 2D 美式/漫画 ──
  PresetStyle(
    name: '2D美式动画',
    assetPath: 'assets/styles/2D美式动画_1771789362799.png',
    description: '美式漫画风格，复古街头，霓虹灯光氛围',
    category: '2D美式',
  ),
  PresetStyle(
    name: '2D复古动画',
    assetPath: 'assets/styles/2D复古动画_1771789359817.png',
    description: '复古动画风格，怀旧色调，经典构图',
    category: '2D美式',
  ),
  PresetStyle(
    name: '2D乔乔风',
    assetPath: 'assets/styles/2D乔乔风_1771789397731.png',
    description: 'JOJO奇妙冒险风格，夸张姿势，浓烈色彩',
    category: '2D美式',
  ),
  PresetStyle(
    name: '2D粗线条',
    assetPath: 'assets/styles/2D粗线条_1771789421228.png',
    description: '粗线条卡通风格，色块鲜明，动感强烈',
    category: '2D美式',
  ),
  PresetStyle(
    name: '2D橡皮管动画',
    assetPath: 'assets/styles/2D橡皮管动画_1771789284767.png',
    description: '橡皮管动画风格，早期卡通，弹性夸张',
    category: '2D美式',
  ),
  PresetStyle(
    name: '2DQ版',
    assetPath: 'assets/styles/2DQ版_1771789288867.png',
    description: '2D Q版风格，头大身小，可爱萌系',
    category: '2D美式',
  ),

  // ── 2D 特殊风格 ──
  PresetStyle(
    name: '2D像素',
    assetPath: 'assets/styles/2D像素_1771789292297.png',
    description: '像素艺术风格，8-bit复古游戏画风',
    category: '2D特殊',
  ),
  PresetStyle(
    name: '2D灵怪都市',
    assetPath: 'assets/styles/2D灵怪都市_1771789394996.png',
    description: '灵怪都市风格，赛博朋克，霓虹夜景',
    category: '2D特殊',
  ),
  PresetStyle(
    name: '2D藤本树',
    assetPath: 'assets/styles/2D藤本木_1771789392396.png',
    description: '藤本树风格，电锯人式，暗调雨夜',
    category: '2D特殊',
  ),
  PresetStyle(
    name: '2D日式侦探',
    assetPath: 'assets/styles/2D日式侦探_1771789400279.png',
    description: '柯南侦探风格，推理悬疑，雨夜街巷',
    category: '2D特殊',
  ),
  PresetStyle(
    name: '2D篮球高手',
    assetPath: 'assets/styles/2D篮球高手_1771789403029.png',
    description: '灌篮高手风格，青春热血，校园运动',
    category: '2D特殊',
  ),
  PresetStyle(
    name: '2D手冢治虫',
    assetPath: 'assets/styles/2D手冢治虫_1771789409445.png',
    description: '手冢治虫经典画风，复古漫画，时代感',
    category: '2D特殊',
  ),
  PresetStyle(
    name: '2D死亡之神',
    assetPath: 'assets/styles/2D死亡之神_1771789412688.png',
    description: '死亡笔记风格，现代都市，悬疑氛围',
    category: '2D特殊',
  ),
  PresetStyle(
    name: '2D诡异惊悚',
    assetPath: 'assets/styles/2D诡异惊悚_1771789324519.png',
    description: '伊藤润二恐怖风格，暗色扭曲，惊悚氛围',
    category: '2D特殊',
  ),

  // ── 2D 文艺/清新 ──
  PresetStyle(
    name: '2D工笔风',
    assetPath: 'assets/styles/2D工笔风_1771789295666.png',
    description: '中国风工笔画风格，花鸟山水，古典雅致',
    category: '2D文艺',
  ),
  PresetStyle(
    name: '2D简笔画',
    assetPath: 'assets/styles/2D简笔画_1771789298632.png',
    description: '简洁线描风格，极简线条，清新简约',
    category: '2D文艺',
  ),
  PresetStyle(
    name: '2D简单线条',
    assetPath: 'assets/styles/2D简单线条_1771789315949.png',
    description: '简单线条动漫风格，清晰简洁，氛围感',
    category: '2D文艺',
  ),
  PresetStyle(
    name: '2D水彩',
    assetPath: 'assets/styles/2D水彩_1771789312983.png',
    description: '水彩手绘风格，色彩晕染，柔和梦幻',
    category: '2D文艺',
  ),
  PresetStyle(
    name: '2D美式漫画',
    assetPath: 'assets/styles/2D美式漫画_1771789319050.png',
    description: '美式漫画风格，鲜艳色彩，动感十足',
    category: '2D文艺',
  ),
  PresetStyle(
    name: '2D少女漫画',
    assetPath: 'assets/styles/2D少女漫画_1771789322198.png',
    description: '少女漫画风格，柔美细腻，青春浪漫',
    category: '2D文艺',
  ),

  // ── 真人 ──
  PresetStyle(
    name: '真人电影',
    assetPath: 'assets/styles/真人电影_1771789349748.png',
    description: '真实电影画面风格，电影光影，新海诚场景',
    category: '真人',
  ),
  PresetStyle(
    name: '真人古装',
    assetPath: 'assets/styles/真人古装_1771789353265.png',
    description: '真人古装电影风格，武侠仙侠，古典韵味',
    category: '真人',
  ),
  PresetStyle(
    name: '真人复古港片',
    assetPath: 'assets/styles/真人复古港片_1771789302347.png',
    description: '复古港片风格，霓虹街头，怀旧质感',
    category: '真人',
  ),
  PresetStyle(
    name: '真人复古武侠',
    assetPath: 'assets/styles/真人复古武侠_1771789305516.png',
    description: '复古武侠电影风格，刀剑江湖，古典建筑',
    category: '真人',
  ),
  PresetStyle(
    name: '真实光晕',
    assetPath: 'assets/styles/真实光晕_1771789309932.png',
    description: '真实光晕风格，电影级光影，都市夜景',
    category: '真人',
  ),

  // ── 其他 ──
  PresetStyle(
    name: '2D鸟山明',
    assetPath: 'assets/styles/2D鸟三明_1771789386563.png',
    description: '鸟山明风格，龙珠式动感，经典漫画',
    category: '其他',
  ),
  PresetStyle(
    name: '2D哆啦',
    assetPath: 'assets/styles/2D哆小啦_1771789389663.png',
    description: '哆啦A梦式风格，温馨工坊，怀旧治愈',
    category: '其他',
  ),
];

const kPresetCategories = ['3D', '定格', '2D日系', '2D美式', '2D特殊', '2D文艺', '真人', '其他'];
