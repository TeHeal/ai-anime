import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 选中的场景 ID（支持 int 或 String UUID）
class SelectedLocIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final selectedLocIdProvider =
    NotifierProvider<SelectedLocIdNotifier, String?>(SelectedLocIdNotifier.new);

/// 场景状态筛选
class LocStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final locStatusFilterProvider =
    NotifierProvider<LocStatusFilterNotifier, String?>(
  LocStatusFilterNotifier.new,
);

/// 场景名称搜索
class LocNameSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final locNameSearchProvider =
    NotifierProvider<LocNameSearchNotifier, String>(LocNameSearchNotifier.new);
