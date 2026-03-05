import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前选中的角色 ID（UUID 字符串）
class SelectedCharIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final selectedCharIdProvider =
    NotifierProvider<SelectedCharIdNotifier, String?>(SelectedCharIdNotifier.new);

/// 状态筛选：skeleton / draft / confirmed
class CharStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final charStatusFilterProvider =
    NotifierProvider<CharStatusFilterNotifier, String?>(
        CharStatusFilterNotifier.new);

/// 重要性筛选：main / support / functional / extra
class CharImportanceFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final charImportanceFilterProvider =
    NotifierProvider<CharImportanceFilterNotifier, String?>(
        CharImportanceFilterNotifier.new);

/// 角色类型筛选：human / nonhuman / personified / narrator
class CharRoleTypeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final charRoleTypeFilterProvider =
    NotifierProvider<CharRoleTypeFilterNotifier, String?>(
        CharRoleTypeFilterNotifier.new);

/// 一致性要求筛选：strong / medium / weak
class CharConsistencyFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final charConsistencyFilterProvider =
    NotifierProvider<CharConsistencyFilterNotifier, String?>(
        CharConsistencyFilterNotifier.new);

/// 名称搜索
class CharNameSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final charNameSearchProvider =
    NotifierProvider<CharNameSearchNotifier, String>(CharNameSearchNotifier.new);
