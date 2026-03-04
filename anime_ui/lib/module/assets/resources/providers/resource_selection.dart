import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 泛型简单值 Notifier，用于单值状态管理
class _ValueNotifier<T> extends Notifier<T> {
  _ValueNotifier(this._initial);
  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

/// 视图模式
enum ViewMode { grid, list, preview }

final viewModeProvider =
    NotifierProvider<_ValueNotifier<ViewMode>, ViewMode>(
  () => _ValueNotifier(ViewMode.grid),
);

/// 批量模式开关
final batchModeProvider =
    NotifierProvider<_ValueNotifier<bool>, bool>(() => _ValueNotifier(false));

/// 批量选中的资源 ID
class SelectedResourceIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void setAll(Iterable<String> ids) => state = ids.toSet();

  void clear() => state = {};
}

final selectedResourceIdsProvider =
    NotifierProvider<SelectedResourceIdsNotifier, Set<String>>(
  SelectedResourceIdsNotifier.new,
);
