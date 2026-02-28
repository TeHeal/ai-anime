import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 选中的道具 ID（支持 int 或 String UUID）
class SelectedPropIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final selectedPropIdProvider =
    NotifierProvider<SelectedPropIdNotifier, String?>(SelectedPropIdNotifier.new);

/// 道具状态筛选
class PropStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final propStatusFilterProvider =
    NotifierProvider<PropStatusFilterNotifier, String?>(
  PropStatusFilterNotifier.new,
);

/// 道具名称搜索
class PropNameSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final propNameSearchProvider =
    NotifierProvider<PropNameSearchNotifier, String>(PropNameSearchNotifier.new);
