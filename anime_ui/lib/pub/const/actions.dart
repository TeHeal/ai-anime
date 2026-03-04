/// 操作权限常量（与后端 pub/auth/rbac.go 保持一致）
/// 命名为 AppActions 避免与 Flutter 内置 Actions widget 冲突
abstract final class AppActions {
  // 项目级
  static const projectCreate = 'project.create';
  static const projectDelete = 'project.delete';
  static const projectView = 'project.view';
  static const contentEdit = 'content.edit';
  static const aiGenerate = 'ai.generate';
  static const reviewDecide = 'review.decide';
  static const membersManage = 'members.manage';
  static const auditView = 'audit.view';

  // 脚本
  static const scriptEdit = 'script.edit';
  static const scriptReview = 'script.review';

  // 镜图
  static const shotImageEdit = 'shot_image.edit';
  static const shotImageGenerate = 'shot_image.generate';
  static const shotImageReview = 'shot_image.review';

  // 镜头视频
  static const shotVideoEdit = 'shot_video.edit';
  static const shotVideoGenerate = 'shot_video.generate';
  static const shotVideoReview = 'shot_video.review';

  // 成片
  static const compositeEdit = 'composite.edit';
  static const compositeExport = 'composite.export';

  // 资产
  static const assetEdit = 'asset.edit';
}
