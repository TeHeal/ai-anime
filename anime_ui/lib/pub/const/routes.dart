/// 路由路径常量 — 对象驱动导航体系
abstract final class Routes {
  static const String login = '/login';
  static const String projects = '/projects';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';

  // ── 一级导航（6 个核心对象） ──

  static const String story = '/story';
  static const String assets = '/assets';
  static const String script = '/script';
  static const String shotImages = '/shot-images';
  static const String shots = '/shots';
  static const String episode = '/episode';

  // ── 二级导航（对象内部操作） ──

  // ① 剧本 Story
  static const String storyImport = '$story/import';
  static const String storyEdit = '$story/edit';
  static const String storyPreview = '$story/preview';
  static const String storyConfirm = '$story/confirm';

  // ② 资产 Assets
  static const String assetsOverview = '$assets/overview';
  static const String assetsResources = '$assets/resources';
  static const String assetsCharacters = '$assets/characters';
  static const String assetsEnvironments = '$assets/environments';
  static const String assetsProps = '$assets/props';
  static const String assetsVersions = '$assets/versions';

  // ③ 脚本 Script
  static const String scriptStructure = '$script/structure';
  static const String scriptCenter = '$script/center';
  static const String scriptReview = '$script/review';
  static const String scriptFreeze = '$script/freeze';

  // ③-legacy (保留兼容，redirect 到新路由)
  static const String scriptEpisodes = scriptCenter;
  static const String scriptGenerate = scriptCenter;
  static const String scriptEdit = scriptReview;
  static const String scriptVersions = scriptReview;

  // ④ 镜图 Shot Images (replaces storyboard)
  static const String shotImagesCenter = '$shotImages/center';
  static const String shotImagesReview = '$shotImages/review';

  // ④-legacy (storyboard → shotImages redirect)
  static const String storyboard = shotImages;
  static const String storyboardSketch = shotImagesCenter;
  static const String storyboardComposition = shotImagesCenter;
  static const String storyboardReview = shotImagesReview;
  static const String storyboardApprove = shotImagesReview;

  // ⑤ 镜头 Shots (2 Tab: 生成中心 / 审核编辑)
  static const String shotsCenter = '$shots/center';
  static const String shotsReview = '$shots/review';

  // ⑤-legacy
  static const String shotsRender = shotsCenter;
  static const String shotsList = shotsCenter;
  static const String shotsApprove = shotsReview;

  // ⑥ 成片 Episode
  static const String episodeTimeline = '$episode/timeline';
  static const String episodeAudio = '$episode/audio';
  static const String episodeVersions = '$episode/versions';
  static const String episodeExport = '$episode/export';

  /// 一级对象路径列表
  static const List<String> objectPaths = [
    story, assets, script, shotImages, shots, episode,
  ];

  /// 每个对象的默认子路由
  static const Map<String, String> objectDefaults = {
    story: storyImport,
    assets: assetsOverview,
    script: scriptStructure,
    shotImages: shotImagesCenter,
    shots: shotsCenter,
    episode: episodeTimeline,
  };
}
