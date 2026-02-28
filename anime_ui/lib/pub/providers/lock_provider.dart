import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/lock_status.dart';
import 'package:anime_ui/pub/services/lock_svc.dart';
import 'project_provider.dart';

class LockNotifier extends Notifier<LockStatus> {
  final _svc = LockService();

  @override
  LockStatus build() => const LockStatus();

  int? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> load() async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final status = await _svc.getStatus(pid);
      state = status;
    } catch (e, st) {
      debugPrint('LockNotifier.refresh: $e');
      debugPrint(st.toString());
    }
  }

  Future<bool> lockPhase(String phase) async {
    final pid = _projectId;
    if (pid == null) return false;
    try {
      final status = await _svc.lock(pid, phase);
      state = status;
      return true;
    } catch (e, st) {
      debugPrint('LockNotifier.lockPhase: $e');
      debugPrint(st.toString());
      return false;
    }
  }

  Future<bool> unlockPhase(String phase) async {
    final pid = _projectId;
    if (pid == null) return false;
    try {
      final status = await _svc.unlock(pid, phase);
      state = status;
      return true;
    } catch (e, st) {
      debugPrint('LockNotifier.unlockPhase: $e');
      debugPrint(st.toString());
      return false;
    }
  }

  void updateFromProjectResponse(Map<String, dynamic>? lockStatusJson) {
    if (lockStatusJson != null) {
      state = LockStatus.fromJson(lockStatusJson);
    }
  }

  void clear() {
    state = const LockStatus();
  }
}

final lockProvider =
    NotifierProvider<LockNotifier, LockStatus>(LockNotifier.new);
