import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_svc.dart';

final notificationServiceProvider = Provider((_) => NotificationService());

/// 未读通知数量（红点，README 2.6）
/// 容错：后端无法连接或返回非 2xx 时降级返回 0，避免 AppHeader 持续报错重建
final unreadNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  try {
    final svc = ref.watch(notificationServiceProvider);
    return await svc.getUnreadCount();
  } catch (e) {
    debugPrint('[Notification] 获取未读数失败（降级为0）: $e');
    return 0;
  }
});

/// 通知列表
/// 容错：请求失败时降级返回空列表，避免抽屉展示错误状态
final notificationListProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  try {
    final svc = ref.watch(notificationServiceProvider);
    return await svc.list(limit: 20, offset: 0);
  } catch (e) {
    debugPrint('[Notification] 获取通知列表失败（降级为空列表）: $e');
    return [];
  }
});
