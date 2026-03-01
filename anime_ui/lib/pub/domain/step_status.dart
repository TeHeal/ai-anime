/// 对象状态枚举（6 个核心对象：剧本/资产/脚本/镜图/镜头/成片）
enum StepStatus { notStarted, inProgress, completed }

/// 各对象的状态集合
class StepStatuses {
  const StepStatuses(this.statuses);
  final List<StepStatus> statuses;

  StepStatus operator [](int i) =>
      i >= 0 && i < statuses.length ? statuses[i] : StepStatus.notStarted;
}
